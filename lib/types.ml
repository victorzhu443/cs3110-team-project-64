type pos = { row : int; col : int }
type dir = N | NE | E | SE | S | SW | W | NW
type color = { r : bool; g : bool; b : bool }
type orientation = Horizontal | Slash | Vertical | Backslash

type piece =
  | Source of dir * color
  | Wall
  | Target of color
  | Mirror of orientation
  | Splitter of orientation

let all_dirs = [ N; NE; E; SE; S; SW; W; NW ]

(* Row and column change for one step in each direction. Row 0 is the top, so
   moving north decreases the row. *)
let delta = function
  | N -> (-1, 0)
  | NE -> (-1, 1)
  | E -> (0, 1)
  | SE -> (1, 1)
  | S -> (1, 0)
  | SW -> (1, -1)
  | W -> (0, -1)
  | NW -> (-1, -1)

let step p d =
  let dr, dc = delta d in
  { row = p.row + dr; col = p.col + dc }

let string_of_dir = function
  | N -> "N"
  | NE -> "NE"
  | E -> "E"
  | SE -> "SE"
  | S -> "S"
  | SW -> "SW"
  | W -> "W"
  | NW -> "NW"

let string_of_color c =
  match (c.r, c.g, c.b) with
  | false, false, false -> "black"
  | true, false, false -> "red"
  | false, true, false -> "green"
  | false, false, true -> "blue"
  | true, true, false -> "yellow"
  | true, false, true -> "magenta"
  | false, true, true -> "cyan"
  | true, true, true -> "white"
