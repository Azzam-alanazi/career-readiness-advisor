"""Section 7: the conceptual ER diagram, in Chen notation."""
import math

from uml import Canvas, LINE, F_ENTITY, F_RELATION, F_ATTR, text_width, INK, QUIET


class ER:
    """Records shapes and links, then draws links first so shapes sit on top."""

    def __init__(self, c: Canvas):
        self.c = c
        self.ents, self.rels, self.attrs, self.links, self.cards = {}, {}, [], [], []

    def entity(self, key, cx, cy, name):
        w = text_width(name, 13, True) + 34
        self.ents[key] = (cx, cy, w, 40, name)

    def rel(self, key, cx, cy, name):
        w = text_width(name, 11.5, True) + 50
        self.rels[key] = (cx, cy, w, 52, name)

    def attr(self, owner, cx, cy, name, key=False, derived=False):
        self.attrs.append((owner, cx, cy, name, key, derived))

    def link(self, ent, rel, card, total=False):
        self.links.append((ent, rel, card, total))

    def _center(self, k):
        return (self.ents.get(k) or self.rels[k])[:2]

    def draw(self):
        c = self.c
        for owner, cx, cy, *_ in self.attrs:
            ox, oy = self._center(owner)
            c.line(ox, oy, cx, cy, sw=1)
        for ent, rel, card, total in self.links:
            (ex, ey), (rx, ry) = self._center(ent), self._center(rel)
            if total:
                dx, dy = rx - ex, ry - ey
                n = math.hypot(dx, dy) or 1
                px, py = -dy / n * 2.2, dx / n * 2.2
                c.line(ex + px, ey + py, rx + px, ry + py, sw=1.1)
                c.line(ex - px, ey - py, rx - px, ry - py, sw=1.1)
            else:
                c.line(ex, ey, rx, ry, sw=1.3)
            # the cardinality sits just outside the entity, beside the line
            _, _, w, h, _ = self.ents[ent]
            dx, dy = rx - ex, ry - ey
            n = math.hypot(dx, dy) or 1
            ux, uy = dx / n, dy / n
            t = min((w / 2) / abs(ux) if ux else 1e9, (h / 2) / abs(uy) if uy else 1e9)
            bx, by = ex + ux * (t + 20), ey + uy * (t + 20)
            px, py = -uy * 12, ux * 12
            c.text(bx + px, by + py + 4, card, size=12, bold=True, anchor="middle",
                   fill="#8A1538", halo=True)
        for cx, cy, w, h, name in self.rels.values():
            c.relationship(cx, cy, name, w=w, h=h)
        for cx, cy, w, h, name in self.ents.values():
            c.entity(cx, cy, name, w=w, h=h)
        for owner, cx, cy, name, key, derived in self.attrs:
            c.attribute(cx, cy, name, key=key, derived=derived)


def chen() -> Canvas:
    c = Canvas(1600, 1030,
               "ER diagram: skills connect the job market, the catalog and the student",
               "Chen notation. Rectangles are entities, diamonds relationships, ovals attributes; "
               "underlined = key, dashed = derived, double line = every instance takes part.")
    e = ER(c)
    e.entity("posting", 300, 230, "JOB_POSTING")
    e.entity("career", 700, 230, "CAREER")
    e.entity("skill", 700, 560, "SKILL")
    e.entity("cat", 700, 900, "SKILL_CATEGORY")
    e.entity("course", 1250, 560, "COURSE")
    e.entity("online", 1250, 860, "ONLINE_COURSE")
    e.entity("student", 1250, 230, "STUDENT_PROFILE")

    e.rel("belongs", 500, 230, "BELONGS_TO")
    e.rel("demands", 700, 395, "DEMANDS")
    e.rel("labelled", 455, 430, "LABELLED_WITH")
    e.rel("incat", 700, 745, "IN_CATEGORY")
    e.rel("teaches", 975, 560, "TEACHES")
    e.rel("covers", 975, 860, "COVERS")
    e.rel("targets", 975, 230, "TARGETS")
    e.rel("reports", 975, 395, "REPORTS")
    e.rel("completed", 1170, 395, "COMPLETED")
    e.rel("plans", 1345, 395, "PLANS")

    e.link("posting", "belongs", "N", total=True)
    e.link("career", "belongs", "1")
    e.link("career", "demands", "M")
    e.link("skill", "demands", "N")
    e.link("posting", "labelled", "M")
    e.link("skill", "labelled", "N")
    e.link("skill", "incat", "N", total=True)
    e.link("cat", "incat", "1")
    e.link("course", "teaches", "M")
    e.link("skill", "teaches", "N")
    e.link("online", "covers", "M", total=True)
    e.link("skill", "covers", "N")
    e.link("student", "targets", "M", total=True)
    e.link("career", "targets", "N")
    e.link("student", "reports", "M")
    e.link("skill", "reports", "N")
    e.link("student", "completed", "M")
    e.link("course", "completed", "N")
    e.link("student", "plans", "M")
    e.link("course", "plans", "N")

    # job posting
    e.attr("posting", 140, 110, "id", key=True)
    e.attr("posting", 290, 100, "job_title")
    e.attr("posting", 435, 120, "employer")
    e.attr("posting", 95, 180, "city")
    e.attr("posting", 90, 245, "source")
    e.attr("posting", 105, 310, "url")
    e.attr("posting", 185, 360, "lang")
    e.attr("posting", 290, 330, "posting_text")
    e.attr("posting", 80, 410, "onet_soc")
    # career
    e.attr("career", 640, 120, "name", key=True)
    e.attr("career", 790, 120, "posting_count", derived=True)
    e.attr("demands", 840, 330, "demand_weight", derived=True)
    # skill
    e.attr("skill", 555, 625, "id", key=True)
    e.attr("skill", 540, 680, "name_en")
    e.attr("skill", 565, 735, "name_ar")
    e.attr("cat", 700, 980, "code", key=True)
    # course
    e.attr("course", 1420, 490, "course_code", key=True)
    e.attr("course", 1450, 560, "title")
    e.attr("course", 1425, 630, "track")
    e.attr("course", 1290, 660, "course_text")
    e.attr("teaches", 975, 640, "mapped_by")
    # online course
    e.attr("online", 1420, 790, "url", key=True)
    e.attr("online", 1450, 860, "provider")
    e.attr("online", 1420, 930, "title")
    e.attr("online", 1260, 960, "is_free")
    # student
    e.attr("student", 1250, 110, "device", key=True)
    e.attr("student", 1430, 160, "major")
    e.attr("student", 1450, 230, "language")
    e.attr("targets", 975, 140, "rank (1 = main)")
    e.draw()

    c.note(24, 900, ["Readiness, gaps and suggestions are not stored:",
                     "the API derives them from these entities per request.",
                     "STUDENT_PROFILE lives on the phone, one per device;",
                     "LABELLED_WITH covers the 15 evaluation postings."], w=380)
    return c


ALL = [("7_er_chen", chen)]
