(* Stub so the project builds while other modules code against level.mli. The
   real implementation comes in AKS-4. *)

open Types

type t = unit

type error =
  | File_error of string
  | Missing_name
  | Missing_pieces
  | Unknown_piece_name of string
  | Empty_grid
  | Ragged_grid of int
  | Unknown_char of char * pos
  | Undefined_letter of char
  | Bad_legend_line of int
  | No_source
  | No_target

let todo name = failwith ("Level." ^ name ^ ": not implemented yet (AKS-4)")
let string_of_error _ = todo "string_of_error"
let name _ = todo "name"
let board _ = todo "board"
let pieces _ = todo "pieces"
let of_string _ = todo "of_string"
let load _ = todo "load"
