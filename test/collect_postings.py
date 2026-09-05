"""
Collect Saudi IS job postings via the JSearch API into labeled_postings.csv.

Appends. Existing rows are read, kept byte-for-byte, and written back
unchanged -- including any skill_ids you have already filled in by hand. New
ids continue from the highest one present, and any job whose URL is already in
the file is skipped before it can become a row.

TARGET_PER_CAREER is a target for the TOTAL rows held per career. Each run
tops each career up to that number and stops; a career already at target costs
no requests. Postings screened out (wrong country, remote-elsewhere, or below
the length floor) are written to labeled_postings_excluded.csv with the reason,
never dropped silently.

Setup:
    pip install requests python-dotenv
    echo "JSEARCH_API_KEY=your_key_here" > .env
    echo ".env" >> .gitignore

Run:
    python collect_postings.py

Writes posting text with skill_ids blank. Labeling is a separate manual pass.
"""

import csv
import json
import os
import re
import tempfile
import time
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

import requests
from dotenv import load_dotenv

load_dotenv()
API_KEY = os.environ["JSEARCH_API_KEY"]
ENDPOINT = "https://api.openwebninja.com/jsearch/search-v2"

# Five IS-focused careers. Query strings are what gets sent; the key is the
# career label written to the CSV.
CAREERS = {
    "Business Analyst": "business analyst",
    "Data Analyst": "data analyst",
    "ERP Consultant": "ERP consultant",
    "IT Support Specialist": "IT support specialist",
    "Software Developer": "software developer",
}

TARGET_PER_CAREER = 5
OUT = "labeled_postings.csv"
RAW_DIR = "raw_responses"

# job_title is captured from the API rather than reconstructed from URL slugs.
# Its absence is what let a Web Developer advert sit under IT Support Specialist
# (row 16) through a full duplicate check without anything catching it.
FIELDS = ["id", "career", "job_title", "lang", "posting_text", "skill_ids",
          "employer", "city", "source", "url", "onet_soc"]

# Columns a pre-existing file must already have. job_title is deliberately not
# here: files written before it existed are migrated, not rejected.
LEGACY_FIELDS = [c for c in FIELDS if c != "job_title"]

# Minimum description length. Aggregators republish a rewritten three-sentence
# blurb instead of the employer's advert; those yield ~5 chunks against ~53 for
# a full posting, so a skill has roughly ten times less chance of being matched.
# Since demand weight is the fraction of postings mentioning a skill, mixing the
# two silently deflates every weight computed from the short ones.
MIN_POSTING_CHARS = 900

EXCLUDED = "labeled_postings_excluded.csv"
EXCLUDED_FIELDS = FIELDS + ["excluded_reason", "excluded_on"]

ARABIC = re.compile(r"[؀-ۿ]")
LATIN = re.compile(r"[A-Za-z]")

# Params that identify the click, not the job. LinkedIn appends refId and
# trackingId, so the same vacancy comes back with a different URL every time --
# leaving these in would defeat the skip-if-already-present check. Anything not
# listed here is kept, because some boards put the job id in the query string
# (Indeed uses ?jk=...) and stripping the whole query would collapse every
# Indeed posting into one.
TRACKING_PARAMS = {
    "refid", "trackingid", "trk", "position", "pagenum", "originalsubdomain",
    "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
}


def canon_url(url: str) -> str:
    """Canonical form for comparison only. Never written to the CSV."""
    url = (url or "").strip()
    if not url:
        return ""
    try:
        p = urlsplit(url)
    except ValueError:
        return url.lower()
    kept = sorted((k, v) for k, v in parse_qsl(p.query, keep_blank_values=True)
                  if k.lower() not in TRACKING_PARAMS)
    return urlunsplit((p.scheme.lower(), p.netloc.lower(),
                       p.path.rstrip("/"), urlencode(kept), ""))


def detect_lang(text: str) -> str:
    """
    en / ar / mixed. Mixed when the minority script carries >25% of characters,
    matching the rule used for manual collection so the two are comparable.
    """
    ar = len(ARABIC.findall(text))
    la = len(LATIN.findall(text))
    total = ar + la
    if total == 0:
        return "en"
    ar_share = ar / total
    if ar_share > 0.75:
        return "ar"
    if ar_share < 0.25:
        return "en"
    return "mixed"


# A posting can carry job_country=SA and still be a vacancy somewhere else --
# the Canonical advert (row 21) was tagged Riyadh while its own text said "based
# remotely in the Americas region". These patterns look for a role explicitly
# sited outside the Kingdom. They deliberately do NOT match a posting that names
# a Saudi city alongside another one: "based in Riyadh or Karachi" is a real
# Saudi vacancy with a second location, not a foreign one.
REMOTE_ELSEWHERE = [
    re.compile(r"based\s+remotely\s+in", re.I),
    re.compile(r"remote(?:ly)?\s+(?:in|from|within)\s+(?:the\s+)?"
               r"(?:americas|emea|apac|europe|north america|latin america|"
               r"united states|usa|uk|india|pakistan)", re.I),
    re.compile(r"(?:americas|emea|apac)\s+region", re.I),
    re.compile(r"location:?\s*remote\s*[-–(]\s*"
               r"(?:americas|emea|apac|europe|global|us)", re.I),
    re.compile(r"work\s+from\s+anywhere", re.I),
]

# This endpoint leaves job_country, job_city and job_state null for a large
# share of results -- entire publishers at a time, GulfTalent among them --
# while job_location still carries the place as free text, often in Arabic
# ("الرياض  •  عبر GulfTalent"). Screening on job_country alone therefore threw
# out real Riyadh vacancies, and did so non-randomly, which is a sampling bias
# rather than a tidy filter.
#
# Word boundaries matter here: "جدة" (Jeddah) is a substring of "المتجددة"
# (renewable), so a bare containment test would read "الطاقة المتجددة" as a
# Jeddah vacancy. \b sits on the Unicode word class, so the affix blocks it.
SAUDI_PLACES = re.compile(
    r"\b(?:"
    r"saudi|k\.?s\.?a\.?|riyadh|jeddah|jiddah|dammam|khobar|al[- ]?khobar|"
    r"dhahran|mecca|makkah|medina|madinah|taif|tabuk|abha|jubail|yanbu|"
    r"ha'?il|buraidah|buraydah|qassim|khamis[- ]mushait|najran|jazan|jizan|"
    r"al[- ]?ahsa|hofuf|qatif|neom|kharj|unaizah|arar|sakaka|baha|"
    r"eastern province"
    r"|السعودية|السعوديه|المملكة|الرياض|جدة|الدمام|الخبر|الظهران|مكة|المكرمة|"
    r"المدينة|المنورة|الطائف|تبوك|أبها|ابها|الجبيل|ينبع|حائل|بريدة|القصيم|"
    r"خميس|مشيط|نجران|جازان|جيزان|الأحساء|الاحساء|الهفوف|القطيف|نيوم|الخرج|"
    r"عنيزة|عرعر|سكاكا|الباحة|الشرقية"
    r")\b", re.I | re.U)


def in_saudi(job: dict) -> bool:
    """
    Is this vacancy in Saudi Arabia?

    Prefers the structured country field; falls back to the free-text location
    only when the structured one is absent, so a populated non-Saudi country is
    still authoritative and cannot be talked round by a stray city name.
    """
    country = (job.get("job_country") or "").strip()
    if country:
        return country.upper() in ("SA", "SAUDI ARABIA")

    for field in ("job_location", "job_city", "job_state"):
        val = job.get(field)
        if val and SAUDI_PLACES.search(str(val)):
            return True
    return False


# Some publishers store a clipped copy of the advert, cut mid-sentence at a
# fixed size. Length does not find these: the JobLeads Data Analyst posting is
# 1087 characters and still stops at "Advanced knowledge of SQL, ETL and data".
# A clipped advert loses whatever requirements came after the cut, so its skills
# are missing for a reason that has nothing to do with the employer.
#
# Plenty of complete adverts legitimately end without a full stop -- a bullet
# ("• Regulatory and Compliance Requirements Analysis"), a field ("Work
# Location: In person"), a keyword list. So missing punctuation alone is not
# evidence; the ending also has to read as mid-clause.
TRAILING_JUNK = re.compile(r"(?:#J-\d+-\w+|[|•\-–—\s])+$")
TERMINAL_PUNCT = tuple(".!?…\"')]}»”’۔؟")

# A sentence stopping on one of these is waiting for its next word.
DANGLING_TAIL = {
    "and", "or", "nor", "but", "of", "to", "in", "for", "with", "as", "at",
    "by", "from", "on", "the", "a", "an", "is", "are", "was", "were", "be",
    "been", "that", "which", "including", "such", "plus", "via", "per",
    "into", "over", "under", "between", "during", "about", "than", "then",
    "if", "when", "while", "where", "who", "whom", "whose", "this", "these",
    "those", "our", "your", "their", "its", "his", "her", "not", "no",
}
CONJUNCTIONS = {"and", "or", "&"}


def looks_truncated(text: str) -> bool:
    """
    Does this text stop mid-clause? Independent of how long it is.

    Three signals, all requiring the absence of terminal punctuation first:
    a trailing comma or colon, an ending on a function word, or a coordinating
    conjunction in the final two words -- "SQL, ETL and data" is waiting for
    another item, while "the Saudi and Egyptian employment laws" is finished.
    """
    t = re.sub(r"\s*\|\s*", " ", text or "")
    t = re.sub(r"\s+", " ", t).strip()
    t = TRAILING_JUNK.sub("", t).strip()   # scraper footers sit after the cut
    if not t or t.endswith(TERMINAL_PUNCT):
        return False
    if t.endswith((",", ":", ";", "/")):
        return True

    tokens = re.findall(r"[\w'&/-]+", t.lower())
    if not tokens:
        return False
    if tokens[-1] in DANGLING_TAIL:
        return True
    return len(tokens) >= 2 and tokens[-2] in CONJUNCTIONS


AI_GIG = [
    "help train",
    "next-generation ai",
    "no prior experience in ai",
    "your domain knowledge is what matters",
    "freelance contributor",
]


def screen(job: dict) -> str | None:
    """
    Reason this posting should not become a row, or None to keep it.

    Returning the reason rather than a bool is what makes the excluded file
    auditable -- every dropped posting can say why it was dropped.
    """
    if not in_saudi(job):
        where = job.get("job_country") or job.get("job_location") or "unset"
        return f"not a Saudi vacancy (location {str(where)[:60]!r})"

    desc = job.get("job_description") or ""
    low = desc.lower()

    if any(p in low for p in AI_GIG):
        return "AI-annotation gig, not an employer vacancy"

    for pat in REMOTE_ELSEWHERE:
        m = pat.search(desc)
        if m:
            return f"remote role sited outside Saudi Arabia ({m.group(0).strip()!r})"

    if looks_truncated(desc):
        tail = re.sub(r"\s+", " ", desc).strip()[-48:]
        return f"description truncated mid-clause (ends {tail!r})"

    if len(desc) < MIN_POSTING_CHARS:
        return (f"description {len(desc)} chars, below the "
                f"{MIN_POSTING_CHARS}-char floor (aggregator summary)")
    return None


def is_saudi(job: dict) -> bool:
    """Kept for callers that only need the yes/no. screen() gives the reason."""
    return screen(job) is None


def load_existing(path: str) -> tuple[list[dict], list[str], set[str], int]:
    """
    Read what is already on disk.

    Returns the rows verbatim, the header to write back, the set of canonical
    URLs already present, and the highest id seen. The existing header wins
    over FIELDS so that a column added by hand survives the round trip; a
    missing required column is an error rather than something to paper over.
    """
    if not os.path.exists(path):
        return [], list(FIELDS), set(), 0

    with open(path, newline="", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        header = list(reader.fieldnames or [])
        rows = list(reader)

    missing = [c for c in LEGACY_FIELDS if c not in header]
    if missing:
        raise SystemExit(
            f"{path} is missing required column(s) {missing}.\n"
            f"Found: {header}\n"
            f"Refusing to run: appending would reshape rows that already exist.")

    # Migrate a file written before job_title existed. Existing rows get the
    # column empty rather than a value reconstructed from their URL -- the
    # column records what the API reported, and backfilling old rows with
    # derived values would put inference into a field meant for source data.
    if "job_title" not in header:
        header.insert(header.index("career") + 1, "job_title")
        for r in rows:
            r.setdefault("job_title", "")
        print(f"  migrated: added empty job_title column to {len(rows)} row(s)")

    seen = {canon_url(r.get("url", "")) for r in rows}
    seen.discard("")
    ids = [int(r["id"]) for r in rows
           if str(r.get("id", "")).strip().lstrip("-").isdigit()]
    return rows, header, seen, max(ids, default=0)


def call_api(query: str, cursor: str | None) -> dict:
    """One request, with retries. 504s from this endpoint are transient."""
    params = {"query": query, "country": "sa"}
    if cursor:
        params["cursor"] = cursor

    for attempt in range(3):
        r = requests.get(ENDPOINT, params=params,
                         headers={"X-API-Key": API_KEY}, timeout=90)
        if r.status_code in (502, 503, 504):
            wait = 5 * (attempt + 1)
            print(f"[{r.status_code}, retry in {wait}s] ", end="", flush=True)
            time.sleep(wait)
            continue
        r.raise_for_status()
        return r.json()
    r.raise_for_status()


def fetch(career: str, query: str, want: int,
          seen: set[str]) -> tuple[list[dict], int, list[tuple[dict, str]]]:
    """
    Page until `want` genuinely new qualifying rows land.

    Returns kept jobs, how many were already held by URL, and the jobs screened
    out paired with the reason -- those go to the excluded file, so a rejection
    is always inspectable rather than a silent drop.

    Already-seen URLs are skipped here rather than after collecting, so paging
    continues past them instead of burning the quota on jobs we already hold.
    """
    os.makedirs(RAW_DIR, exist_ok=True)
    kept, rejects, skipped, cursor, page = [], [], 0, None, 0

    while len(kept) < want and page < 4:
        payload = call_api(query, cursor)

        # Cache before parsing: a parser bug shouldn't cost another request.
        slug = career.lower().replace(" ", "_")
        stamp = time.strftime("%Y%m%d-%H%M%S")
        with open(f"{RAW_DIR}/{slug}_p{page}_{stamp}.json", "w",
                  encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, indent=2)

        data = payload.get("data") or {}
        for job in data.get("jobs", []):
            if not job.get("job_description"):
                continue
            key = canon_url(job.get("job_apply_link", ""))
            if key and key in seen:
                skipped += 1
                continue
            reason = screen(job)
            if reason:
                seen.add(key)      # don't re-screen it on a later page
                rejects.append((job, reason))
                continue
            seen.add(key)          # also guards against dupes within this run
            kept.append(job)
            if len(kept) >= want:
                break

        cursor = data.get("cursor")
        page += 1
        if not cursor:
            break
        time.sleep(1)
    return kept, skipped, rejects


def write_atomic(path: str, header: list[str], rows: list[dict]) -> None:
    """
    Write via a temp file and replace.

    Append mode rewrites the whole file every run, so a crash midway through
    would otherwise take the existing rows -- and any hand-entered skill_ids --
    with it. utf-8-sig so Excel opens the Arabic correctly.
    """
    d = os.path.dirname(os.path.abspath(path)) or "."
    fd, tmp = tempfile.mkstemp(dir=d, suffix=".csv.tmp")
    try:
        with os.fdopen(fd, "w", newline="", encoding="utf-8-sig") as f:
            w = csv.DictWriter(f, fieldnames=header, extrasaction="ignore")
            w.writeheader()
            for r in rows:
                w.writerow({k: r.get(k, "") for k in header})
        os.replace(tmp, path)
    except BaseException:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


def max_known_id(*paths: str) -> int:
    """
    Highest id across every file that has ever held a row.

    Ids must come from the excluded file too. A row evicted from the main file
    keeps its id there, and allocating from the main file alone would hand that
    id straight to the next posting collected -- two different vacancies under
    one id, across the two files that are meant to join on it.
    """
    top = 0
    for path in paths:
        if not os.path.exists(path):
            continue
        with open(path, newline="", encoding="utf-8-sig") as f:
            for r in csv.DictReader(f):
                v = str(r.get("id", "")).strip()
                if v.isdigit():
                    top = max(top, int(v))
    return top


def excluded_urls(path: str = EXCLUDED) -> set[str]:
    """
    URLs already screened out on a previous run.

    These must join the seen-set, otherwise every run re-fetches and re-screens
    the same known-bad postings: quota spent to reach the same verdict, and a
    second identical row added to the excluded file each time.
    """
    if not os.path.exists(path):
        return set()
    with open(path, newline="", encoding="utf-8-sig") as f:
        urls = {canon_url(r.get("url", "")) for r in csv.DictReader(f)}
    urls.discard("")
    return urls


def append_excluded(entries: list[dict]) -> None:
    """Append to the excluded file, creating it with a header if absent."""
    if not entries:
        return
    fresh = not os.path.exists(EXCLUDED)
    with open(EXCLUDED, "a", newline="",
              encoding="utf-8-sig" if fresh else "utf-8") as f:
        w = csv.DictWriter(f, fieldnames=EXCLUDED_FIELDS, extrasaction="ignore")
        if fresh:
            w.writeheader()
        for e in entries:
            w.writerow({k: e.get(k, "") for k in EXCLUDED_FIELDS})


def main():
    existing, header, seen, max_id = load_existing(OUT)
    print(f"{OUT}: {len(existing)} existing row(s), "
          f"{len(seen)} known URL(s), highest id {max_id}")
    labeled = sum(1 for r in existing if (r.get("skill_ids") or "").strip())
    if labeled:
        print(f"  {labeled} already carry skill_ids -- these are preserved")

    prev_excluded = excluded_urls()
    if prev_excluded:
        seen |= prev_excluded
        print(f"  {len(prev_excluded)} previously excluded URL(s) will not be "
              f"re-fetched")

    # Ids continue past anything either file has used, so an evicted row's id
    # is never handed to a different posting.
    max_id = max(max_id, max_known_id(OUT, EXCLUDED))

    # Top up to TARGET_PER_CAREER rows per career, counting what is already
    # held. Rows sitting in the excluded file are not counted, so a career whose
    # postings were thrown out for being summaries gets refilled rather than
    # left short.
    held = {}
    for r in existing:
        held[r.get("career", "")] = held.get(r.get("career", ""), 0) + 1

    new_rows, excluded, next_id, total_skipped = [], [], max_id + 1, 0
    stamp = time.strftime("%Y-%m-%d")

    for career, query in CAREERS.items():
        have = held.get(career, 0)
        want = max(0, TARGET_PER_CAREER - have)
        if not want:
            print(f"{career}: {have} already held, nothing needed")
            continue

        print(f"{career}: have {have}, need {want} -> ", end="", flush=True)
        try:
            jobs, skipped, rejects = fetch(career, query, want, seen)
        except requests.HTTPError as e:
            print(f"FAILED ({e.response.status_code})")
            continue

        total_skipped += skipped
        for job in jobs:
            desc = job["job_description"]
            new_rows.append({
                "id": next_id,
                "career": career,
                "job_title": job.get("job_title", ""),
                "lang": detect_lang(desc),
                "posting_text": desc.replace("\n", " | ").replace("\r", ""),
                "skill_ids": "",
                "employer": job.get("employer_name", ""),
                "city": job.get("job_city", ""),
                "source": job.get("job_publisher", ""),
                "url": job.get("job_apply_link", ""),
                "onet_soc": job.get("job_onet_soc") or "",
            })
            next_id += 1

        for job, reason in rejects:
            desc = job.get("job_description") or ""
            excluded.append({
                "id": "", "career": career,
                "job_title": job.get("job_title", ""),
                "lang": detect_lang(desc),
                "posting_text": desc.replace("\n", " | ").replace("\r", ""),
                "skill_ids": "",
                "employer": job.get("employer_name", ""),
                "city": job.get("job_city", ""),
                "source": job.get("job_publisher", ""),
                "url": job.get("job_apply_link", ""),
                "onet_soc": job.get("job_onet_soc") or "",
                "excluded_reason": reason, "excluded_on": stamp,
            })

        got = len(jobs)
        print(f"{got} new{' (SHORT)' if got < want else ''}, "
              f"{skipped} already held, {len(rejects)} screened out")

    append_excluded(excluded)
    if excluded:
        print(f"\nwrote {len(excluded)} screened-out posting(s) to {EXCLUDED}")

    if not new_rows:
        print(f"\nnothing new to add; {OUT} left untouched "
              f"({total_skipped} already-held job(s) seen)")
        return

    write_atomic(OUT, header, existing + new_rows)

    langs = {}
    for r in new_rows:
        langs[r["lang"]] = langs.get(r["lang"], 0) + 1
    print(f"\nappended {len(new_rows)} row(s) to {OUT} "
          f"(now {len(existing) + len(new_rows)} total)")
    print(f"skipped {total_skipped} job(s) already present by URL")
    print(f"language split of the new rows: {langs}")
    print("\nskill_ids is blank on the new rows. Label them yourself in one pass.")


if __name__ == "__main__":
    main()
