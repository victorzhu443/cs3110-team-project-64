(* Stub so the project builds while other modules code against board.mli. The
   real implementation comes in AKS-3. *)

open Types

type t = unit
type cell = Empty | Fixed of piece | Placed of piece

type error =
  | Bad_size of int * int
  | Out_of_bounds of pos
  | Occupied of pos
  | Not_player_piece of pos
  | Not_placeable of piece

let todo name = failwith ("Board." ^ name ^ ": not implemented yet (AKS-3)")
let string_of_error _ = todo "string_of_error"
let empty _ _ = todo "empty"
let rows _ = todo "rows"
let cols _ = todo "cols"
let in_bounds _ _ = todo "in_bounds"
let get _ _ = todo "get"
let add_fixed _ _ _ = todo "add_fixed"
let place _ _ _ = todo "place"
let rotate _ _ = todo "rotate"
let remove _ _ = todo "remove"
let sources _ = todo "sources"
let targets _ = todo "targets"
let placed _ = todo "placed"
let empty_cells _ = todo "empty_cells"
