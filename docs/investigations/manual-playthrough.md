# Manual play-through of tutorial01

Done by Anvi on Mon Nov 23, 2026

Machine: MacBook Air, macOS, Terminal app, OPAM switch cs3110-2026fa. Commit: 59613bf.

## Steps followed
The README's "Build and play" section, as written.

## What I saw
| # | What I did | What I expected | What I saw | OK? |
|---|---|---|---|---|
| 1 | Solved with `place 1 3 splitter \`, `place 1 5 mirror \` | Beams reach both targets, win message | Beams split at (1, 3) and turned at (1, 5); both targets changed from `o` to `*`; "Pieces left: none", "Moves: 2", then "You solved the level!" | Yes |
| 2 | `place 9 9 mirror /` | A clear error, game continues | "(9, 9) is not on the board." The board, pieces and move count were unchanged and the prompt came back | Yes |
| 3 | `fly` | "Invalid command", game continues | "Invalid command. Type help for usage." Nothing changed | Yes |
| 4 | `rotate 0 0` | Error, nothing changes | "There is no piece of yours at (0, 0) to change." Nothing changed | Yes |
| 5 | `remove 1 3` after placing | The splitter returns to "Pieces left" | The splitter came back ("Pieces left: splitter, mirror") and its beams disappeared, and "Moves" went from 1 to 2 | Yes |
| 6 | Run with `nope.lvl` | A message that the file could not be read | "The level file could not be read: nope.lvl: No such file or directory" | Yes |
| 7 | Colors on | Beams and targets drawn in their colors | The tutorial's beams are white, which shows as grey in my terminal; unlit targets are dim. No other colors appear on this level | Yes, but hard to read |

## Anything confusing or wrong
- White beams look grey, so they barely stand out from the board. Bright white or bold could help in MS3.
- The tutorial only uses white light, so this check does not exercise colored beams or color mixing.
