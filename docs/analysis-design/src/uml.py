"""
A small SVG kit for drawing the project's UML, database and ER diagrams.

Every diagram is laid out by hand in diagrams.py: positions are explicit, so a
connector never crosses a box by accident. This file only knows how to draw
the shapes UML uses -- class boxes, actors, use cases, lifelines, activity
nodes, entities -- and how wide a line of Arial text is.
"""
from __future__ import annotations

from dataclasses import dataclass
from html import escape

FONT = "Arial, Helvetica, sans-serif"
INK = "#1F2328"
QUIET = "#57606A"
LINE = "#3D444D"

# Fills, one per kind of shape, so the same kind always looks the same.
F_CLASS_HEAD = "#E7EEF9"
F_CLASS_BODY = "#FFFFFF"
F_INTERFACE = "#EAF5EA"
F_ENUM = "#FFF4E0"
F_USECASE = "#FFF7DD"
F_ACTION = "#E9F4EC"
F_DECISION = "#FFF1DD"
F_NOTE = "#FFFBE6"
F_LIFELINE = "#E7EEF9"
F_ENTITY = "#E7EEF9"
F_RELATION = "#FBE7EE"
F_ATTR = "#FFFFFF"
F_COMPONENT = "#EEEAF7"
F_NODE = "#ECEFF2"
F_PACKAGE = "#F6F8FA"
F_EXTERNAL = "#F3F3F3"
F_STORE = "#FFF7DD"

# Helvetica/Arial advance widths, per 1000 units of the em.
_W = {
    " ": 278, "!": 278, '"': 355, "#": 556, "$": 556, "%": 889, "&": 667, "'": 191,
    "(": 333, ")": 333, "*": 389, "+": 584, ",": 278, "-": 333, ".": 278, "/": 278,
    ":": 278, ";": 278, "<": 584, "=": 584, ">": 584, "?": 556, "@": 1015, "[": 278,
    "\\": 278, "]": 278, "^": 469, "_": 556, "`": 333, "{": 334, "|": 260, "}": 334,
    "~": 584, "«": 556, "»": 556, "·": 278, "–": 556, "—": 1000, "…": 1000, "→": 1000,
    "←": 1000, "↔": 1000, "≥": 549, "≤": 549, "×": 584, "∪": 768, "Σ": 711, "∑": 711,
    "’": 222, "“": 333, "”": 333, "…": 1000, "✓": 800, "°": 400, "/": 278,
}
for ch, w in zip("abcdefghijklmnopqrstuvwxyz",
                 [556, 556, 500, 556, 556, 278, 556, 556, 222, 222, 500, 222, 833,
                  556, 556, 556, 556, 333, 500, 278, 556, 500, 722, 500, 500, 500]):
    _W[ch] = w
for ch, w in zip("ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                 [667, 667, 722, 722, 667, 611, 778, 722, 278, 500, 667, 556, 833,
                  722, 778, 667, 778, 722, 667, 611, 722, 667, 944, 667, 667, 611]):
    _W[ch] = w
for ch in "0123456789":
    _W[ch] = 556


def text_width(s: str, size: float = 12, bold: bool = False) -> float:
    w = sum(_W.get(ch, 600) for ch in s) * size / 1000
    return w * (1.07 if bold else 1.0)


def esc(s: str) -> str:
    return escape(s, quote=True)


@dataclass
class Box:
    x: float
    y: float
    w: float
    h: float

    @property
    def cx(self) -> float:
        return self.x + self.w / 2

    @property
    def cy(self) -> float:
        return self.y + self.h / 2

    @property
    def right(self) -> float:
        return self.x + self.w

    @property
    def bottom(self) -> float:
        return self.y + self.h

    def top_at(self, t: float = 0.5) -> tuple[float, float]:
        return (self.x + self.w * t, self.y)

    def bottom_at(self, t: float = 0.5) -> tuple[float, float]:
        return (self.x + self.w * t, self.bottom)

    def left_at(self, t: float = 0.5) -> tuple[float, float]:
        return (self.x, self.y + self.h * t)

    def right_at(self, t: float = 0.5) -> tuple[float, float]:
        return (self.right, self.y + self.h * t)


MARKERS = """
<marker id="open" viewBox="0 0 12 12" refX="11" refY="6" markerWidth="12" markerHeight="12"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <path d="M1 1 L11 6 L1 11" fill="none" stroke="{line}" stroke-width="1.3"/>
</marker>
<marker id="filled" viewBox="0 0 12 12" refX="11" refY="6" markerWidth="11" markerHeight="11"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <path d="M0 1 L11 6 L0 11 z" fill="{line}"/>
</marker>
<marker id="hollow" viewBox="0 0 16 16" refX="15" refY="8" markerWidth="16" markerHeight="16"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <path d="M1 1 L15 8 L1 15 z" fill="#fff" stroke="{line}" stroke-width="1.3"/>
</marker>
<marker id="diamond" viewBox="0 0 22 12" refX="21" refY="6" markerWidth="22" markerHeight="12"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <path d="M1 6 L11 1 L21 6 L11 11 z" fill="{line}" stroke="{line}" stroke-width="1"/>
</marker>
<marker id="odiamond" viewBox="0 0 22 12" refX="21" refY="6" markerWidth="22" markerHeight="12"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <path d="M1 6 L11 1 L21 6 L11 11 z" fill="#fff" stroke="{line}" stroke-width="1.2"/>
</marker>
<marker id="cf-many" viewBox="0 0 20 16" refX="19" refY="8" markerWidth="20" markerHeight="16"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <path d="M19 1 L5 8 L19 15 M5 8 L19 8 M3 2 L3 14" fill="none" stroke="{line}" stroke-width="1.3"/>
</marker>
<marker id="cf-zmany" viewBox="0 0 26 16" refX="25" refY="8" markerWidth="26" markerHeight="16"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <circle cx="6" cy="8" r="4" fill="#fff" stroke="{line}" stroke-width="1.3"/>
  <path d="M25 1 L12 8 L25 15 M10 8 L25 8" fill="none" stroke="{line}" stroke-width="1.3"/>
</marker>
<marker id="cf-one" viewBox="0 0 20 16" refX="19" refY="8" markerWidth="20" markerHeight="16"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <path d="M8 2 L8 14 M13 2 L13 14 M0 8 L19 8" fill="none" stroke="{line}" stroke-width="1.3"/>
</marker>
<marker id="cf-zone" viewBox="0 0 24 16" refX="23" refY="8" markerWidth="24" markerHeight="16"
        markerUnits="userSpaceOnUse" orient="auto-start-reverse">
  <circle cx="7" cy="8" r="4" fill="#fff" stroke="{line}" stroke-width="1.3"/>
  <path d="M16 2 L16 14 M11 8 L23 8" fill="none" stroke="{line}" stroke-width="1.3"/>
</marker>
""".format(line=LINE)


class Canvas:
    def __init__(self, w: float, h: float, title: str | None = None,
                 subtitle: str | None = None) -> None:
        self.w, self.h = w, h
        self.items: list[str] = []
        self.title, self.subtitle = title, subtitle
        if title:
            self.text(24, 34, title, size=17, bold=True)
        if subtitle:
            self.text(24, 56, subtitle, size=12.5, fill=QUIET)

    # ---- raw shapes ---------------------------------------------------------

    def add(self, s: str) -> None:
        self.items.append(s)

    def text(self, x, y, s, size=12, bold=False, italic=False, anchor="start",
             fill=INK, underline=False, dashed_underline=False, rotate=None,
             halo=False) -> None:
        style = []
        if halo:
            style.append('stroke="#FFFFFF" stroke-width="4" stroke-linejoin="round" '
                         'paint-order="stroke"')
        if rotate is not None:
            style.append(f'transform="rotate({rotate} {x:.1f} {y:.1f})"')
        if bold:
            style.append('font-weight="bold"')
        if italic:
            style.append('font-style="italic"')
        if underline:
            style.append('text-decoration="underline"')
        self.add(f'<text x="{x:.1f}" y="{y:.1f}" font-size="{size}" text-anchor="{anchor}" '
                 f'fill="{fill}" {" ".join(style)}>{esc(s)}</text>')
        if dashed_underline:
            w = text_width(s, size, bold)
            x0 = x - w / 2 if anchor == "middle" else (x - w if anchor == "end" else x)
            self.add(f'<line x1="{x0:.1f}" y1="{y + 2:.1f}" x2="{x0 + w:.1f}" y2="{y + 2:.1f}" '
                     f'stroke="{fill}" stroke-width="1" stroke-dasharray="3 2"/>')

    def lines(self, x, y, lines, size=12, lh=None, anchor="start", bold=False,
              italic=False, fill=INK) -> None:
        lh = lh or size * 1.35
        for i, s in enumerate(lines):
            self.text(x, y + i * lh, s, size=size, anchor=anchor, bold=bold,
                      italic=italic, fill=fill)

    def rect(self, x, y, w, h, fill="#fff", stroke=LINE, rx=0, dash=None, sw=1.2,
             opacity=None) -> Box:
        d = f' stroke-dasharray="{dash}"' if dash else ""
        o = f' fill-opacity="{opacity}"' if opacity is not None else ""
        self.add(f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{rx}" '
                 f'fill="{fill}"{o} stroke="{stroke}" stroke-width="{sw}"{d}/>')
        return Box(x, y, w, h)

    def line(self, x1, y1, x2, y2, stroke=LINE, sw=1.2, dash=None) -> None:
        d = f' stroke-dasharray="{dash}"' if dash else ""
        self.add(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
                 f'stroke="{stroke}" stroke-width="{sw}"{d}/>')

    def path(self, pts, end=None, start=None, dash=None, sw=1.2, stroke=LINE,
             label=None, label_at=None, label_anchor="middle", label_dy=-6,
             label_size=11, label_fill=QUIET) -> None:
        """A connector through pts, with optional UML ends and a label."""
        d = "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts)
        attrs = [f'd="{d}"', 'fill="none"', f'stroke="{stroke}"', f'stroke-width="{sw}"']
        if dash:
            attrs.append(f'stroke-dasharray="{dash}"')
        if end:
            attrs.append(f'marker-end="url(#{end})"')
        if start:
            attrs.append(f'marker-start="url(#{start})"')
        self.add(f'<path {" ".join(attrs)}/>')
        if label:
            if label_at is None:
                (x1, y1), (x2, y2) = pts[len(pts) // 2 - 1], pts[len(pts) // 2]
                label_at = ((x1 + x2) / 2, (y1 + y2) / 2)
            lx, ly = label_at
            for i, s in enumerate(label if isinstance(label, list) else [label]):
                self.text(lx, ly + label_dy + i * (label_size + 3), s, size=label_size,
                          anchor=label_anchor, fill=label_fill, italic=False)

    # ---- notes and frames ---------------------------------------------------

    def note(self, x, y, lines, w=None, size=11.5, fill=F_NOTE) -> Box:
        w = w or max(text_width(s, size) for s in lines) + 24
        h = len(lines) * (size + 4) + 14
        f = 10
        self.add(f'<path d="M{x} {y} H{x + w - f} L{x + w} {y + f} V{y + h} H{x} Z" '
                 f'fill="{fill}" stroke="{LINE}" stroke-width="1"/>')
        self.add(f'<path d="M{x + w - f} {y} V{y + f} H{x + w}" fill="none" '
                 f'stroke="{LINE}" stroke-width="1"/>')
        self.lines(x + 10, y + size + 6, lines, size=size, lh=size + 4)
        return Box(x, y, w, h)

    def frame(self, x, y, w, h, tag, title=None, fill="none", labels=True) -> Box:
        """A UML frame (sd, act, alt, opt, loop...) with its pentagon tag."""
        self.rect(x, y, w, h, fill=fill, stroke=LINE, sw=1.1)
        if labels:
            self.frame_tag(x, y, tag, title)
        return Box(x, y, w, h)

    def frame_tag(self, x, y, tag, title=None) -> None:
        tw = text_width(tag, 11.5, True) + 16
        self.add(f'<path d="M{x} {y} H{x + tw} V{y + 12} L{x + tw - 8} {y + 20} H{x} Z" '
                 f'fill="#F3F4F6" stroke="{LINE}" stroke-width="1.1"/>')
        self.text(x + 7, y + 14.5, tag, size=11.5, bold=True)
        if title:
            self.text(x + tw + 8, y + 14.5, title, size=11.5, fill=QUIET, halo=True)

    def package(self, x, y, w, h, name, stereo=None, fill=F_PACKAGE) -> Box:
        tab_w = max(text_width(name, 12.5, True) + 20, 70)
        self.add(f'<path d="M{x} {y + 22} V{y} H{x + tab_w} V{y + 22}" fill="{fill}" '
                 f'stroke="{LINE}" stroke-width="1.2"/>')
        self.rect(x, y + 22, w, h - 22, fill=fill)
        self.text(x + 10, y + 16, name, size=12.5, bold=True)
        if stereo:
            self.text(x + w - 10, y + 40, stereo, size=11, italic=True, anchor="end", fill=QUIET)
        return Box(x, y + 22, w, h - 22)

    # ---- class diagrams -----------------------------------------------------

    def class_box(self, x, y, name, attrs=(), ops=(), stereo=None, w=None,
                  head_fill=F_CLASS_HEAD, italic_name=False, size=11.5) -> Box:
        lh = size + 4.5
        name_w = text_width(name, 13, True)
        content = list(attrs) + list(ops)
        w = w or max([name_w + 28] + [text_width(s, size) + 18 for s in content]
                     + ([text_width(stereo, 11) + 20] if stereo else []))
        head_h = 26 + (14 if stereo else 0)
        a_h = (len(attrs) * lh + 8) if attrs else 10
        o_h = (len(ops) * lh + 8) if ops else (10 if attrs or not ops else 0)
        if not attrs and not ops:
            a_h, o_h = 0, 0
        h = head_h + a_h + o_h
        self.rect(x, y, w, h, fill=F_CLASS_BODY)
        self.rect(x, y, w, head_h, fill=head_fill)
        ty = y + 17
        if stereo:
            self.text(x + w / 2, ty, stereo, size=11, anchor="middle", fill=QUIET)
            ty += 14
        self.text(x + w / 2, ty + 1, name, size=13, bold=True, anchor="middle",
                  italic=italic_name)
        cy = y + head_h
        if attrs or ops:
            self.lines(x + 8, cy + lh, attrs, size=size, lh=lh)
            cy += a_h
            self.line(x, cy, x + w, cy, sw=1)
            self.lines(x + 8, cy + lh, ops, size=size, lh=lh)
        return Box(x, y, w, h)

    # ---- use cases ----------------------------------------------------------

    def actor(self, cx, y, name, lines=None, size=12) -> Box:
        """A stick figure whose head top is at y; returns its bounding box."""
        s = LINE
        self.add(f'<circle cx="{cx}" cy="{y + 9}" r="9" fill="#fff" stroke="{s}" stroke-width="1.4"/>')
        self.line(cx, y + 18, cx, y + 44, stroke=s, sw=1.4)
        self.line(cx - 16, y + 27, cx + 16, y + 27, stroke=s, sw=1.4)
        self.line(cx, y + 44, cx - 13, y + 62, stroke=s, sw=1.4)
        self.line(cx, y + 44, cx + 13, y + 62, stroke=s, sw=1.4)
        names = lines or [name]
        self.lines(cx, y + 78, names, size=size, anchor="middle", bold=True, lh=size + 3)
        return Box(cx - 18, y, 36, 62)

    def system_actor(self, x, y, name_lines, w=None) -> Box:
        """A non-human actor: a box with the «system» keyword."""
        w = w or max(text_width(s, 12, True) for s in name_lines) + 28
        h = 22 + len(name_lines) * 15 + 10
        self.rect(x, y, w, h, fill=F_EXTERNAL, rx=4)
        self.text(x + w / 2, y + 16, "«system»", size=11, anchor="middle", fill=QUIET)
        self.lines(x + w / 2, y + 33, name_lines, size=12, bold=True, anchor="middle", lh=15)
        return Box(x, y, w, h)

    def usecase(self, cx, cy, lines, w=None, h=None, size=12, fill=F_USECASE,
                bold_first=False) -> Box:
        tw = max(text_width(s, size, bold_first and i == 0) for i, s in enumerate(lines))
        w = w or tw * 1.18 + 34
        h = h or len(lines) * (size + 3) + 26
        self.add(f'<ellipse cx="{cx}" cy="{cy}" rx="{w / 2:.1f}" ry="{h / 2:.1f}" '
                 f'fill="{fill}" stroke="{LINE}" stroke-width="1.2"/>')
        y0 = cy - (len(lines) - 1) * (size + 3) / 2 + size / 3
        for i, s in enumerate(lines):
            self.text(cx, y0 + i * (size + 3), s, size=size, anchor="middle",
                      bold=bold_first and i == 0)
        return Box(cx - w / 2, cy - h / 2, w, h)

    # ---- activity diagrams --------------------------------------------------

    def start(self, cx, cy) -> Box:
        self.add(f'<circle cx="{cx}" cy="{cy}" r="9" fill="{INK}"/>')
        return Box(cx - 9, cy - 9, 18, 18)

    def end(self, cx, cy) -> Box:
        self.add(f'<circle cx="{cx}" cy="{cy}" r="11" fill="#fff" stroke="{INK}" stroke-width="1.4"/>')
        self.add(f'<circle cx="{cx}" cy="{cy}" r="6.5" fill="{INK}"/>')
        return Box(cx - 11, cy - 11, 22, 22)

    def flow_end(self, cx, cy) -> Box:
        self.add(f'<circle cx="{cx}" cy="{cy}" r="9" fill="#fff" stroke="{INK}" stroke-width="1.4"/>')
        self.line(cx - 6, cy - 6, cx + 6, cy + 6, stroke=INK, sw=1.4)
        self.line(cx - 6, cy + 6, cx + 6, cy - 6, stroke=INK, sw=1.4)
        return Box(cx - 9, cy - 9, 18, 18)

    def action(self, cx, cy, lines, w=None, size=12, fill=F_ACTION, bold=False) -> Box:
        if isinstance(lines, str):
            lines = [lines]
        w = w or max(text_width(s, size, bold) for s in lines) + 28
        h = len(lines) * (size + 3.5) + 18
        x, y = cx - w / 2, cy - h / 2
        self.rect(x, y, w, h, fill=fill, rx=12)
        y0 = cy - (len(lines) - 1) * (size + 3.5) / 2 + size / 3
        for i, s in enumerate(lines):
            self.text(cx, y0 + i * (size + 3.5), s, size=size, anchor="middle", bold=bold)
        return Box(x, y, w, h)

    def decision(self, cx, cy, w=34, h=34, label=None) -> Box:
        self.add(f'<path d="M{cx} {cy - h / 2} L{cx + w / 2} {cy} L{cx} {cy + h / 2} '
                 f'L{cx - w / 2} {cy} Z" fill="{F_DECISION}" stroke="{LINE}" stroke-width="1.2"/>')
        if label:
            self.text(cx + w / 2 + 6, cy - h / 2 + 2, label, size=11, fill=QUIET)
        return Box(cx - w / 2, cy - h / 2, w, h)

    def bar(self, cx, cy, w=160, vertical=False) -> Box:
        if vertical:
            self.rect(cx - 3, cy - w / 2, 6, w, fill=INK, stroke=INK, sw=0)
            return Box(cx - 3, cy - w / 2, 6, w)
        self.rect(cx - w / 2, cy - 3, w, 6, fill=INK, stroke=INK, sw=0)
        return Box(cx - w / 2, cy - 3, w, 6)

    def lanes(self, x, y, widths, h, titles, head=30) -> list[float]:
        """Swimlanes side by side; returns each lane's centre x."""
        centres = []
        cx = x
        for w, t in zip(widths, titles):
            self.rect(cx, y, w, h, fill="none", sw=1.2)
            self.rect(cx, y, w, head, fill="#F3F4F6", sw=1.2)
            self.text(cx + w / 2, y + 20, t, size=13, bold=True, anchor="middle")
            centres.append(cx + w / 2)
            cx += w
        return centres

    def guard(self, x, y, s, anchor="start") -> None:
        self.text(x, y, s, size=11, fill=QUIET, anchor=anchor)

    # ---- sequence diagrams --------------------------------------------------

    def lifeline_head(self, cx, y, lines, kind="object", w=None, size=11.5) -> Box:
        if kind == "actor":
            self.actor(cx, y - 4, lines[0], lines=lines, size=11.5)
            return Box(cx - 40, y, 80, 92)
        w = w or max(text_width(s, size, i == 0) for i, s in enumerate(lines)) + 20
        h = len(lines) * (size + 3) + 14
        fill = F_LIFELINE if kind == "object" else F_EXTERNAL
        self.rect(cx - w / 2, y, w, h, fill=fill, rx=3)
        for i, s in enumerate(lines):
            self.text(cx, y + 17 + i * (size + 3), s, size=size if i == 0 else size - 1,
                      anchor="middle", bold=(i == 0), fill=INK if i == 0 else QUIET)
        return Box(cx - w / 2, y, w, h)

    def activation(self, cx, y1, y2, depth=0) -> None:
        x = cx - 5 + depth * 6
        self.rect(x, y1, 10, y2 - y1, fill="#FFFFFF", sw=1.1)

    def message(self, x1, x2, y, label, kind="sync", size=11, label_lines=None) -> None:
        """sync: filled head; async: open head; reply: dashed + open head."""
        if kind == "reply":
            self.path([(x1, y), (x2, y)], end="open", dash="5 4")
        elif kind == "async":
            self.path([(x1, y), (x2, y)], end="open")
        elif kind == "create":
            self.path([(x1, y), (x2, y)], end="open", dash="5 4")
        else:
            self.path([(x1, y), (x2, y)], end="filled")
        labels = label_lines or [label]
        mid = (x1 + x2) / 2
        for i, s in enumerate(reversed(labels)):
            self.text(mid, y - 5 - i * (size + 2), s, size=size, anchor="middle",
                      fill=INK if kind != "reply" else QUIET, halo=True)

    def self_message(self, cx, y, label, h=22, w=26, size=11, label_lines=None,
                     left=False) -> None:
        self.path([(cx + 5, y), (cx + 5 + w, y), (cx + 5 + w, y + h), (cx + 10, y + h)],
                  end="filled")
        labels = label_lines or [label]
        for i, s in enumerate(labels):
            if left:
                self.text(cx - 10, y + 4 + i * (size + 2), s, size=size, anchor="end", halo=True)
            else:
                self.text(cx + 5 + w + 6, y + 4 + i * (size + 2), s, size=size, halo=True)

    # ---- data models --------------------------------------------------------

    def table(self, x, y, name, rows, subtitle=None, w=None, size=11.5,
              head_fill=F_ENTITY) -> Box:
        """
        A store drawn as a table. rows = (key, column, note): key is 'PK', 'FK',
        'PK FK', 'UQ' or ''.
        """
        lh = size + 6
        key_w = 34
        w = w or max([text_width(name, 13, True) + 24]
                     + ([text_width(subtitle, 11) + 24] if subtitle else [])
                     + [key_w + text_width(c, size, k.startswith("PK")) +
                        (text_width(n, 10.5) + 14 if n else 0) + 20 for k, c, n in rows])
        head_h = 26 + (14 if subtitle else 0)
        h = head_h + len(rows) * lh + 8
        self.rect(x, y, w, h, fill="#fff")
        self.rect(x, y, w, head_h, fill=head_fill)
        self.text(x + w / 2, y + 18, name, size=13, bold=True, anchor="middle")
        if subtitle:
            self.text(x + w / 2, y + 33, subtitle, size=10.5, anchor="middle", fill=QUIET)
        self.line(x + key_w, y + head_h, x + key_w, y + h, sw=0.8)
        for i, (k, c, n) in enumerate(rows):
            ry = y + head_h + 4 + (i + 1) * lh - 5
            if k:
                self.text(x + key_w / 2, ry, k, size=9.5, bold=True, anchor="middle",
                          fill="#8A5300" if "PK" in k else QUIET)
            self.text(x + key_w + 8, ry, c, size=size, bold=k.startswith("PK"),
                      underline=k.startswith("PK"))
            if n:
                self.text(x + w - 8, ry, n, size=10.5, anchor="end", fill=QUIET)
        return Box(x, y, w, h)

    def entity(self, cx, cy, name, w=None, h=40, weak=False) -> Box:
        w = w or text_width(name, 13, True) + 34
        x, y = cx - w / 2, cy - h / 2
        self.rect(x, y, w, h, fill=F_ENTITY, sw=1.4)
        if weak:
            self.rect(x + 4, y + 4, w - 8, h - 8, fill="none", sw=1.1)
        self.text(cx, cy + 4.5, name, size=13, bold=True, anchor="middle")
        return Box(x, y, w, h)

    def relationship(self, cx, cy, name, w=None, h=50) -> Box:
        w = w or text_width(name, 11.5, True) + 46
        self.add(f'<path d="M{cx} {cy - h / 2} L{cx + w / 2} {cy} L{cx} {cy + h / 2} '
                 f'L{cx - w / 2} {cy} Z" fill="{F_RELATION}" stroke="{LINE}" stroke-width="1.3"/>')
        self.text(cx, cy + 4, name, size=11.5, bold=True, anchor="middle")
        return Box(cx - w / 2, cy - h / 2, w, h)

    def attribute(self, cx, cy, name, key=False, derived=False, multi=False,
                  partial=False, size=11) -> Box:
        w = text_width(name, size, key) + 22
        h = 24
        dash = ' stroke-dasharray="4 3"' if derived else ""
        self.add(f'<ellipse cx="{cx}" cy="{cy}" rx="{w / 2:.1f}" ry="{h / 2}" fill="{F_ATTR}" '
                 f'stroke="{LINE}" stroke-width="1.1"{dash}/>')
        if multi:
            self.add(f'<ellipse cx="{cx}" cy="{cy}" rx="{w / 2 - 3:.1f}" ry="{h / 2 - 3}" '
                     f'fill="none" stroke="{LINE}" stroke-width="0.9"/>')
        self.text(cx, cy + 4, name, size=size, anchor="middle", bold=key,
                  underline=key and not partial, dashed_underline=partial)
        return Box(cx - w / 2, cy - h / 2, w, h)

    # ---- architecture -------------------------------------------------------

    def component(self, x, y, w, name_lines, body=(), stereo="«component»",
                  fill=F_COMPONENT, size=11) -> Box:
        h = 22 + (14 if stereo else 0) + len(name_lines) * 15 + (len(body) * (size + 4) + 8 if body else 0) + 6
        self.rect(x, y, w, h, fill=fill, rx=3)
        # the UML component icon, top right
        ix, iy = x + w - 24, y + 8
        self.rect(ix, iy, 16, 18, fill="#fff", sw=1)
        self.rect(ix - 4, iy + 3, 8, 4, fill="#fff", sw=1)
        self.rect(ix - 4, iy + 11, 8, 4, fill="#fff", sw=1)
        ty = y + 18
        if stereo:
            self.text(x + 10, ty, stereo, size=10.5, fill=QUIET)
            ty += 15
        self.lines(x + 10, ty + 1, name_lines, size=12.5, bold=True, lh=15)
        ty += len(name_lines) * 15
        if body:
            self.line(x, ty - 6, x + w, ty - 6, sw=0.8)
            self.lines(x + 10, ty + size + 2, body, size=size, lh=size + 4, fill=INK)
        return Box(x, y, w, h)

    def node(self, x, y, w, h, name_lines, stereo=None, depth=12, fill=F_NODE) -> Box:
        d = depth
        self.add(f'<path d="M{x} {y + d} L{x + d} {y} H{x + w + d} V{y + h - d} L{x + w} {y + h}" '
                 f'fill="{fill}" stroke="{LINE}" stroke-width="1.2"/>')
        self.add(f'<path d="M{x + w} {y + d} L{x + w + d} {y}" fill="none" stroke="{LINE}" stroke-width="1.2"/>')
        self.rect(x, y + d, w, h - d, fill=fill)
        ty = y + d + 18
        if stereo:
            self.text(x + 10, ty, stereo, size=10.5, fill=QUIET)
            ty += 15
        self.lines(x + 10, ty, name_lines, size=13, bold=True, lh=16)
        return Box(x, y + d, w, h - d)

    def artifact(self, x, y, w, name_lines, body=(), stereo="«artifact»", size=10.5,
                 fill="#FFFFFF") -> Box:
        h = 20 + len(name_lines) * 14 + (len(body) * (size + 3.5) + 6 if body else 0) + 8
        self.rect(x, y, w, h, fill=fill, rx=2)
        # the document icon
        ix, iy = x + w - 20, y + 6
        self.add(f'<path d="M{ix} {iy} H{ix + 9} L{ix + 13} {iy + 4} V{iy + 16} H{ix} Z" '
                 f'fill="#fff" stroke="{LINE}" stroke-width="0.9"/>')
        self.add(f'<path d="M{ix + 9} {iy} V{iy + 4} H{ix + 13}" fill="none" stroke="{LINE}" stroke-width="0.9"/>')
        self.text(x + 8, y + 15, stereo, size=10, fill=QUIET)
        self.lines(x + 8, y + 30, name_lines, size=11.5, bold=True, lh=14)
        if body:
            self.lines(x + 8, y + 30 + len(name_lines) * 14 + 2, body, size=size,
                       lh=size + 3.5, fill=INK)
        return Box(x, y, w, h)

    def lollipop(self, x, y, label, direction="left", size=11) -> tuple[float, float]:
        """A provided interface: a ball on a stick sticking out of (x, y)."""
        dx = -26 if direction == "left" else 26
        self.line(x, y, x + dx, y, sw=1.2)
        bx = x + dx + (-7 if direction == "left" else 7)
        self.add(f'<circle cx="{bx}" cy="{y}" r="7" fill="#fff" stroke="{LINE}" stroke-width="1.3"/>')
        self.text(bx, y - 12, label, size=size, anchor="middle", fill=INK)
        return (bx + (-7 if direction == "left" else 7), y)

    # ---- output -------------------------------------------------------------

    def svg(self) -> str:
        return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.w}" height="{self.h}" '
                f'viewBox="0 0 {self.w} {self.h}" font-family="{FONT}">\n'
                f'<defs>{MARKERS}</defs>\n'
                f'<rect width="{self.w}" height="{self.h}" fill="#FFFFFF"/>\n'
                + "\n".join(self.items) + "\n</svg>\n")

    def save(self, path) -> None:
        with open(path, "w", encoding="utf-8") as f:
            f.write(self.svg())
