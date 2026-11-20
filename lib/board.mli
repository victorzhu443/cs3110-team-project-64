(** A rectangular grid of cells holding pieces.

    A board is never changed in place: every operation that "changes" a board
    returns a new one and leaves the old one as it was. Cells are either empty,
    hold a fixed piece that came with the level, or hold a piece the player
    placed. Only player pieces can be rotated or removed. *)

open Types

type t
(** A board. The representation is hidden. *)

(** What a single cell holds. *)
type cell =
  | Empty  (** Nothing is here. *)
  | Fixed of piece  (** Part of the level; the player cannot move it. *)
  | Placed of piece  (** Put here by the player; can be rotated or removed. *)

(** Why an operation was refused. *)
type error =
  | Bad_size of int * int
      (** A board must have at least one row and one column. Holds the rows and
          columns asked for. *)
  | Out_of_bounds of pos  (** The position is not on the board. *)
  | Occupied of pos  (** The cell already holds a piece. *)
  | Not_player_piece of pos
      (** The cell is empty or holds a fixed piece, so there is nothing the
          player can rotate or remove there. *)
  | Not_placeable of piece
      (** Players may only place mirrors and splitters, not sources, walls, or
          targets. *)

val string_of_error : error -> string
(** [string_of_error e] is a short sentence describing [e], suitable to show a
    player. *)

val empty : int -> int -> (t, error) result
(** [empty rows cols] is a board with [rows] rows and [cols] columns, every cell
    empty. Error: [Bad_size] if [rows < 1] or [cols < 1]. *)

val rows : t -> int
(** [rows b] is the number of rows in [b]. *)

val cols : t -> int
(** [cols b] is the number of columns in [b]. *)

val in_bounds : t -> pos -> bool
(** [in_bounds b p] is whether [p] is a cell of [b]: [0 <= p.row < rows b] and
    [0 <= p.col < cols b]. *)

val get : t -> pos -> (cell, error) result
(** [get b p] is what the cell at [p] holds. Error: [Out_of_bounds]. *)

val add_fixed : t -> pos -> piece -> (t, error) result
(** [add_fixed b p pc] is [b] with the fixed piece [pc] at [p]. Used when
    building a level, not by the player. Any kind of piece may be fixed. Errors:
    [Out_of_bounds]; [Occupied] if the cell is not empty. *)

val place : t -> pos -> piece -> (t, error) result
(** [place b p pc] is [b] with the player piece [pc] at [p]. Any empty cell is
    allowed, including the cell right in front of a source. Errors:
    [Out_of_bounds]; [Occupied] if the cell is not empty; [Not_placeable] if
    [pc] is not a [Mirror] or [Splitter]. *)

val rotate : t -> pos -> (t, error) result
(** [rotate b p] is [b] with the player piece at [p] turned 45 degrees
    clockwise. Orientations cycle [Horizontal] to [Slash] to [Vertical] to
    [Backslash] and back to [Horizontal], so four rotations return a piece to
    where it started. Errors: [Out_of_bounds]; [Not_player_piece] if the cell is
    empty or holds a fixed piece. *)

val remove : t -> pos -> (t, error) result
(** [remove b p] is [b] with the player piece at [p] taken off, leaving the cell
    empty. Errors: [Out_of_bounds]; [Not_player_piece] if the cell is empty or
    holds a fixed piece. *)

val sources : t -> (pos * dir * color) list
(** [sources b] is every source on [b] with its direction and color, in reading
    order (top row first, left to right). *)

val targets : t -> (pos * color) list
(** [targets b] is every target on [b] with the color it needs, in reading
    order. *)

val placed : t -> (pos * piece) list
(** [placed b] is every piece the player has placed on [b], in reading order. *)

val empty_cells : t -> pos list
(** [empty_cells b] is every empty cell of [b], in reading order. *)
