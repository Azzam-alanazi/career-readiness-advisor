# Project analysis and design

The UML, database and ER diagrams for the Career Readiness Advisor, drawn from
the code and data as they stood on 17 October 2026.

- `APPLICATION_PROGRAMMING_UML.pdf` and `Project_Analysis_and_Design.docx`: the submission document, 28
  pages, every diagram with a short explanation, the use case descriptions and
  the data-store and relationship tables.
- `png/`: each diagram at twice its drawn size, for pasting into another report.
- `svg/`: the same diagrams as vector files; they scale without blurring.
- `src/`: the scripts that draw them.

| # | Diagram | File |
|---|---|---|
| 1a–1c | Component, deployment, package | `1a_component`, `1b_deployment`, `1c_packages` |
| 2a–2b | Use case: app users; researcher | `2a_usecase_app`, `2b_usecase_data` |
| 3a–3d | Activity: journey, POST /gap, start-up, planning | `3a_…` to `3d_…` |
| 4a–4f | Sequence: onboarding, readiness, suggestions, planning, department, start-up | `4a_…` to `4f_…` |
| 5 | Database (the data stores) | `5_database_stores` |
| 6a–6e | Class: engine, service, API objects, app domain, app layers | `6a_…` to `6e_…` |
| 7 | ER, Chen notation | `7_er_chen` |

## Redrawing

From `src/`, with Python and the Edge browser that ships with Windows:

```bash
python build.py
```

```bash
python build_docx.py
```

`build.py` writes `svg/` and `png/` (pass part of a name, such as `4b`, to draw
only those). `build_docx.py` assembles the Word file from `png/`. To make the PDF,
open the Word file and save it as PDF.

Every position is set by hand in the `d*.py` files, so a change to a diagram is
a change to its coordinates there.
