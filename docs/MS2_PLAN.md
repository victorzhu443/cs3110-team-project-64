# MS2 plan: Team 64 LaserTracer

Written Mon Nov 16, 2026, for Anvi (PM). This is the detailed master plan. The short Word summary for the team and the five per-person plans come later and are built from this file.

**Status words used below**

- **DECIDED**: Anvi agreed on Nov 16. Treat as fixed unless the team votes otherwise.
- **PROVISIONAL**: in force as the default until the team discusses it at the meeting.
- **PROPOSED**: my draft of a design detail. The team ratifies or edits it on Tue Nov 17. Not binding until then.
- **OPEN**: nobody has decided yet. Each open item has an owner and a date in section 13.

---

## 1. Dates and what MS2 is

| Date | What |
|---|---|
| Tue Nov 17 | Team ratifies the shared contract (section 5). A4 is due at 9:00pm the same day. |
| Wed Nov 18 | Work starts. |
| Sat Nov 21 | Team target: the MS2 slice works end to end and report inputs are in. |
| Sun Nov 22 | Report assembled, ZIP built and checked, contract revisited. |
| Mon Nov 23 | MS2 due on Gradescope. Time not confirmed; MS1 was 9:00pm. |
| Wed Nov 25 | Peer evaluations due (within 48 hours of submitting). |

MS2 is two things: a small part of the game that a person can actually use, and a report of about six pages. The handout says "a modest amount of useful, connected functionality is enough for full progress credit," and that most development still happens in MS3. Graders read the report plus selected code and tests from the uploaded ZIP, not from the repository.

There is no required staff meeting. The line in the repo README that says there is one is wrong and gets removed in task ANV-2.

---

## 2. Where the repository stands (read Nov 16)

- Five files only: `README.md`, `AUTHORS.md`, `docs/TEAM-CONTRACT.md`, `docs/MS1-CHECKLIST.md`, `.gitignore`. No OCaml code and no dune project.
- 13 commits, all pushed straight to `main`. No pull request has been used yet.
- Eight of Victor's commits end with `Co-Authored-By: Claude Opus 5 (1M context)`. The four README commits by Anvi, Alex, Akshay and Sohan have no such line.
- `AUTHORS.md` lists Victor, Sohan and Alex. Anvi and Akshay are missing. The file ships inside the MS2 ZIP.
- The AI-use table in `AUTHORS.md` is empty and the "running log" promised in the contract does not exist yet.
- The game's own name is still "TBD, Lumen is the current candidate."

---

## 3. What the MS2 report must contain

Source: the MS2 handout, sections 01 to 06, pasted by Anvi on Nov 16. Section 07 (submission), the rubric and the report template have not been read yet (open item O5).

| Report section | What the grader looks for | Who supplies it | Evidence it points to |
|---|---|---|---|
| Header | Team name, members and NetIDs, project title, clickable repo URL | Anvi | n/a |
| 01 What works so far | Short project description; changes since MS1; what a user can do now; which components work together; what remains | Anvi writes, from Alex's play-through transcript | `bin/main.ml`, `levels/tutorial01.lvl`, test paths |
| 02 Design | Main modules and how they cooperate, with a small diagram; key types and operations, each marked implemented or proposed; a few design choices and why; what building taught us; what still needs investigating and how | Each owner writes one paragraph on their module; Anvi draws the diagram and assembles; Victor and Alex write up the two investigations | every `.mli`, `docs/DECISIONS.md`, `docs/investigations/` |
| 03 Responsibilities | Updated table: done so far and next, primary and backup, paths; for each backup, how they became familiar and what they do next; every member contributed; anything missed or reassigned | Sohan drafts the table from the report inputs; Anvi checks | pull requests, test files, investigation notes |
| 04 Remaining work | Order, dependencies and concrete work per person for MS3 | Anvi, from each owner's "next" list | section 12 of this plan |
| 05 Validation | Per scope area: what should happen and how we know the expected answer; checks done with actual results, including failures; planned checks clearly labelled; steps for manual checks; `dune test` runs the suite | Sohan leads; each owner supplies their own test results | `test/*.ml`, manual play-through note |
| 06 AI use | How we used AI and reviewed it, with a concrete example; who reviews from now on; how an owner shows they understand the code; how AI-written tests' expected answers are checked independently | Anvi, from `docs/AI-LOG.md` | `docs/AI-LOG.md`, `AUTHORS.md` |

Three requirements that are easy to miss:

1. **Connected, not separate.** "A collection of functions that teammates have tested separately" does not count. The slice has to run through board, tracer, game state and display together.
2. **Backups must have done something.** Section 03 asks how each backup owner became familiar with the work. Every backup has a concrete task in section 8.
3. **AI-written tests.** Section 06 asks how expected answers are checked independently of the implementation. The contract does not cover this yet (decision D13).

---

## 4. Decision register

These get copied into `docs/DECISIONS.md` in task ANV-2.

| # | Decision | Status |
|---|---|---|
| D1 | Beams travel in eight directions in the shared type, as promised in MS1. The MS2 level only needs straight beams. | DECIDED |
| D2 | A color is three on/off channels: red, green, blue. White is all three on. | DECIDED |
| D3 | MS2 pieces: source, wall, target, mirror, splitter. Prism, filter and combiner wait for MS3 and appear in the report as proposed. | DECIDED |
| D4 | The board hides its representation and is never changed in place. Every move returns a new board. | DECIDED |
| D5 | Rules: a target lights only on an exact color match; a target absorbs the beam; a beam ends at the board edge. | DECIDED |
| D6 | Level files are a plain-text grid written by hand, with no library. A bad file returns an error value, not an exception. | DECIDED |
| D7 | Alex owns game state (current board, pieces left, move count, win check), as part of "game shell." It is testable without the screen. This is an addition to the MS1 table and is recorded as such in report section 03. | DECIDED |
| D8 | The MS2 slice is exactly the MS1 "Where we'll start" text (section 6 below). | DECIDED |
| D9 | Sohan's generator in MS2: backwards construction plus a test over many seeds. Playing a generated level with `--seed` is a stretch goal. | DECIDED |
| D10 | Screen for MS2: plain colored text and typed commands, no library. Whether `notty` or `minttea` is needed at all is open (O2). | DECIDED, with O2 open |
| D11 | Akshay creates the dune project as the first handoff on Wednesday, with Victor reviewing. Each owner then adds their own `.mli` with a stub so everything compiles. | DECIDED |
| D12 | OUnit only. One test file per module. | DECIDED |
| D13 | AI-written tests: the human works out expected answers by hand from the level drawing; solver answers are verified by running the tracer; agents never get expected values by running the code. | PROVISIONAL until the team meeting |
| D14 | The two-reviewer rule starts Wednesday; the backup owner is always one of the two; reviews happen the same day; Victor protects `main`; agent rules go in `AGENTS.md`; Anvi's first tasks are the AI log, the decision log, the AI table and Anvi's own `AUTHORS.md` row. | DECIDED |
| D15 | No AI attribution on commits or pull requests. Agents raise this with their human before the first commit. AI use is disclosed in `AUTHORS.md`, `docs/AI-LOG.md` and the report. | DECIDED |
| D16 | The eight existing co-author lines: Anvi may ask Victor to remove them. See the warning in section 11 before doing it. | OPEN (O4) |

---

## 5. Shared contract (PROPOSED, to ratify Tue Nov 17)

Everything in this section is a draft for the team to edit. Once ratified it is frozen for MS2: a change needs a post in the group chat and a yes from every owner whose module uses the thing being changed.

### 5.1 Project layout

```
dune-project
.ocamlformat
bin/main.ml            the driver: reads input, prints output, nothing else
lib/types.ml(i)        shared vocabulary used by every module
lib/board.ml(i)        Akshay
lib/level.ml(i)        Akshay
lib/tracer.ml(i)       Anvi
lib/solver.ml(i)       Victor
lib/generator.ml(i)    Sohan
lib/game.ml(i)         Alex
lib/render.ml(i)       Alex
test/test_board.ml, test_level.ml, test_tracer.ml, test_solver.ml,
     test_generator.ml, test_game.ml, test_render.ml, test_util.ml
levels/tutorial01.lvl
docs/                  contract, logs, investigations
AGENTS.md  AUTHORS.md  README.md
```

One library holding all modules, one executable, one test folder. The library and executable name depends on the game's name (O3).

### 5.2 Shared vocabulary (`Types`)

Owned by Akshay, because it describes the board and pieces. Every other module depends on it, so it is the most expensive thing to change later.

```ocaml
type pos = { row : int; col : int }      (* row 0 is the top, col 0 is the left *)
type dir = N | NE | E | SE | S | SW | W | NW
type color = { r : bool; g : bool; b : bool }
type orientation = Horizontal | Slash | Vertical | Backslash   (* the line a mirror lies along *)
type piece =
  | Source of dir * color
  | Wall
  | Target of color
  | Mirror of orientation
  | Splitter of orientation
```

Plus small pure helpers the team agrees it needs, for example the eight directions as a list, the position one step along a direction, and a printable name for each value.

### 5.3 What each module publishes and who relies on it

Names and shapes below are the level of detail to ratify. Exact signatures are written by each owner in their `.mli` on Wednesday (handoff H1b) and reviewed by the people who use them (H1c).

| Module | Owner | Publishes | Relied on by |
|---|---|---|---|
| `Board` | Akshay | An abstract board; create an empty board of a size; read a cell (empty, fixed piece, placed piece); add a fixed piece when building a level; place, rotate and remove a player piece; list sources, targets and empty cells; an error type for out of bounds, occupied cell, and "not a player piece" | Tracer, Solver, Generator, Game, Render, Level |
| `Level` | Akshay | A level: name, board, list of pieces the player may place; parse from text and load from a path, both returning a result with a described error | Game, Generator, Solver tests, `main` |
| `Tracer` | Anvi | `trace` from a board to a result holding: the ordered beam segments (cell, direction, color), the color arriving at each target, and whether every target is lit | Solver, Generator, Game, Render |
| `Solver` | Victor | `solve` from a board and the pieces available to an optional list of placements. Hints, solution counting and dead-end detection are proposed for MS3 | Generator (MS3), Game (MS3) |
| `Generator` | Sohan | `generate` from a seed and a size to a level that is solvable by construction. Difficulty and uniqueness are proposed for MS3 | `main` (stretch), Game (MS3) |
| `Game` | Alex | Game state; start from a level; apply a command (place, rotate, remove) returning a new state or an error; pieces left; move count; whether the level is won; a parser from a typed line to a command | Render, `main` |
| `Render` | Alex | A pure function from game state to the text to print, including beams and colors | `main` |

Rules that cross module lines:

- **Errors.** A public function that can fail returns a result with a described error. No exception is allowed to escape a module.
- **Purity.** Only `bin/main.ml` reads input or prints. Everything in `lib/` is testable without a terminal.
- **Randomness.** Only seeded randomness, passed in. The same seed must always give the same level.
- **Tracer and Generator.** Sohan needs to find where each beam ends in order to put a target there. Anvi and Sohan agree in the H1b review that the trace result exposes enough for that.

### 5.4 Game rules still to pin down (small, but shared)

D5 fixes the main rules. These details are left for the owner named, to propose in their `.mli` and record in `docs/DECISIONS.md`:

- What happens when a beam meets a mirror edge-on (Anvi).
- Which pieces a player may rotate and how many orientations a rotation cycles through (Akshay).
- Whether a player may place a piece in the path of a source's first cell (Akshay).
- The typed command words, for example `place`, `rotate`, `remove`, `quit` (Alex).
- The characters used in a level file (Akshay).

---

## 6. MS2 scope

**In (D8, D9, D10).** One hand-written level. The player loads it, sees it drawn in the terminal in color, places and rotates pieces by typing commands, sees the beams redrawn, and is told when every target is lit. The solver solves that same level in an automated test. The generator builds levels by backwards construction and a test checks many seeds. Victor's solver timing experiment is reported.

**Out until MS3.** Hints, dead-end warnings, solution counting, difficulty, uniqueness, decoy walls, prism, filter, combiner, undo history, saved stats, cursor movement, animation, menus, Bisect coverage, `INSTALL.md`, the video.

**Stretch, only after the slice works.** `main --seed N` plays a generated level. The solver also checks a few generated levels.

---

## 7. Handoffs

A handoff is the moment one person's work becomes something another person builds on. "Merged" means on `main` after two approvals. "End of day" means 11:59pm.

| ID | Due | From | To | What is handed over | It counts as done when |
|---|---|---|---|---|---|
| H0 | Tue Nov 17, end of day | Anvi | Everyone | Ratified shared contract (section 5) and answers to O1, O3 | All five have said yes in the group chat; edits are written into this plan |
| H0b | Tue Nov 17, end of day | Victor | Everyone | `main` protected, pull request template in place, how-to posted in chat | A direct push to `main` is refused; a test pull request shows the template |
| H1a | Wed Nov 18, 3pm (pull request open by noon) | Akshay | Everyone | Project skeleton with the `Types` module | A fresh clone passes `dune build` and `dune test`; merged |
| H1b | Wed Nov 18, end of day | Each owner | Their users | Their `.mli` with doc comments, a stub implementation, and their test file | `main` still builds; every module in 5.3 has an interface |
| H1c | Thu Nov 19, noon | Each user | Each owner | Comments on the interfaces they depend on | Every owner has a yes or a requested change from each person in the "relied on by" column |
| H2a | Thu Nov 19, 3pm | Akshay | Anvi, Alex, Victor, Sohan | Working board: create, read, add fixed, place, rotate, remove, list | Board tests pass on `main` |
| H2b | Thu Nov 19, end of day | Akshay | Anvi, Alex, Victor | Level loader and `levels/tutorial01.lvl`, plus its known solution written down | The level loads in a test; malformed files return errors |
| H3a | Fri Nov 20, 3pm | Anvi | Victor, Sohan, Alex | Tracer for source, wall, target and mirror | Tracer tests with hand-worked answers pass on `main` |
| H3b | Fri Nov 20, end of day | Anvi | Victor, Sohan, Alex | Splitter and loop detection; the tutorial level's known solution traces as solved | Tests pass on `main` |
| H4a | Sat Nov 21, 3pm | Alex | Everyone | Playable level from `dune exec` | Akshay plays `tutorial01` to a win following written steps |
| H4b | Sat Nov 21, 3pm | Victor | Anvi, Sohan | Solver test green and the timing table | `docs/investigations/solver-timing.md` merged |
| H4c | Sat Nov 21, 3pm | Sohan | Anvi, Alex | Generator test over many seeds green | Test passes on `main` |
| H5 | Sat Nov 21, end of day | Everyone | Anvi, Sohan | Report input (template in section 10.3) | Five inputs in the shared report document |
| H6 | Sun Nov 22, 6pm | Anvi, Sohan | Everyone | Full report draft, and the ZIP built from a clean clone | Everyone has read the draft; the unzipped folder passes `dune build` and `dune test` |
| H7 | Mon Nov 23, by the deadline | Anvi | Gradescope | `MS2Report.pdf` and the ZIP; all teammates added | Gradescope shows five members |
| H8 | Wed Nov 25 | Everyone | Each other | Peer evaluation forms | Anvi has a yes from all five |

If a handoff will be late, the owner says so in the group chat before the due time, with a new time. The people waiting keep working against the interface. A test that needs a module which is still a stub stays on its author's branch until it passes, so `dune test` on `main` always passes.

---

## 8. Work packages

Task IDs are used in the tracker and in the per-person plans. Every task lists what it waits on and what "done" means.

### 8.1 Anvi: tracer (primary), board (backup), project management

| ID | Task | Waits on | Due | Done means |
|---|---|---|---|---|
| ANV-1 | Post section 5, the decision register and the agent rules (section 9) in the group chat, so agents have the rules before `AGENTS.md` is merged; get a yes from all five; collect everyone's availability for Wed to Mon; settle O1 and O3 | n/a | H0 | Five yeses; edits written back into this plan |
| ANV-2 | Documentation set-up pull request: `docs/AI-LOG.md`, `docs/DECISIONS.md` seeded with D1 to D16, the AI-use table in `AUTHORS.md` ready to fill, Anvi's own `AUTHORS.md` row, `AGENTS.md` (section 9), `docs/MS2-CHECKLIST.md`; README fixes (remove the staff-meeting line, set the MS2 date) | H0b | Wed noon | Merged; reviewers Sohan and Victor |
| ANV-3 | Ask the advisor whether `notty` or `minttea` is needed (O2); get section 07, the rubric and the report template (O5); confirm the submission time (O7) | n/a | Wed | Answers recorded in `docs/DECISIONS.md` |
| ANV-4 | Keep the tracker current; post a status line in the chat at each handoff | n/a | ongoing | Tracker matches `main` at every handoff |
| ANV-5 | `tracer.mli` with doc comments, a stub, and `test/test_tracer.ml` | H1a | H1b | Merged; reviewers Victor and Sohan |
| ANV-6 | Hand-work the expected results: draw eight to ten tiny boards with the beam path and lit targets marked, before writing tracer code | H0 | Thu | Drawings kept in the repo or the report document; Victor checks two of them independently |
| ANV-7 | Tracer for source, wall, target and mirror, including the board edge, exact color match and absorption | H2a | H3a | The hand-worked cases pass as tests |
| ANV-8 | Splitter and loop detection; a test that the tutorial level's known solution traces as solved | H2b | H3b | Tests pass on `main` |
| ANV-9 | Backup duty for the board: first reviewer on Akshay's pull requests; check `tutorial01` by hand | H1b | Thu | Review comments on record; noted in the report input |
| ANV-10 | Second reviewer on Victor's solver pull requests | n/a | as they open | Same-day review |
| ANV-11 | Assemble the report with Sohan; draw the module diagram; write sections 01, 04 and 06 | H5 | H6 | Draft shared with the team |
| ANV-12 | Revisit the contract with the anonymous form, as the contract promises before each milestone; add the agreement on AI-written tests | n/a | Sun | Form sent and results discussed; `docs/TEAM-CONTRACT.md` updated by pull request |
| ANV-13 | Build the ZIP from a fresh clone, leaving out `_build`, `_opam` and `.git`; unzip it somewhere empty and run `dune build` and `dune test`; submit and add teammates | H6 | H7 | Submitted with five members |
| ANV-14 | Remind everyone about peer evaluations | H7 | H8 | Five yeses |

### 8.2 Akshay: board and level files (primary), terminal UI (backup), Git workflow (backup)

| ID | Task | Waits on | Due | Done means |
|---|---|---|---|---|
| AKS-1 | Skeleton pull request: `dune-project`, the `lib`, `bin` and `test` dune files, `.ocamlformat`, the `Types` module exactly as ratified, a `main` that builds, a test set-up with a placeholder file for each test file in 5.1, each holding one passing test; Akshay's own `AUTHORS.md` row | H0, H0b | H1a | A fresh clone passes `dune build` and `dune test`; reviewers Victor and Anvi |
| AKS-2 | `board.mli` and `level.mli` with doc comments and stubs; the level file format written down | H1a | H1b | Merged; reviewers Anvi and Alex |
| AKS-3 | Working board with tests: placing on an empty cell works; an occupied cell, an out-of-bounds cell and a fixed piece each give the right error; rotation cycles; the old board is unchanged after a move | H1b | H2a | Tests pass on `main` |
| AKS-4 | Level parser with validation, and `levels/tutorial01.lvl` using only MS2 pieces, with its solution written down for the other tests; tests for malformed files | H2a | H2b | The level loads in a test; each bad file returns its error |
| AKS-5 | Backup duty for the UI: first reviewer on Alex's pull requests; do the manual play-through of `tutorial01` from written steps and record what was seen in `docs/investigations/manual-playthrough.md` | H4a | Sat | Note merged; cited in report section 05 |
| AKS-6 | Second reviewer on Sohan's generator pull requests | n/a | as they open | Same-day review |
| AKS-7 | Report input | n/a | H5 | In the report document |

### 8.3 Victor: solver (primary), tracer (backup), Git workflow

| ID | Task | Waits on | Due | Done means |
|---|---|---|---|---|
| VIC-0 | Only if Anvi asks and the team agrees (O4): remove the eight co-author lines. Read the warning in section 11 first | Anvi's ask | before H1a, or not at all | Everyone has re-cloned; the five README commits still show the right people on GitHub |
| VIC-1 | Protect `main` (pull request required, two approvals, no force push); add the pull request template from section 9.4; post the five-line how-to in the chat; help Akshay get started with branches | n/a | H0b | A direct push is refused |
| VIC-2 | Review the skeleton as soon as it opens | AKS-1 | H1a | Approved or changes requested within two hours of the pull request opening |
| VIC-3 | `solver.mli` with doc comments, a stub, and `test/test_solver.ml` | H1a | H1b | Merged; reviewers Sohan and Anvi |
| VIC-4 | Brute-force `solve`, written against the board and tracer interfaces. Tests: the tutorial level has a solution; applying it and tracing reports solved; an unsolvable level returns nothing; a solution uses only the pieces available | H1b; goes green after H3b | Fri | Code merged; tests green by H4b |
| VIC-5 | Backup duty for the tracer: first reviewer on Anvi's pull requests; independently hand-check two of Anvi's drawings | ANV-6 | Fri | Comments on record; noted in the report input |
| VIC-6 | Timing experiment: 6×6 and 8×8 boards with two, three and four pieces; a table of times and a conclusion on board size and pruning | H3b | H4b | `docs/investigations/solver-timing.md` merged |
| VIC-7 | Second reviewer on Alex's game and render pull requests | n/a | as they open | Same-day review |
| VIC-8 | Report input, plus the investigation paragraph for report section 02 | n/a | H5 | In the report document |

### 8.4 Sohan: generator and test harness (primary), solver (backup), project management (backup)

| ID | Task | Waits on | Due | Done means |
|---|---|---|---|---|
| SOH-1 | `generator.mli` with doc comments, a stub, and `test/test_generator.ml`; `test/test_util.ml` with helpers the other test files share (agreed with Akshay, since it touches the test set-up); a "how to run the tests" section in the README; the OUnit row in the `AUTHORS.md` libraries table | H1a | H1b | Merged; reviewers Alex and Akshay |
| SOH-2 | Agree with Anvi how the trace result shows where each beam ends | ANV-5 | H1c | Recorded in `docs/DECISIONS.md` |
| SOH-3 | Backwards construction from a seed: build a board with walls and a source, place pieces, trace, put targets where beams end, take the pieces back as the player's pieces | H1b; goes green after H3b | Fri | Code merged |
| SOH-4 | Tests: for seeds 1 to 200 the construction's own placement traces as solved; the same seed gives the same level twice | H3b | H4c | Tests pass on `main` |
| SOH-5 | Backup duty for the solver: first reviewer on Victor's pull requests; run the timing benchmark on a second laptop and add those numbers | VIC-6 | Sat | Numbers in the timing note |
| SOH-6 | Second reviewer on Anvi's tracer pull requests | n/a | as they open | Same-day review |
| SOH-7 | Backup duty for project management: run `dune test` on `main` and record the actual output; draft report sections 03 and 05 from the report inputs | H5 | H6 | Drafts in the report document |
| SOH-8 | Report input | n/a | H5 | In the report document |

### 8.5 Alex: game state and terminal UI (primary), generator (backup)

| ID | Task | Waits on | Due | Done means |
|---|---|---|---|---|
| ALX-1 | `game.mli` and `render.mli` with doc comments and stubs; the typed commands written down; test files | H1a | H1b | Merged; reviewers Akshay and Victor |
| ALX-2 | Game state: start from a level; apply place, rotate and remove; pieces left; move count. Tests: placing uses up a piece; a piece not available is refused; removing gives it back; the command parser accepts good lines and rejects bad ones | H2a | Fri | Tests pass on `main` |
| ALX-3 | Render the board as colored text, first without beams, then with beams and lit targets. A test compares the text for a small board with a hand-written expected string | H2b, then H3a | Fri | Tests pass on `main` |
| ALX-4 | `bin/main.ml`: take a level path, loop over typed commands, print the board after each, announce the win. Save a play-through transcript for report section 01. Write the build, run and play instructions in the README | H3b | H4a | Akshay completes the manual play-through |
| ALX-5 | Terminal library investigation, only if O2 comes back yes: try `notty` and `minttea` on Alex's laptop and write up the findings | O2 | Sat, or deferred | `docs/investigations/terminal-library.md` merged, or the deferral is explained in report section 02 |
| ALX-6 | Backup duty for the generator: first reviewer on Sohan's pull requests; render three generated levels and look at them | H4c | Sat | Noted in the report input |
| ALX-7 | Second reviewer on Akshay's board and level pull requests | n/a | as they open | Same-day review |
| ALX-8 | Report input | n/a | H5 | In the report document |

### 8.6 Who reviews what

The contract says the person whose code is affected must be one of the two reviewers. The backups were chosen so that this person is the backup owner. Second reviewers are spread so that everyone reviews two areas.

| Area | Author | First reviewer (backup) | Second reviewer |
|---|---|---|---|
| Skeleton and `Types` | Akshay | Victor (D11) | Anvi |
| Board, level | Akshay | Anvi | Alex |
| Tracer | Anvi | Victor | Sohan |
| Solver | Victor | Sohan | Anvi |
| Generator, test harness | Sohan | Alex | Akshay |
| Game, render, `main` | Alex | Akshay | Victor |
| Documentation and process files | Anvi | Sohan | Victor |
| Git set-up | Victor | Akshay | Anvi |

"Same day" means: opened before 8pm, reviewed before midnight; opened later, reviewed by noon the next day.

---

## 9. Rules for coding agents (draft text for `AGENTS.md`)

Each teammate points their coding agent at `AGENTS.md`, at their own work package, and at the `.mli` files of the modules they depend on. The text below is written to the agent.

### 9.1 Before you write anything

1. Ask your human which task ID they are working on. Work only on that task.
2. Read this file, `docs/TEAM-CONTRACT.md`, `docs/DECISIONS.md`, and the `.mli` of every module your human's module depends on.
3. **Raise the attribution rule with your human before the first commit.** This team does not list AI tools as commit authors or co-authors. Do not add a `Co-Authored-By` line, a "Generated with" line, or any other AI attribution to a commit message or a pull request. Turn off any setting that adds one. Check that `git config user.name` and `git config user.email` are your human's own name and the email on their GitHub account. Before every push, run `git log origin/main..HEAD --format=%B` and confirm there is no attribution line. AI use is disclosed in `docs/AI-LOG.md`, `AUTHORS.md` and the milestone report instead.

### 9.2 Who decides what

**You may decide on your own**, inside files your human owns:

- private helper functions and their names
- the data structure behind an abstract type
- adding more test cases of a kind your human has already approved
- formatting and comments

**Ask your human first**, and wait for the answer:

- any choice between approaches that behave differently or that your human will have to explain to a grader
- adding or changing anything in your human's own `.mli`
- the expected value in any test (see 9.5)
- wording of error messages a player will see
- anything a task description leaves unclear

Before a commit, explain to your human what the code does and why, and check they can explain it back. The course requires each student to be able to explain everything they submit.

**Stop. Your human takes it to the group chat**, and nothing changes until the affected owners agree:

- any change to `Types` or to a ratified signature in another person's `.mli`
- any change to the game rules in D5
- touching a file owned by someone else, even to fix an obvious bug. Tell the owner instead.
- adding an OPAM package
- changing `dune-project`, a dune file, `.ocamlformat` or the test set-up
- building something that section 6 lists as out of scope
- anything that will make a handoff late

**Never:**

- push to `main`, merge a pull request, or force-push
- write the "My understanding" part of a pull request for your human
- produce an expected test value by running the implementation
- copy code from an existing laser puzzle game, from a course assignment (A0 to A4), or from the web without your human recording the source in `AUTHORS.md`
- edit `docs/TEAM-CONTRACT.md`, or submit anything to Gradescope
- commit a temporary copy of someone else's module to get unblocked. Code against the `.mli`.

### 9.3 Code rules

- Every module has an `.mli`. Every value in it has an OCamldoc comment saying what it does, what it needs, and what errors it returns.
- A public function that can fail returns a result. No exception escapes a module.
- Nothing in `lib/` reads input or prints. Only `bin/main.ml` does.
- Randomness is seeded and passed in. Never self-initialize the random generator.
- A board is never modified in place.
- Run `dune build`, `dune test` and `dune fmt` before every commit. Do not commit if any of them fails.

### 9.4 Pull requests and the two-reviewer rule

The team contract says every change goes through a pull request with two reviewers, and that if a change affects code someone else owns or uses, that person must be one of the reviewers.

- Work on a branch named `<name>/<module>-<topic>`. Keep each pull request small: one task or part of one.
- Name the two reviewers from the table in section 8.6 of the plan. If the change touches something another person uses, add that person.
- You do not approve, and you do not merge. Your human merges after two approvals and a green build.
- If your human is asked to review someone else's pull request, help them read it, but the review comments are theirs.
- Your human posts in the group chat when they push.

Every pull request description has these parts:

1. **What and why.** The task ID and one or two sentences.
2. **How to check it.** The commands to run and what to expect.
3. **My understanding.** Written by the human, in their own words: what the main parts do.
4. **AI use.** What the agent did, and how the human checked it.
5. **Expected answers.** For each new test, how the expected value was worked out.
6. **Checklist.** Builds; tests pass; formatted; `.mli` comments updated; `docs/AI-LOG.md` row added; `docs/DECISIONS.md` entry added if a decision was made; no AI attribution lines.

### 9.5 Tests (PROVISIONAL, D13)

- The human works out each expected answer by hand, from a drawing of the level, before the test is run. You may propose the test and the drawing; the human confirms the answer.
- A solver result is checked by applying it and running the tracer, not by comparing with what the solver returned last time.
- A generator result is checked by a property that must hold for every seed.
- One test file per module. Do not edit another module's test file.

### 9.6 Logs

For every pull request, add a row to `docs/AI-LOG.md`: date, member, component, what the AI did, how it was checked, pull request link. If the work settled a design question, add an entry to `docs/DECISIONS.md`: what was decided, the alternatives, why, and who agreed.

---

## 10. Documentation coverage

### 10.1 Every document, its owner, and when it changes

| Document | Owner | Created | Updated | Feeds |
|---|---|---|---|---|
| `.mli` doc comments | Each module owner | H1b | Every pull request that changes behavior | Report 02; MS3 requirement |
| `README.md` | Alex for build, run and play; Sohan for running tests; Anvi for dates and corrections | exists | ANV-2, SOH-1, ALX-4 | The grader who opens the ZIP |
| `AUTHORS.md` authors table | Each person adds their own row | exists | Anvi in ANV-2, Akshay in AKS-1 | Ships in the ZIP |
| `AUTHORS.md` libraries table | Whoever adds a package | exists | SOH-1 for OUnit | Ships in the ZIP |
| `AUTHORS.md` AI-use table | Anvi sets it up; each member fills their own row | ANV-2 | Before H5 | Report 06 |
| `docs/AI-LOG.md` | Anvi creates; everyone appends | ANV-2 | Every pull request | Report 06; the `AUTHORS.md` table |
| `docs/DECISIONS.md` | Anvi creates; everyone appends | ANV-2 | When a decision is made | Report 02 |
| `AGENTS.md` | Anvi | ANV-2 | By group-chat agreement | Every teammate's agent |
| Pull request template | Victor | VIC-1 | Rarely | Every pull request |
| `docs/TEAM-CONTRACT.md` | Anvi edits, by team agreement | exists | ANV-12: D7 and the AI-test agreement | Report 03 and 06 |
| `docs/MS2-CHECKLIST.md` | Anvi | ANV-2 | At each handoff | The tracker |
| `docs/investigations/solver-timing.md` | Victor, with Sohan's numbers | VIC-6 | n/a | Report 02 |
| `docs/investigations/terminal-library.md` | Alex | ALX-5, if O2 is yes | n/a | Report 02 |
| `docs/investigations/manual-playthrough.md` | Akshay | AKS-5 | n/a | Report 05 |
| Level file format | Akshay | AKS-2 | n/a | Report 02 |
| `MS2Report.pdf` | Anvi assembles, Sohan co-drafts | H6 | n/a | Gradescope |
| Peer evaluation forms | Everyone | H8 | n/a | Stay inside the team |

### 10.2 Validation plan for MS2 (feeds report section 05)

| Area | Automated checks | How the expected answer is known | Owner |
|---|---|---|---|
| Board | Legal placement; each illegal placement gives its error; rotation cycles; old board unchanged | By reading the rule | Akshay |
| Level | The tutorial level parses to the expected size, pieces and available pieces; each malformed file gives its error | Counted by hand from the file | Akshay |
| Tracer | One test per piece and per rule: edge, wall, mirror turn, exact color, absorption, splitter, a loop that must end; the tutorial solution traces as solved | Hand-drawn boards, two checked by Victor | Anvi |
| Solver | The tutorial level is solvable; the returned placement traces as solved; an unsolvable level returns nothing; only available pieces are used | The tracer acts as the independent checker | Victor |
| Generator | Seeds 1 to 200 each trace as solved with the construction's own placement; a seed repeats exactly | A property, not a stored answer | Sohan |
| Game | Pieces left and move count after each command; illegal commands refused; parser accepts and rejects | By reading the rule | Alex |
| Render | Text for a small board equals a hand-written string | Written by hand | Alex |
| Whole slice | Manual: written steps to load the tutorial level, place the pieces, and see the win message; colors visible | A person looks | Akshay |

Planned for MS3 and labelled as such in the report: prism, filter and combiner tracing; hints; dead-end detection; uniqueness; difficulty; saved stats; Bisect coverage.

### 10.3 Report input template (handoff H5)

Each person fills this in the shared report document by the end of Saturday:

1. What I built, with paths.
2. What works and what does not yet.
3. My tests: files, how many, the actual result of running them, and how I knew the expected answers.
4. One paragraph for report section 02: what my module takes care of, what others rely on, what building it taught me, and any decision I logged.
5. My backup role: what I did to learn the other component, and what I will do next.
6. How I used AI, how I checked it, and one concrete example.
7. What I will deliver for MS3.

---

## 11. Risks

| Risk | Why it matters | What we do |
|---|---|---|
| The tracer is on the critical path and its owner is also the PM | Solver, generator and game all wait on H3a and H3b, and Anvi also assembles the report | Hand-work the expected answers early (ANV-6); split the tracer into H3a and H3b; Victor is first call if it slips; Sohan drafts report sections 03 and 05 |
| Wednesday depends on the skeleton | Nobody can add an interface until H1a is merged, and Akshay is new to git | Victor helps Akshay and reviews by noon. If H1a is not merged by Wed 6pm, Victor finishes it and the report records the reassignment |
| Two reviewers on every change in a four-day window | A slow review blocks the next person | Small pull requests; the reviewer table in 8.6; same-day rule; Anvi nudges at each handoff |
| A shared type changes mid-week | Every module breaks at once | Frozen after H0; the change rule in section 5 |
| Removing the eight co-author lines (O4) | It rewrites history that all five have pulled. **MS1 has no grade yet, and 20% of MS1 is the check that each member's commit is correctly attributed.** A botched rewrite could damage that | Safest: leave them and apply D15 from Wednesday. If the team still wants them gone, wait for the MS1 grade, or do it Tuesday with everyone re-cloning, and confirm on GitHub that the five README commits still show the right people |
| Solver too slow | It is the experiment MS1 promised | VIC-6 reports it. The MS2 solver test only uses the small tutorial level |
| Five different agents writing in five styles | Hard to review and to explain | `AGENTS.md`, `.ocamlformat`, the "My understanding" section |
| A4 is due Tue 9pm | Ratification on Tuesday competes with it | Keep H0 to a group-chat yes on a short post |
| Travel before the break | Someone may be unavailable Sat to Mon | ANV-1 collects availability |
| Handout section 07, the rubric and the template are unread | A submission detail could be missed | O5, due Wednesday |

---

## 12. After MS2 (outline for report section 04)

Order, because of what depends on what:

1. Prism, filter and combiner in `Types`, then the tracer (Akshay, Anvi).
2. Solver pruning, solution counting, hints and dead-end detection (Victor).
3. Generator difficulty, uniqueness and decoy walls, which need solution counting (Sohan).
4. Cursor movement, menus, seed entry, hint display, saved stats (Alex, with Akshay for saving).
5. Bisect coverage, `INSTALL.md`, the product video, and the MS3 report.

The detailed MS3 plan is written after MS2 is submitted and the MS3 date is known.

---

## 13. Open items

| # | Question | Owner | Needed by |
|---|---|---|---|
| O1 | How AI-written tests get checked. D13 is the default until the team discusses it | Anvi, at the team meeting | H0 if possible; before H6 at the latest, because report section 06 needs it |
| O2 | Is `notty` or `minttea` needed at all? MS1 promised this investigation, so if it is dropped the report must say why | Anvi asks the advisor | Wed |
| O3 | The game's name, which sets the library and executable name | Team | H0, because AKS-1 needs it |
| O4 | Remove the eight old co-author lines? | Anvi asks Victor; see section 11 | Before H1a, or after the MS1 grade |
| O5 | Handout section 07, the rubric, the MS2 report template, the ZIP's required name | Anvi | Wed |
| O6 | When and where the team meets this week | Anvi | Tue |
| O7 | Submission time on Mon Nov 23 | Anvi | Wed |
| O8 | Merge style: ordinary merge or squash | Victor | H0b |
| O9 | Which OPAM switch everyone builds with | Akshay, with Victor | H1a |
| O10 | Where the task tracker lives: a file in the repo, or a shared sheet that needs no pull request | Anvi | Wed |
| O11 | Ratify section 5 | Team | H0 |

---

## 14. Next steps for this plan

1. Anvi reviews this file and marks changes.
2. One plan per person, built from section 8 and section 9, for each teammate to give to their agent.
3. The short Word summary for the team.
