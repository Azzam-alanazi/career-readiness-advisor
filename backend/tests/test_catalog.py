"""The catalog as the app shows it: each course's track, for display only."""
from backend.tests.world import COURSES, write_world


def test_courses_carry_their_catalog_track_and_the_same_skills(make_client, tmp_path):
    # Tracks on three courses, none on the fourth. Nothing else differs from the
    # default world, so every course keeps the skills extraction gives it there.
    tracked = [(*COURSES[0], "", "core"), (*COURSES[1], "", "college"), COURSES[2],
               (*COURSES[3], "", "elective_analytics")]
    with make_client(write_world(tmp_path / "tracked", courses=tracked)) as c:
        got = {x["code"]: (x["track"], x["skills"]) for x in c.get("/courses").json()}
    assert got == {"IS230": ("core", ["SQ"]), "BUS210": ("college", ["CM"]),
                   "IS210": ("", ["PY"]), "IS320": ("elective_analytics", ["ER"])}
