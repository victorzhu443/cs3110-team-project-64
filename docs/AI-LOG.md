# AI log

One row per pull request, added by its author before review. Report section 06
and the AI table in [AUTHORS.md](../AUTHORS.md) are built from this log. AI use
is disclosed here, in `AUTHORS.md` and in the milestone report, never in commit
messages. The rules our coding agents follow are in [AGENTS.md](../AGENTS.md).

- **What the AI did:** which files or parts it drafted, and what it was asked.
- **How it was checked:** what the human did — read every line, ran the tests,
  worked expected values out by hand, asked a teammate.
- Work from before the pull-request rule (Nov 18) was pushed straight to `main`,
  so those rows list commits instead of a pull request.

| Date | Member | Component | What the AI did | How it was checked | Pull request |
|---|---|---|---|---|---|
| 2026-11-02 | Victor | Repository set-up: README, team contract, `AUTHORS.md`, MS1 checklist, team name | A coding agent (Claude) drafted the files and commit messages in six commits: `9a5397d`, `0379a85`, `5c7029c`, `3dcba4c`, `9edb56c`, `9d0bbef` | *Victor to add* | none (before the rule) |
| 2026-11-04 | Victor | MS1 checklist and contract updates | Same, two commits: `8589506`, `9911c4f` | *Victor to add* | none (before the rule) |
| 2026-11-16 | Anvi | MS2 plan (`docs/MS2_PLAN.md`) | An AI assistant (Claude) drafted the plan from the MS2 handout and Anvi's decisions | Anvi made every decision marked DECIDED and reviewed the full text; the team ratified the shared contract at the Nov 17 kickoff | none (before the rule, `8d90546`) |
| 2026-11-20 | Akshay | Project skeleton and `Types` (AKS-1) | *Akshay to add* | *Akshay to add* | #1 |
| 2026-11-20 | Anvi | Git set-up (VIC-1): pull request template | Claude Code drafted `.github/pull_request_template.md` from section 9.4 of the plan, and drafted the pull request description | Anvi compared each heading and checklist item with section 9.4 and approved the text before it was committed | #2 |
| 2026-11-20 | Anvi | Documentation set-up (ANV-2) | Claude drafted `DECISIONS.md`, `AGENTS.md`, `MS2-CHECKLIST.md`, this file's intro, and the README and `AUTHORS.md` edits from the MS2 plan and the team's decisions | Anvi reviewed and edited every file before it was committed; reviewers Sohan and Victor | #7 |
| 2026-11-20 | Alex | Game and render interfaces (ALX-1) | Codex drafted the interfaces, stubs, and command documentation from the MS2 plan and Alex's choices | Alex approved the command syntax and API shape. Codex ran the build, tests, and formatting checks. Alex's diff review is pending. | *link to be added once opened* |
| 2026-11-20 | Anvi | Tracer fixes (ANV-5), on Victor's tracer | Claude Code drafted the changes to `tracer.ml`, `tracer.mli` and `test_tracer.ml` to follow D21 and D22, and the `trace` wrapper and the `entered` field | Anvi decided each rule, read every line, and ran `dune build` and `dune test` (27 pass); the new tests' expected values come from her hand-worked boards (D13); reviewed by Sohan and Victor | #6 |
| 2026-11-20 | Anvi | Hand-worked tracer boards (ANV-6) | Claude Code drafted the write-up of the 17 boards, `victor-check.md`, and `draw_boards.py`, which draws the pictures | Anvi worked every answer by hand first; the agent then worked them by reasoning, not by running code (D23), and all 17 matched; Victor checks boards 5 and 9 on his own | #8 |
| 2026-11-21 | Anvi | Decision register update | Claude Code drafted D25–D28, the D21 note and these rows from decisions already made | Anvi checked each entry against what was decided | *this PR* |
