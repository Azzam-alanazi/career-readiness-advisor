# Archive

## `labeled_postings_starter19.csv`

The original hand-labeled set: 3 Business Analyst postings (one Arabic) plus 22
blank scaffold rows, labelled against the **19-entry starter taxonomy**.

Every F1 figure recorded for Phase 0 up to 2026-09-05 was measured on these
three rows — including the 0.900 in `config.json`. Kept for that reason: the
numbers in the evaluation chapter are not reproducible without it.

It is **not** live input. Its `skill_ids` (`sql`, `requirements`, `powerbi`,
`communication`, `problem_solving`, `process_modeling`) do not exist in the
current 90-entry taxonomy, so `validate.py` would reject the file outright. It
also held the only Arabic posting collected anywhere in the project.

To use it again, either restore `taxonomy_starter_19.json` as `taxonomy.json`,
or map its six ids onto SK-codes — a relabelling decision, not a mechanical one.
