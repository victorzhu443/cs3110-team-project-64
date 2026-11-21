(** A puzzle: a named board plus the pieces the player is given to solve it.

    Levels are read from plain-text files. The format is described in
    [docs/LEVEL-FORMAT.md]. A file that does not follow the format gives an
    error value describing what is wrong; it never raises an exception. *)

open Types

type t
(** A level. The representation is hidden. *)

(** Why a level could not be read. Line numbers count from 1. *)
type error =
  | File_error of string
      (** The file could not be opened or read. Holds the system's message. *)
  | Missing_name  (** There is no [name:] line. *)
  | Missing_pieces  (** There is no [pieces:] line. *)
  | Duplicate_header of int
      (** The [name:] or [pieces:] line on this line repeats one that came
          before it. *)
  | Unknown_piece_name of string
      (** A word on the [pieces:] line is not [mirror] or [splitter]. *)
  | Empty_grid  (** The file has no grid. *)
  | Ragged_grid of int
      (** The grid row on this line is a different width from the first row. *)
  | Unknown_char of char * pos
      (** This character at this grid position does not mean anything. *)
  | Undefined_letter of char
      (** A letter used in the grid has no legend line. *)
  | Bad_legend_line of int
      (** The legend line on this line is not in the form the format expects.
          Any line containing [=] counts as a legend line. *)
  | No_source  (** The grid has no source. *)
  | No_target  (** The grid has no target. *)

val string_of_error : error -> string
(** [string_of_error e] is a short sentence describing [e]. *)

val name : t -> string
(** [name l] is the level's name, as given on its [name:] line. *)

val board : t -> Board.t
(** [board l] is the starting board: every fixed piece in place and no player
    pieces. *)

val pieces : t -> piece list
(** [pieces l] is the pieces the player may place, in the order the file lists
    them. Each is a [Mirror Horizontal] or [Splitter Horizontal]; the player
    chooses the orientation when placing or by rotating. *)

val of_string : string -> (t, error) result
(** [of_string s] is the level described by the text [s]. Errors: every
    constructor of [error] except [File_error]. *)

val load : string -> (t, error) result
(** [load path] reads the file at [path] and is [of_string] of its contents.
    Errors: [File_error] if the file cannot be read, otherwise as [of_string].
*)
