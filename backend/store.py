"""Student profiles in SQLite -- the spec's local storage choice."""
import json
import sqlite3
import uuid
from datetime import datetime, timezone
from pathlib import Path

_COLUMNS = ("id, career, major, completed_courses, self_reported_skills, "
            "other_careers, created_at")

# Columns added after the first release, each with the default that reads an
# old row correctly: a profile saved before the column existed reported no
# skills and compared no careers.
_ADDED = {"self_reported_skills": "TEXT NOT NULL DEFAULT '[]'",
          "other_careers": "TEXT NOT NULL DEFAULT '[]'"}


class ProfileStore:

    def __init__(self, path: Path) -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._run("""CREATE TABLE IF NOT EXISTS profiles (
                         id                   TEXT PRIMARY KEY,
                         career               TEXT NOT NULL,
                         major                TEXT,
                         completed_courses    TEXT NOT NULL,
                         created_at           TEXT NOT NULL,
                         self_reported_skills TEXT NOT NULL DEFAULT '[]',
                         other_careers        TEXT NOT NULL DEFAULT '[]')""")
        columns = {row[1] for row in self._run("PRAGMA table_info(profiles)")}
        for name, declaration in _ADDED.items():
            if name not in columns:
                self._run(f"ALTER TABLE profiles ADD COLUMN {name} {declaration}")

    def _run(self, sql: str, params: tuple = ()) -> list[tuple]:
        # One short-lived connection per call: FastAPI runs sync handlers on a
        # thread pool, and a sqlite3 connection must not cross threads.
        db = sqlite3.connect(self.path)
        try:
            # TRUNCATE, not the default DELETE journal. This repo sits in a
            # OneDrive folder, which can hold a handle that permits writes but
            # refuses deletes, and a failed journal delete surfaces as a
            # "disk I/O error" on a write that otherwise succeeded.
            db.execute("PRAGMA journal_mode=TRUNCATE")
            rows = db.execute(sql, params).fetchall()
            db.commit()
            return rows
        finally:
            db.close()

    def create(self, career: str, major: str | None, courses: list[str],
               self_reported: list[str] | tuple = (),
               other_careers: list[str] | tuple = ()) -> dict:
        row = {"id": uuid.uuid4().hex, "career": career, "major": major,
               "completed_courses": courses,
               "self_reported_skills": list(self_reported),
               "other_careers": list(other_careers),
               "created_at": datetime.now(timezone.utc).isoformat(timespec="seconds")}
        self._run(f"INSERT INTO profiles ({_COLUMNS}) VALUES (?, ?, ?, ?, ?, ?, ?)",
                  (row["id"], career, major, json.dumps(courses),
                   json.dumps(row["self_reported_skills"]),
                   json.dumps(row["other_careers"]), row["created_at"]))
        return row

    def get(self, profile_id: str) -> dict | None:
        rows = self._run(f"SELECT {_COLUMNS} FROM profiles WHERE id = ?", (profile_id,))
        if not rows:
            return None
        pid, career, major, courses, skills, others, created = rows[0]
        return {"id": pid, "career": career, "major": major,
                "completed_courses": json.loads(courses),
                "self_reported_skills": json.loads(skills),
                "other_careers": json.loads(others), "created_at": created}
