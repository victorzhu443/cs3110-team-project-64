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
| 2026-11-20 | Sohan | Test harness (SOH-1, part 1): `test/test_util.ml`, the README's "Running the tests" section, the OUnit row in `AUTHORS.md` | Claude Code drafted the three changes, the pull request description and the wording of "My understanding" | Sohan read the code and ran `dune test`; the agent also ran the build, tests and formatter on the branch; reviewers Alex and Akshay | #3 |
| 2026-11-20 | Sohan | Generator (SOH-1, SOH-3, SOH-4): `lib/generator.mli`, `lib/generator.ml`, `test/test_generator.ml` | Claude Code wrote a prototype against stand-in modules on Nov 18, then adapted it to the real `Types`, `Tracer` and level format: the interface, the backwards construction, and the tests over seeds 1 to 200. It also drafted the pull request description and "My understanding", and the follow-up commit that left `generate` out after Alex's review | Sohan read the code and ran `dune test`. The tests check properties promised in `generator.mli` for every seed, not stored output (D13). The agent broke the generator on purpose three ways on a scratch copy and confirmed the tests fail each time; reviewers Alex and Akshay | #9 |
| 2026-11-21 | Sohan | AI log and `AUTHORS.md` rows for the generator and test harness | Claude Code drafted these rows and the `AUTHORS.md` AI row | Taken from the AI-use sections of #3 and #9; reviewers Anvi and Victor | *this PR* |
| 2026-11-20 | Anvi | Git set-up (VIC-1): pull request template | Claude Code drafted `.github/pull_request_template.md` from section 9.4 of the plan, and drafted the pull request description | Anvi compared each heading and checklist item with section 9.4 and approved the text before it was committed | #2 |
| 2026-11-20 | Anvi | Documentation set-up (ANV-2) | Claude drafted `DECISIONS.md`, `AGENTS.md`, `MS2-CHECKLIST.md`, this file's intro, and the README and `AUTHORS.md` edits from the MS2 plan and the team's decisions | Anvi reviewed and edited every file before it was committed; reviewers Sohan and Victor | #7 |
| 2026-11-20 | Alex | Game and render interfaces (ALX-1) | Codex drafted the interfaces, stubs, and command documentation from the MS2 plan and Alex's choices | Alex approved the command syntax and API shape. Codex ran the build, tests, and formatting checks. Alex's diff review is pending. | *link to be added once opened* |
| 2026-11-20 | Anvi | Tracer fixes (ANV-5), on Victor's tracer | Claude Code drafted the changes to `tracer.ml`, `tracer.mli` and `test_tracer.ml` to follow D21 and D22, and the `trace` wrapper and the `entered` field | Anvi decided each rule, read every line, and ran `dune build` and `dune test` (27 pass); the new tests' expected values come from her hand-worked boards (D13); reviewed by Sohan and Victor | #6 |
| 2026-11-20 | Anvi | Hand-worked tracer boards (ANV-6) | Claude Code drafted the write-up of the 17 boards, `victor-check.md`, and `draw_boards.py`, which draws the pictures | Anvi worked every answer by hand first; the agent then worked them by reasoning, not by running code (D23), and all 17 matched; Victor checks boards 5 and 9 on his own | #8 |
| 2026-11-21 | Anvi | Decision register update | Claude Code drafted D25–D28, the D21 note and these rows from decisions already made | Anvi checked each entry against what was decided | *this PR* |
| 2026-11-21 | Anvi | Tracer tests from the hand-worked boards (ANV-7) | Claude Code turned the 17 boards in `docs/tracer-cases/README.md` (#8) into tests in `test/test_tracer.ml`, copying each expected value from Anvi's answers | Anvi worked every answer by hand (ANV-6) and approved the test code before it was committed; all 17 pass, 44 tracer tests in all | *this PR* |
| 2026-11-21 | Alex | Game state and command parser (ALX-2) | Codex drafted the game-state code, command parser, error messages, and OUnit tests | I approved the API and error wording. Codex worked out the expected results from the level drawing and documented rules, then ran the build, formatter, and all 148 tests. My own review and test run are pending. | *link to be added once opened* |
| 2026-11-21 | Alex | Board rendering (ALX-3) | Codex drafted the renderer and its plain-text test from Alex's approved display choices | Codex worked out the expected text from the level drawing at Alex's request, then ran the checks. Alex's independent review is pending. | *link to be added once opened* |
| 2026-11-21 | Alex | Playable tutorial (ALX-4) | Codex drafted the terminal loop and README instructions and recorded an actual tutorial play-through | Alex chose the terminal wording and exit behavior. Codex ran the build, formatter, all 148 tests, and terminal smoke checks. Alex's manual review and Akshay's play-through are pending. | *link to be added once opened* |
