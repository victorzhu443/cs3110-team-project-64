# Tutorial 1 play-through

Run from the repository root with plain terminal output. Coordinates are
zero-based and row first.

```text
$ NO_COLOR=1 dune exec ./bin/main.exe -- levels/tutorial01.lvl
Tutorial 1
......#
@------
.......
.#.....
...o..#
.....o.
Pieces left: splitter, mirror
Moves: 0
lumen> place 1 3 splitter \
......#
@--╲---
...|...
.#.|...
...*..#
...|.o.
Pieces left: mirror
Moves: 1
lumen> place 1 5 mirror \
......#
@--╲-\.
...|.|.
.#.|.|.
...*.|#
...|.*.
Pieces left: none
Moves: 2
You solved the level!
```
