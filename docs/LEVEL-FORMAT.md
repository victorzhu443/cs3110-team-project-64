# Level file format

Owner: Akshay (AKS-2). Read by `Level.of_string` and `Level.load`.

A level file is plain text with three parts, in this order: a header, the grid,
and a legend. Blank lines between parts are ignored.

## Example

```
name: Tutorial 1
pieces: mirror mirror splitter

#######
#A...a#
#.....#
#..#..#
#....b#
#######

A = source E white
a = target white
b = target white
```

## Header

Two lines, in either order, before the grid:

- `name: <text>` is the level's name. Everything after `name:` is kept, with
  spaces at the ends trimmed.
- `pieces: <word> <word> ...` lists the pieces the player is given. Each word is
  `mirror` or `splitter`. A word may repeat. An empty list is allowed.

## Grid

One line per row, top row first. Every row must be the same width. Row 0 is the
top and column 0 is the left, matching `Types.pos`.

| Character | Meaning |
|---|---|
| `.` | Empty cell |
| `#` | Wall |
| `/` | Fixed mirror, `Slash` |
| `\` | Fixed mirror, `Backslash` |
| `-` | Fixed mirror, `Horizontal` |
| `\|` | Fixed mirror, `Vertical` |
| `A` to `Z` | A source, defined in the legend |
| `a` to `z` | A target, defined in the legend |

A grid must contain at least one source and one target.

## Legend

One line for each letter used in the grid:

- `<Uppercase letter> = source <direction> <color>`, for example `A = source E white`
- `<lowercase letter> = target <color>`, for example `a = target red`

Directions are `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`. Colors are `black`,
`red`, `green`, `blue`, `yellow`, `magenta`, `cyan`, `white` (the names
`Types.string_of_color` prints). A letter may be used in more than one cell, and
each cell gets the same piece.

## Rules for player pieces

Decided with AKS-2 (plan section 5.4):

- Players place only mirrors and splitters, on any empty cell, including the
  cell right in front of a source.
- Rotating turns a player piece 45 degrees clockwise: `-` to `/` to `|` to `\`
  and back. Fixed pieces never rotate.

## Errors

Each problem gives its own `Level.error` value instead of crashing:

| Problem | Error |
|---|---|
| The file can't be read | `File_error` |
| No `name:` line | `Missing_name` |
| No `pieces:` line | `Missing_pieces` |
| A word other than `mirror` or `splitter` on the `pieces:` line | `Unknown_piece_name` |
| No grid | `Empty_grid` |
| A row of a different width | `Ragged_grid` (the line number) |
| A character not in the table above | `Unknown_char` |
| A letter with no legend line | `Undefined_letter` |
| A legend line that doesn't match the forms above | `Bad_legend_line` (the line number) |
| No source, or no target | `No_source`, `No_target` |
