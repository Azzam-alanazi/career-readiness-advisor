"""
End-to-end demo with the real multilingual embedding model.

First run downloads ~1GB of model weights. After that it works offline.
"""

from skillgap import (Embedder, Taxonomy, build_career_profile,
                      skills_from_courses, analyze_gap, recommend,
                      load_match_params)

# Matching parameters come from config.json, which validate.py writes after
# comparing both matching methods against each labeled set. Run validate.py
# first -- there are no defaults to fall back on. Postings and course text get
# separate parameters because they are different kinds of text.
POSTING_PARAMS = load_match_params("postings")
COURSE_PARAMS = load_match_params("courses")
if not POSTING_PARAMS["gate_passed"]:
    print(f"NOTE: the matcher FAILED its validation gate (best F1 "
          f"{POSTING_PARAMS['best_f1']}).")
    print("      The figures below are best-measured output, not validated output.")
if not COURSE_PARAMS["validated"]:
    print("NOTE: course parameters are inherited from postings, not measured.")
    print("      Label labeled_courses.csv and re-run validate.py.")

# multilingual-e5-base handles Arabic and English in one shared vector space,
# so an Arabic posting can match an English skill label directly.
embedder = Embedder("intfloat/multilingual-e5-base")
tax = Taxonomy("taxonomy.json", embedder)

# --- market side: real postings you collected -----------------------------
# Mixed language on purpose, to show cross-lingual matching working.
postings = [
    """Business Analyst - Riyadh
    Gather and document business requirements from stakeholders.
    Strong SQL skills for querying databases and building reports.
    Experience with Power BI dashboards is a plus.
    Excellent communication and presentation abilities.""",

    """محلل أعمال - جدة
    جمع وتحليل متطلبات العمل من أصحاب المصلحة.
    خبرة في قواعد البيانات والاستعلامات.
    مهارات تواصل وعرض ممتازة.
    إجادة اللغة الإنجليزية.""",

    """Business Analyst
    Document business processes and produce BPMN process models.
    Analytical thinking and structured problem solving required.
    Work with SQL databases and reporting tools.""",
]

profile = build_career_profile("Business Analyst", postings, tax, POSTING_PARAMS)
print(f"\n=== Market demand ({profile.posting_count} postings) ===")
for sid, w in profile.top():
    print(f"  {tax.name(sid):<45} {w:>5.0%} of postings")

# --- academic side: your department's course catalog ----------------------
courses = {
    "Database Systems": ["Relational database design, SQL querying, normalization."],
    "Systems Analysis and Design": ["Requirements elicitation, business analysis, system modeling."],
    "Business Intelligence": ["Data warehousing, dashboards, Power BI reporting."],
    "Business Process Management": ["Process modeling with BPMN, workflow analysis."],
    "Technical Writing": ["Professional communication, presentations, report writing."],
}
catalog = {n: sorted(skills_from_courses(d, tax, COURSE_PARAMS)) for n, d in courses.items()}

# --- student -------------------------------------------------------------
completed = ["Database Systems", "Systems Analysis and Design"]
acquired = {s for c in completed for s in catalog[c]}

gap = analyze_gap(profile, acquired, min_demand=0.15)
print(f"\n=== Readiness: {gap.readiness:.0%} for {gap.career} ===")
print("\nYou have:")
for sid, w in gap.covered:
    print(f"  + {tax.name(sid)}")
print("\nYou're missing:")
for sid, w in gap.missing:
    print(f"  - {tax.name(sid):<45} (in {w:.0%} of postings)")

print("\n=== Recommended next ===")
for r in recommend(gap, catalog, tax):
    print(f"  {r['course']}")
    for c in r["closes"]:
        print(f"      closes: {c}")
