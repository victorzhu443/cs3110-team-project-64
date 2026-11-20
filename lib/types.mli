(** Shared vocabulary for the board, its pieces, and beams of light. Every other
    module depends on these types, so changing them needs agreement from the
    whole team. *)

type pos = { row : int; col : int }
(** A cell on the board. Row 0 is the top row and column 0 is the left column.
*)

(** One of the eight compass directions a beam can travel in. [N] is towards row
    0 and [E] is towards higher column numbers. *)
type dir = N | NE | E | SE | S | SW | W | NW

type color = { r : bool; g : bool; b : bool }
(** A color as three on/off channels. White has all three on; black (no light)
    has all three off. *)

(** The line a mirror or splitter lies along, as drawn on the screen:
    [Horizontal] is [-], [Slash] is [/], [Vertical] is [|], and [Backslash] is
    [\ ]. *)
type orientation = Horizontal | Slash | Vertical | Backslash

(** Something that can occupy a cell. *)
type piece =
  | Source of dir * color  (** Emits a beam of the given color in [dir]. *)
  | Wall  (** Stops any beam that reaches it. *)
  | Target of color  (** Lit only by a beam of exactly this color. *)
  | Mirror of orientation  (** Reflects a beam. *)
  | Splitter of orientation  (** Sends a beam two ways. *)

val all_dirs : dir list
(** [all_dirs] is the eight directions, clockwise starting from [N]. *)

val step : pos -> dir -> pos
(** [step p d] is the position one cell from [p] in direction [d]. The result
    may be off the board; callers check bounds. *)

val string_of_dir : dir -> string
(** [string_of_dir d] is the name of [d], for example ["NE"]. *)

val string_of_color : color -> string
(** [string_of_color c] is a readable name for [c]: one of ["black"], ["red"],
    ["green"], ["blue"], ["yellow"], ["magenta"], ["cyan"], or ["white"]. *)

val string_of_orientation : orientation -> string
(** [string_of_orientation o] is the one-character symbol for [o], as described
    by {!orientation}. *)

val string_of_piece : piece -> string
(** [string_of_piece p] is the lowercase piece name followed by its attributes
    separated by spaces. Sources include direction then color, targets include
    color, and mirrors and splitters include their orientation symbol. For
    example, ["source NE red"], ["target blue"], and ["mirror /"]. *)
