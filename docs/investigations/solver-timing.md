# Solver timing: brute force against beam pruning (VIC-6)

**Question.** How long does `Solver.solve` take on the board sizes and piece
counts we expect, and how much does the pruning hook (`?candidates`) buy?

**Answer in one line.** Brute force is fine up to 6×6 with three pieces (under
five seconds), slow at 8×8 with three (up to half a minute) and does not finish
8×8 with four mirrors within a minute. Offering only the cells a beam passes
through cuts the work by a factor of 10² to 10⁴ and solves every level here in
under 0.03 s. Pruning should be the default in MS3.

## Set-up

- Branch `victor/solver-timing` on top of `victor/solver-solve` (#16), commit
  `c3dbca1`: `Solver.solve` as merged, `Tracer.trace`, `Board`, `Level`,
  `Generator`.
- Apple M5 Pro, 24 GB, macOS 26.6.2, OCaml 5.3.0, dune 3.24.2, native build.
- Times are CPU seconds (`Sys.time`); each run gives up after 60 s.
- Harness: [`solver-timing/bench.ml`](solver-timing/bench.ml) and
  [`solver-timing/levels.ml`](solver-timing/levels.ml). See "Reproducing"
  below.

One trace of the tutorial board (6×7, three walls, two targets) costs
**4.2 µs**. A search step, which applies the placements and then traces, costs
7–9 µs.

## Method

Each level is searched twice with `Solver.search` over `Board.empty_cells`,
using the same goal predicate as `Solver.solve` (apply the placements, trace,
read `all_lit`):

- **every cell** – the default `?candidates`: every remaining empty cell is
  tried. This is exactly what `solve` does today.
- **on a beam** – `?candidates` returns only the remaining cells that some beam
  passes through on the board with the pieces placed so far. A piece anywhere
  else cannot change the light.

The harness counts **traces** (calls of the goal predicate) and CPU seconds.
Every solution the search returns is applied and traced again before it is
counted as found, so the numbers never rest on the search's own word.

### Levels

- **2 and 3 pieces: generated.** `Generator.construct ~seed ~rows ~cols`, the
  first seeds from 1 upward whose level has that many pieces: 6×6 seeds 1, 2
  (two pieces) and 3, 5 (three); 8×8 seeds 4, 5 (two) and 1, 2 (three). The
  same seed gives the same level on the same OCaml version; `levels.ml` prints
  them. Most mix a splitter with mirrors.
- **4 pieces: hand-drawn**, because the generator stops at three. Walls close
  every shorter route, so all four mirrors are needed: the beam can only reach
  the target travelling west out of the bottom-right corner, and getting there
  from a source firing east along the top row takes four turns (south, east,
  south, west). Intended solutions: 6×6 `\` (0,2), `\` (2,2), `\` (2,5),
  `/` (5,5); 8×8 `\` (0,4), `\` (3,4), `\` (3,7), `/` (7,7).

```
6×6                 8×8
A..#..              A....#..
......              ........
......              ........
......              ........
....#.              ........
...#a.              ........
                    ......#.
A = source E red    .....#a.
a = target red
```

## Results

| level | pieces | search | traces | CPU s | result |
|---|---|---|---|---|---|
| 6×6 seed 1 | 2 | every cell | 16 | 0.000 | found |
| 6×6 seed 1 | 2 | on a beam | 124 | 0.001 | found |
| 6×6 seed 2 | 2 | every cell | 6 048 | 0.028 | found |
| 6×6 seed 2 | 2 | on a beam | 4 | 0.000 | found |
| 6×6 seed 3 | 3 | every cell | 1 035 088 | 4.750 | found |
| 6×6 seed 3 | 3 | on a beam | 170 | 0.001 | found |
| 6×6 seed 5 | 3 | every cell | 353 418 | 1.665 | found |
| 6×6 seed 5 | 3 | on a beam | 1 710 | 0.009 | found |
| 6×6 hand-drawn | 4 | every cell | 1 783 264 | 8.502 | found |
| 6×6 hand-drawn | 4 | on a beam | 132 | 0.001 | found |
| 8×8 seed 4 | 2 | every cell | 16 272 | 0.125 | found |
| 8×8 seed 4 | 2 | on a beam | 28 | 0.000 | found |
| 8×8 seed 5 | 2 | every cell | 17 920 | 0.137 | found |
| 8×8 seed 5 | 2 | on a beam | 30 | 0.000 | found |
| 8×8 seed 1 | 3 | every cell | 88 454 | 0.716 | found |
| 8×8 seed 1 | 3 | on a beam | 140 | 0.002 | found |
| 8×8 seed 2 | 3 | every cell | 3 724 998 | 31.328 | found |
| 8×8 seed 2 | 3 | on a beam | 2 720 | 0.029 | found |
| 8×8 hand-drawn | 4 | every cell | 7 992 750 | 60.000 | **not finished** |
| 8×8 hand-drawn | 4 | on a beam | 348 | 0.003 | found |

Sohan's numbers from a second laptop (SOH-5) go in a second table here.

## What the numbers say

**Board size.** The brute-force search space is about n × (n−1) × … over the
empty cells, times 4 orientations per piece. Going from 6×6 (about 32 empty
cells) to 8×8 (about 58) multiplies the space by roughly 1.8 per piece: ×3 for
two pieces, ×6 for three, ×11 for four. The measured worst cases follow that
shape: 1.0 M traces at 6×6 with three pieces, 3.7 M at 8×8.

**Pieces.** Each extra piece multiplies the space by about 4n. The 8×8
four-mirror level has an upper bound of 58 × 57 × 56 × 55 × 4⁴ ≈ 2.6 billion
traces, which is about five hours at 7 µs each; the run was stopped at 60 s and
8 million traces. Three pieces on 8×8 is already the edge of what a player
would wait for.

**Where the solution sits matters more than the size.** Brute force on 6×6
seed 1 found its answer after 16 traces and on seed 2 after 6 048: the search
tries cells in reading order, so a solution near the top-left is found at once
and one near the bottom-right only after almost everything else. The table's
brute-force times are therefore samples, not bounds. The pruned search barely
depends on this, because it has so few cells to try.

**Pruning.** Offering only on-beam cells cut the traces by 10² to 10⁴ and every
level, including the one brute force could not finish, was solved in under
0.03 s. The hook itself costs one extra trace per call, which the table does not
count; with hundreds of calls at 4 µs each that is under a millisecond.

**When pruning is complete.** The pruned search only considers a piece on a
cell a beam already reaches, so it finds a solution only if the pieces can be
put down in the order the beam meets them. That holds whenever the pieces are
interchangeable (all mirrors, as in the hand-drawn levels) or the `pieces` list
is already in beam order, which the generator guarantees because it places
pieces along the beam. A hand-written level that lists a mirror before the
splitter the beam meets first could make the pruned search return `None` for a
solvable level. The fix is to let the search choose which remaining piece to
place next rather than taking them in list order. Until that is done, pruning
is an optimisation to try first, with brute force as the fallback, not a
replacement for it.

**Repeated work.** `search` places pieces in list order without noticing that
two mirrors are the same piece, so k identical pieces are tried in all k!
orders (noted in `solver.mli`). The four-mirror brute-force counts carry a
factor of up to 24; skipping those repeats is the cheapest speed-up after
pruning.

## Recommendation for MS3

1. Make on-beam pruning the default `?candidates` in `solve`, with the
   every-cell search as a fallback when the pruned search returns `None`.
2. Let the search pick the next piece by kind, so pruning is complete for any
   piece order and identical pieces are not permuted.
3. Keep the 60 s cap idea in the game: a hint request should time out, not
   hang.

## Reproducing

From the repository root, on a branch that has `Solver.solve`:

```
mkdir -p bench
cp docs/investigations/solver-timing/*.ml bench/
printf '(executables\n (names bench levels)\n (libraries lumen))\n' > bench/dune
dune exec bench/bench.exe      # the table; a few minutes, one run hits the cap
dune exec bench/levels.exe     # the generated levels used
rm -r bench
```

`bench/` is deliberately not committed: adding a build target is a dune change
the team decides together. The harness never prints from `lib/`; it is its own
executable.
