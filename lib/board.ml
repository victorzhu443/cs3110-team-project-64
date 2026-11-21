open Types

(* A cell missing from the map is empty. Positions compare by row, then column,
   so the map's bindings come out in reading order. *)
module PosMap = Map.Make (struct
  type t = pos

  let compare = compare
end)

type cell = Empty | Fixed of piece | Placed of piece

(* AF: [{ rows; cols; cells }] is a [rows] by [cols] board where the cell at [p]
   holds [c] if [cells] binds [p] to [c], and is empty otherwise.
   RI: [rows >= 1], [cols >= 1]; every key of [cells] is in bounds; no key is
   bound to [Empty]; every [Placed] piece is a [Mirror] or [Splitter]. *)
type t = { rows : int; cols : int; cells : cell PosMap.t }

type error =
  | Bad_size of int * int
  | Out_of_bounds of pos
  | Occupied of pos
  | Not_player_piece of pos
  | Not_placeable of piece

let string_of_pos p = Printf.sprintf "(%d, %d)" p.row p.col

let string_of_error = function
  | Bad_size (r, c) ->
      Printf.sprintf
        "A board must have at least one row and one column, not %d by %d." r c
  | Out_of_bounds p ->
      Printf.sprintf "%s is not on the board." (string_of_pos p)
  | Occupied p -> Printf.sprintf "%s already has a piece." (string_of_pos p)
  | Not_player_piece p ->
      Printf.sprintf "There is no piece of yours at %s to change."
        (string_of_pos p)
  | Not_placeable pc ->
      Printf.sprintf "You can only place mirrors and splitters, not a %s."
        (string_of_piece pc)

let empty rows cols =
  if rows < 1 || cols < 1 then Error (Bad_size (rows, cols))
  else Ok { rows; cols; cells = PosMap.empty }

let rows b = b.rows
let cols b = b.cols
let in_bounds b p = 0 <= p.row && p.row < b.rows && 0 <= p.col && p.col < b.cols

(* [lookup b p] is the cell at [p], assuming [p] is in bounds. *)
let lookup b p = Option.value (PosMap.find_opt p b.cells) ~default:Empty
let get b p = if in_bounds b p then Ok (lookup b p) else Error (Out_of_bounds p)

(* [put b p c] is [b] with [c] at [p], if [p] is in bounds and empty. *)
let put b p c =
  if not (in_bounds b p) then Error (Out_of_bounds p)
  else if lookup b p <> Empty then Error (Occupied p)
  else Ok { b with cells = PosMap.add p c b.cells }

let add_fixed b p pc = put b p (Fixed pc)

let place b p pc =
  match pc with
  | Mirror _ | Splitter _ -> put b p (Placed pc)
  | Source _ | Wall | Target _ -> Error (Not_placeable pc)

(* One 45-degree clockwise turn: - to \ to | to / and back to -. *)
let next_orientation = function
  | Horizontal -> Backslash
  | Backslash -> Vertical
  | Vertical -> Slash
  | Slash -> Horizontal

(* [change_placed b p f] applies [f] to the cell at [p] if it holds a player
   piece. *)
let change_placed b p f =
  if not (in_bounds b p) then Error (Out_of_bounds p)
  else
    match lookup b p with
    | Placed pc -> Ok { b with cells = f pc b.cells }
    | Empty | Fixed _ -> Error (Not_player_piece p)

let rotate b p =
  change_placed b p (fun pc cells ->
      let turned =
        match pc with
        | Mirror o -> Mirror (next_orientation o)
        | Splitter o -> Splitter (next_orientation o)
        (* Never placed, by the representation invariant. *)
        | Source _ | Wall | Target _ -> pc
      in
      PosMap.add p (Placed turned) cells)

let remove b p = change_placed b p (fun _ cells -> PosMap.remove p cells)

(* Every non-empty cell with what it holds, in reading order. *)
let pieces b =
  List.filter_map
    (function
      | p, (Fixed pc | Placed pc) -> Some (p, pc, lookup b p) | _, Empty -> None)
    (PosMap.bindings b.cells)

let sources b =
  List.filter_map
    (function p, Source (d, c), _ -> Some (p, d, c) | _ -> None)
    (pieces b)

let targets b =
  List.filter_map
    (function p, Target c, _ -> Some (p, c) | _ -> None)
    (pieces b)

let placed b =
  List.filter_map
    (function p, pc, Placed _ -> Some (p, pc) | _ -> None)
    (pieces b)

let empty_cells b =
  List.concat_map
    (fun row ->
      List.filter_map
        (fun col ->
          let p = { row; col } in
          if lookup b p = Empty then Some p else None)
        (List.init b.cols Fun.id))
    (List.init b.rows Fun.id)
