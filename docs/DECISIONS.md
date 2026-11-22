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
| D24 | The terminal uses zero-based, row-first coordinates and counts each successful board edit as one move. | DECIDED |
| D25 | A looping beam stops before it repeats a cell and direction, and ends as a loop. | DECIDED |
| D26 | A splitter hit edge-on sends one beam; a splitter hit square-on sends one on and one back. | DECIDED |
| D27 | A board with no targets counts as all lit. | DECIDED |
| D28 | The shape of the trace result, and tracing a grid without a board. | DECIDED |
| D29 | The terminal uses a glyph per board cell and ANSI color, with a plain-text render option. | DECIDED |
| D30 | The terminal takes a level path and ends the session on a win, quit, or end of input. | DECIDED |

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
- **What follows:** lighting is not one-way. Adding a beam can turn a lit
  target dark (a red target lit by red goes dark when a blue beam also crosses
  it). So the win check is made after every move, not once a target lights;
  backwards construction must make a target the mix of every beam through its
  cell; and the solver cannot stop early because a target is lit. Raised by
  Victor on #6.

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

### D24 — Terminal commands (ALX-1)

- **What:** `place ROW COL PIECE ORIENTATION`, `rotate ROW COL`,
  `remove ROW COL`, `help`, and `quit`. Coordinates are zero-based and
  row-first. Piece names are `mirror` and `splitter`. Orientations use the
  symbols shown in the README. Every successful board edit counts as one
  move. The executable handles help and quit.
- **Alternative considered:** one-based player coordinates.
- **Why:** zero-based, row-first coordinates match `Types.pos` and the level
  file coordinates. The orientation symbols match the level format.
- **Who agreed:** Alex, the game and terminal UI owner, on Nov 20.

ALX-2 clarifications from Alex on Nov 21:

- Coordinates use nonnegative decimal integers.
- Placement checks the board before checking inventory. Removing a piece
  returns it in the orientation it had in the starting inventory.
- Invalid commands prompt the player to type `help`. An empty inventory
  names the unavailable piece kind. Board errors keep the Board wording.

### D25 — Loops (resolves L1)

- **What:** a beam whose next cell is one it already entered travelling the
  same way stops where it is. That cell is not listed again; the ending's
  reason is `Looped` and its `last` is the last cell of the path.
- **Alternatives:** list the repeated cell once more; record no separate
  reason.
- **Why:** every cell in the path is one the beam really lit, and a loop is
  visible in the result without comparing cells.
- **Who agreed:** Anvi as tracer owner, accepting Victor's version in #6
  (Nov 20).

### D26 — Splitters edge-on and square-on (resolves S2/S3)

- **What:** these follow from D22's splitter rule (the turned beam goes where a
  mirror would send it). Edge-on, the turned beam and the straight beam are the
  same way, so one beam leaves. Square-on, one beam goes straight on and one
  comes straight back.
- **Who agreed:** Anvi, Nov 18, as part of D22.

### D27 — No targets means all lit

- **What:** `all_lit` is true on a board with no targets.
- **Alternatives:** false, so that a board must have a target to be solved.
- **Why:** "every target is lit" is true when there are none. If a level must
  have a target, that check belongs in level validation (Akshay), not in the
  tracer.
- **Who agreed:** Anvi, accepting Victor's version in #6 (Nov 20).

### D28 — The trace result (resolves the result-shape question; SOH-2)

- **What:** `Tracer.trace : Board.t -> result` wraps
  `Tracer.trace_grid ~rows ~cols ~cell_at`, so tests and the generator can
  trace a grid without a board. A `result` holds `segments` (each cell of each
  beam, with `at`, `entered`, `dir` and `color`; a cell appears once per beam
  through it), `endings` (one per beam, each splitter branch its own, with
  `last`, `heading`, `beam_color` and a `reason`: `Left_board`, `Hit_wall`,
  `Hit_mirror_edge` or `Looped`), `targets` (in reading order, each with the
  mix that reached it, or `None`) and `all_lit`.
- **Alternatives:** trace only a `Board.t`; hold a split beam as a tree.
- **Why:** the rules can be tested on a grid written as text before the board
  works, and a flat list is simple for Alex to draw and for Sohan to read
  endings from.
- **Who agreed:** Anvi as tracer owner and Victor, who wrote it (#6). Sohan
  approved #6 and builds the generator on `trace_grid` (#9).

### D29 — Board rendering (ALX-3)

- **What:** The grid shows empty cells as dots, walls as hashes, sources as
  `@`, dark targets as `o`, and lit targets as `*`. Mirrors use their
  orientation symbols and splitters use distinct line glyphs. Beams follow
  their axis and use `+` where different axes cross in an empty cell. A
  piece stays visible when a beam passes through it. The inventory and
  move count appear below the grid.
- **Alternative considered:** Always include color escapes in the renderer.
- **Why:** Plain output is readable in transcripts and can be compared by
  tests. Color shows the light and target colors in the terminal.
- **Who agreed:** Alex, the terminal UI owner, on Nov 21.

Review follow-up on PR #19: Alex approved dashed beam glyphs
(`┄`, `┆`, `⋰`, `⋱`) so they remain distinct from pieces in plain text.
The renderer uses the basic eight ANSI colors for terminal compatibility.

### D30 — Terminal session (ALX-4)

- **What:** The terminal takes a level file path and redraws the board as the
  player enters commands. Invalid commands and rejected moves display the
  existing Game error messages and leave the session running. The session
  ends on `quit`, end of input, or a win. The win message is
  `You solved the level!`. Set `NO_COLOR=1` for plain output.
- **Alternative considered:** Keep accepting moves after a win.
- **Why:** Ending at the win gives the tutorial a clear finish. Plain output
  makes the play-through easy to capture and read.
- **Who agreed:** Alex, the terminal UI owner, on Nov 21.

Review follow-up on PR #21: When the inventory is empty and a placed piece
can be removed, an unsolved game tells the player how to recover.

## Still open

| # | Question | Owner | Needed by |
|---|---|---|---|
| O2 | Is `notty` or `minttea` needed at all? MS1 promised this investigation, so if it is dropped the report must say why. Alex's ALX-5 waits on it. | Anvi asks the advisor | As soon as possible |
| O4 | Remove the eight co-author lines (D16)? | Victor; Anvi follows up | Before H1a, or after the MS1 grade |
| O5 | Handout section 07, the rubric, the report template, the ZIP's required name | Anvi | Deferred while code gets started; before H6 (Sun Nov 22, 6pm) |
| O9 | Which OPAM switch everyone builds with | Akshay, with Victor | H1a |
| — | A splitter's branches share one loop check. Could a second branch of the same beam be wrongly cut off as a loop? Victor could not build a case where it happens (#6). | Anvi | ANV-8 follow-up |

Rule details each owner proposes in their `.mli` and records here (plan
section 5.4): which pieces rotate and through how many orientations (Akshay);
placing a piece in a source's first cell (Akshay); the level file characters
(Akshay).
