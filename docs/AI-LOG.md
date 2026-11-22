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
| 2026-11-20 | Anvi | Documentation set-up (ANV-2) | Claude drafted `DECISIONS.md`, `AGENTS.md`, `MS2-CHECKLIST.md`, this file's intro, and the README and `AUTHORS.md` edits from the MS2 plan and the team's decisions | Anvi reviewed and edited every file before it was committed; reviewers Sohan and Victor | *link added once opened* |
| 2026-11-20 | Alex | Game and render interfaces (ALX-1) | Codex drafted the interfaces, stubs, and command documentation from the MS2 plan and Alex's choices | Alex approved the command syntax and API shape. Codex ran the build, tests, and formatting checks. Alex's diff review is pending. | *link to be added once opened* |
| 2026-11-21 | Victor | Solver `solve` and `apply` (VIC-4) | Claude Code drafted `apply`, the `solve` wrapper over `search`, their `.mli` comments and the eight level tests in `test/test_solver.ml`; it also proposed the eight expected answers, worked by reasoning from the drawings and never by running the code | Victor checked each expected answer against its drawing and confirmed all eight before the tests were run, read every line, and ran `dune build`, `dune test` (all suites pass) and `dune fmt`; reviewers Sohan and Anvi | *this PR* |
| 2026-11-21 | Victor | Solver timing investigation (VIC-6) | Claude Code drafted the benchmark harness (`docs/investigations/solver-timing/`), ran it, drew the two four-mirror levels with the argument that all four are needed, and drafted `docs/investigations/solver-timing.md` from the measured numbers | Victor checked the four-mirror argument against the drawings and read the harness and the write-up before opening the pull request; Sohan re-runs the harness on a second machine (SOH-5); reviewers Sohan and Anvi | *this PR* |
