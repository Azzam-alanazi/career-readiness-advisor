"""Student profiles in SQLite -- the spec's local storage choice."""
import json
import sqlite3
import uuid
from datetime import datetime, timezone
from pathlib import Path


class ProfileStore:

    def __init__(self, path: Path) -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._run("""CREATE TABLE IF NOT EXISTS profiles (
                         id                TEXT PRIMARY KEY,
                         career            TEXT NOT NULL,
                         major             TEXT,
                         completed_courses TEXT NOT NULL,
                         created_at        TEXT NOT NULL)""")

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

    def create(self, career: str, major: str | None, courses: list[str]) -> dict:
        row = {"id": uuid.uuid4().hex, "career": career, "major": major,
               "completed_courses": courses,
               "created_at": datetime.now(timezone.utc).isoformat(timespec="seconds")}
        self._run("INSERT INTO profiles VALUES (?, ?, ?, ?, ?)",
                  (row["id"], career, major, json.dumps(courses), row["created_at"]))
        return row

    def get(self, profile_id: str) -> dict | None:
        rows = self._run("SELECT id, career, major, completed_courses, created_at "
                         "FROM profiles WHERE id = ?", (profile_id,))
        if not rows:
            return None
        pid, career, major, courses, created = rows[0]
        return {"id": pid, "career": career, "major": major,
                "completed_courses": json.loads(courses), "created_at": created}
