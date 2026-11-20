# Decisions

What the team has decided about the design and the process, and what is still
open. When a pull request or a group-chat discussion settles a question, add an
entry: what was decided, the alternatives, why, and who agreed. D1–D16 come from
section 4 of [the MS2 plan](MS2_PLAN.md); where the two differ, this file is
the current record.

- **DECIDED**: fixed unless the team agrees otherwise.
- **PROVISIONAL**: in force as the default until the team discusses it.
- **OPEN**: not decided yet; owner and date in "Still open" below.

## Register

| # | Decision | Status |
|---|---|---|
| D1 | Beams travel in eight directions in the shared type, as promised in MS1. The MS2 level only needs straight beams. | DECIDED |
| D2 | A color is three on/off channels: red, green, blue. White is all three on. | DECIDED |
| D3 | MS2 pieces: source, wall, target, mirror, splitter. Prism, filter and combiner wait for MS3 and appear in the report as proposed. | DECIDED |
| D4 | The board hides its representation and is never changed in place. Every move returns a new board. | DECIDED |
| D5 | Rules: a target lights only on an exact color match; a target absorbs the beam; a beam ends at the board edge. | CHANGED by D21 (targets no longer absorb) |
| D6 | Level files are a plain-text grid written by hand, with no library. A bad file returns an error value, not an exception. | DECIDED |
| D7 | Alex owns game state (current board, pieces left, move count, win check), as part of "game shell." It is testable without the screen. This is an addition to the MS1 responsibility table and is recorded as such in report section 03. | DECIDED |
| D8 | The MS2 slice is exactly the MS1 "Where we'll start" text (section 6 of the plan). | DECIDED |
| D9 | Sohan's generator in MS2: backwards construction plus a test over many seeds. Playing a generated level with `--seed` is a stretch goal. | DECIDED |
| D10 | Screen for MS2: plain colored text and typed commands, no library. Whether `notty` or `minttea` is needed at all is open (O2). | DECIDED, with O2 open |
| D11 | Akshay creates the dune project as the first handoff on Wednesday, with Victor reviewing. Each owner then adds their own `.mli` with a stub so everything compiles. | DECIDED |
| D12 | OUnit only. One test file per module. | DECIDED |
| D13 | AI-written tests: the human works out expected answers by hand from the level drawing; solver answers are verified by running the tracer; agents never get expected values by running the code. | DECIDED (confirmed at the Nov 17 kickoff; addition in D23) |
| D14 | The two-reviewer rule starts Wed Nov 18; the backup owner is always one of the two; reviews happen the same day; Victor protects `main`; agent rules go in `AGENTS.md`. | DECIDED |
| D15 | No AI attribution on commits or pull requests. Agents raise this with their human before the first commit. AI use is disclosed in `AUTHORS.md`, `docs/AI-LOG.md` and the report. | DECIDED |
| D16 | The eight existing co-author lines on Victor's Nov 2–4 commits: whether to remove them. Rewriting shared history is risky while MS1, which checks commit attribution, is ungraded (plan section 11). | OPEN (O4) |
| D17 | The game is called Lumen; the library is `lumen`. | DECIDED |
| D18 | Pull requests are merged with an ordinary merge commit. | DECIDED |
| D19 | The shared contract (plan section 5) is ratified with no edits and frozen for MS2. | DECIDED |
| D20 | MS2 is submitted on Gradescope by Mon Nov 23, 9:00 pm. | DECIDED |
| D21 | Beams pass through targets; a target lights when the mix of every beam through it exactly equals its color. | DECIDED |
| D22 | Tracer rules for paths, mirrors, sources, crossings and splitters. | DECIDED |
| D23 | An agent may cross-check hand-worked expected answers after the human has written theirs. | DECIDED |

## Decisions since Nov 17

### D17 — The game is called Lumen (resolves O3)

- **What:** the game's name is Lumen. The Dune library is `lumen` (AKS-1,
  pull request #1); the program stays `bin/main.exe`.
- **Alternatives:** none recorded.
- **Why:** it had been the working name since MS1; the team confirmed it.
- **Who agreed:** the team, at the Tue Nov 17 kickoff.

### D18 — Ordinary merge commits (resolves O8)

- **What:** pull requests are merged with a regular merge commit, not squashed
  or rebased.
- **Alternatives:** squash merge; rebase merge.
- **Why:** each member's own commits stay on `main` under their own name, which
  is how course staff see who did what.
- **Who agreed:** Victor, as git lead and owner of O8.

### D19 — Shared contract ratified (resolves O11)

- **What:** the project layout, the `Types` module, the module table and the
  cross-module rules in section 5 of the plan are frozen for MS2 as written.
  A change needs a post in the group chat and a yes from every owner whose
  module uses the thing being changed.
- **Alternatives:** none; no edits were proposed.
- **Who agreed:** the team, at the Tue Nov 17 kickoff.

### D20 — Submission time (resolves O7)

- **What:** `MS2Report.pdf` and the ZIP are due on Gradescope by Mon Nov 23,
  9:00 pm. The team target stays Sat Nov 21 for the working slice.
- **Who confirmed:** Anvi.

### D21 — Targets let beams pass; exact-mix lighting (changes D5)

- **What:** a beam passes through a target and keeps going. A target lights when
  the colors of every beam passing through it, OR-ed channel by channel, exactly
  equal the target's color (red + green = yellow lights a yellow target; a stray
  green beam through a red target makes yellow, so it stays dark). The rest of
  D5 stands: a beam ends at the board edge.
- **Alternatives:** targets absorb (the old D5); a target lights if any one beam
  matches (no mixing); a target lights if the mix contains its color.
- **Why:** it is the look the team wants for the game, colored targets become
  real puzzles, and it keeps D5's exact match. "Contains" was rejected because a
  white beam would light every target and MS3's prism and filter would lose their
  purpose. Mixing at targets overlaps with the MS3 combiner; revisit in the MS3 plan.
- **Who agreed:** the team, in the group chat, Nov 18.

### D22 — Tracer rules

Decided by Anvi as tracer owner (plan section 5.4) and shared with the team on
Nov 18. They go into the `tracer.mli` comments.

- A beam's path starts in its source's own cell and ends in the cell that stopped
  it (a wall, a mirror edge); at the board edge it ends in the last cell on the
  board.
- A mirror hit edge-on (the beam moves along the mirror's line) stops the beam,
  like a wall. *Alternative:* pass through.
- A mirror hit square-on bounces the beam straight back. *Alternative:* stop.
- Mirrors reflect from both faces in MS2. One-sided mirrors are proposed for MS3;
  they change `Types`, so they need every owner's yes then.
- A beam entering any source's cell, its own included, passes through.
  *Alternative:* the source blocks it.
- Beams that cross outside a target pass through each other untouched.
- A splitter sends one beam straight on and turns a second beam exactly as a
  mirror of the same orientation would; both keep the incoming color.

### D23 — Agents may cross-check expected answers (adds to D13)

- **What:** after the human has written their own expected answers, the agent
  may work them out independently, by reasoning and never by running code, for
  comparison. The human settles any difference. The pull request's AI-log row
  says the answers were cross-checked.
- **Why:** a second, independent check of hand-worked answers, without the
  implementation deciding what is "right".
- **Who agreed:** the team, Nov 18.

## Still open

| # | Question | Owner | Needed by |
|---|---|---|---|
| O2 | Is `notty` or `minttea` needed at all? MS1 promised this investigation, so if it is dropped the report must say why. Alex's ALX-5 waits on it. | Anvi asks the advisor | As soon as possible |
| O4 | Remove the eight co-author lines (D16)? | Victor; Anvi follows up | Before H1a, or after the MS1 grade |
| O5 | Handout section 07, the rubric, the report template, the ZIP's required name | Anvi | Deferred while code gets started; before H6 (Sun Nov 22, 6pm) |
| O9 | Which OPAM switch everyone builds with | Akshay, with Victor | H1a |
| L1 | When a beam loops, is the repeated cell listed again, and is the end recorded as "loop"? | Anvi | ANV-8 (H3b) |
| S2/S3 | What a splitter does when hit edge-on, and when hit square-on | Anvi | ANV-8 (H3b) |
| — | Whether "every target lit" is true on a board with no targets | Anvi | ANV-5 (`tracer.mli`) |
| — | The shape of the trace result, including how a split beam is held (Sohan and Alex rely on it) | Anvi, with Sohan | ANV-5 / H1c |

Rule details each owner proposes in their `.mli` and records here (plan
section 5.4): which pieces rotate and through how many orientations (Akshay);
placing a piece in a source's first cell (Akshay); the typed command words
(Alex); the level file characters (Akshay).
