open Types

type error =
  | Invalid_size of int * int
  | Gave_up of int
  | Unreadable_text of Level.error

type construction = {
  rows : int;
  cols : int;
  fixed : (pos * piece) list;
  solution : (pos * piece) list;
  text : string;
}

let min_size = 4
let max_size = 20
let max_attempts = 1000

let string_of_error = function
  | Invalid_size (rows, cols) ->
      Printf.sprintf
        "A %d by %d board is not allowed: rows and columns must each be \
         between %d and %d."
        rows cols min_size max_size
  | Gave_up n -> Printf.sprintf "No valid level was found after %d tries." n
  | Unreadable_text e ->
      "The generated level could not be read back: " ^ Level.string_of_error e

(* ---------- What a generated level is made of ---------- *)

(* MS2 levels only need straight beams (D1), so sources point N, E, S or W. *)
let source_dirs = [| N; E; S; W |]

(* Every color except black (no channels on). *)
let source_colors =
  [|
    { r = true; g = false; b = false };
    { r = false; g = true; b = false };
    { r = false; g = false; b = true };
    { r = true; g = true; b = false };
    { r = true; g = false; b = true };
    { r = false; g = true; b = true };
    { r = true; g = true; b = true };
  |]

(* A straight beam meeting a diagonal piece turns 90 degrees. A Horizontal or
   Vertical one would send it straight back or stop it edge-on (D22), so the
   generator only places diagonal pieces. The player can still rotate them. *)
let player_pieces =
  [| Mirror Slash; Mirror Backslash; Splitter Slash; Splitter Backslash |]

(* About one cell in ten is a wall. *)
let wall_count rows cols = rows * cols / 10

(* Two or three pieces for the player to place. *)
let min_pieces = 2
let max_pieces = 3

(* ---------- The grid being built ---------- *)

(* The generator builds its level as a map from cells to pieces and traces it
   with [Tracer.trace_grid], so it needs no working [Board]. A cell missing
   from the map is empty. *)
module Grid = Map.Make (struct
  type t = pos

  let compare = compare
end)

(* Every cell in reading order. *)
let all_cells rows cols =
  List.concat_map
    (fun row -> List.init cols (fun col -> { row; col }))
    (List.init rows Fun.id)

let empty_cells rows cols grid =
  List.filter (fun p -> not (Grid.mem p grid)) (all_cells rows cols)

let trace rows cols grid =
  Tracer.trace_grid ~rows ~cols ~cell_at:(fun p -> Grid.find_opt p grid)

(* The cells some beam passes through, sorted and without duplicates, so the
   result does not depend on the order the tracer lists them in. *)
let beam_cells (r : Tracer.result) =
  List.sort_uniq compare
    (List.map (fun (s : Tracer.segment) -> s.at) r.segments)

let opposite = function
  | N -> S
  | NE -> SW
  | E -> W
  | SE -> NW
  | S -> N
  | SW -> NE
  | W -> E
  | NW -> SE

(* ---------- Small helpers ---------- *)

(* Inside one attempt, any failure just means "try another level", so the
   attempt works in [option]. *)
let ( let* ) = Option.bind
let pick rng arr = arr.(Random.State.int rng (Array.length arr))

let pick_list rng = function
  | [] -> None
  | l -> Some (List.nth l (Random.State.int rng (List.length l)))

(* ---------- The steps of one attempt ---------- *)

let rec add_walls rng rows cols grid n =
  if n = 0 then Some grid
  else
    let* p = pick_list rng (empty_cells rows cols grid) in
    add_walls rng rows cols (Grid.add p Wall grid) (n - 1)

(* Place [n] player pieces, one at a time, each on an empty cell that a beam
   currently passes through. Returns the grid and the placements in order. *)
let rec add_pieces rng rows cols grid placed n =
  if n = 0 then Some (grid, List.rev placed)
  else
    let cells =
      List.filter
        (fun p -> not (Grid.mem p grid))
        (beam_cells (trace rows cols grid))
    in
    let* p = pick_list rng cells in
    let piece = pick rng player_pieces in
    add_pieces rng rows cols (Grid.add p piece grid) ((p, piece) :: placed)
      (n - 1)

(* Where a beam's path ends, and so where its target goes: the last cell on the
   board for a beam that runs off the edge, and the cell before the wall for a
   beam that hits one (the ending names the wall's own cell). The cell must be
   empty. A loop or a mirror met edge-on gives [None]. *)
let target_spot grid (e : Tracer.ending) =
  let cell =
    match e.reason with
    | Tracer.Left_board -> Some e.last
    | Tracer.Hit_wall -> Some (step e.last (opposite e.heading))
    | Tracer.Hit_mirror_edge | Tracer.Looped -> None
  in
  match cell with
  | Some p when not (Grid.mem p grid) -> Some (p, e.beam_color)
  | _ -> None

(* A spot for every beam's end, or [None] if any beam has none. Two beams
   ending in the same cell share one target. *)
let target_spots grid (r : Tracer.result) =
  let spots = List.map (target_spot grid) r.endings in
  if List.mem None spots then None
  else
    let spots = List.sort_uniq compare (List.filter_map Fun.id spots) in
    let cells = List.map fst spots in
    if List.length (List.sort_uniq compare cells) <> List.length cells then None
    else Some spots

(* The guarantees promised in generator.mli, checked on the finished level
   rather than trusted. *)
let passes_checks rows cols level_grid solution =
  let unsolved_at_start = not (trace rows cols level_grid).all_lit in
  let full =
    List.fold_left (fun g (p, piece) -> Grid.add p piece g) level_grid solution
  in
  let r = trace rows cols full in
  let hit = beam_cells r in
  unsolved_at_start && r.all_lit
  && List.for_all (fun (p, _) -> List.mem p hit) solution

(* ---------- Writing the level as text ---------- *)

(* The word the [pieces:] line uses. The solution only holds mirrors and
   splitters. *)
let kind_word = function Splitter _ -> "splitter" | _ -> "mirror"

(* The level in the format of docs/LEVEL-FORMAT.md. The one source is [A]; each
   target color gets its own lowercase letter, in the order the colors first
   appear in reading order. *)
let to_text ~name rows cols grid solution =
  let target_colors =
    List.fold_left
      (fun acc (_, piece) ->
        match piece with
        | Target c when not (List.mem c acc) -> acc @ [ c ]
        | _ -> acc)
      [] (Grid.bindings grid)
  in
  let letter_of c =
    let rec index i = function
      | [] -> 0
      | x :: rest -> if x = c then i else index (i + 1) rest
    in
    Char.chr (Char.code 'a' + index 0 target_colors)
  in
  let char_at p =
    match Grid.find_opt p grid with
    | None -> '.'
    | Some Wall -> '#'
    | Some (Source _) -> 'A'
    | Some (Target c) -> letter_of c
    (* Never in a generated level's fixed pieces. *)
    | Some (Mirror _ | Splitter _) -> '.'
  in
  let row r = String.init cols (fun col -> char_at { row = r; col }) in
  let source_lines =
    List.filter_map
      (fun (_, piece) ->
        match piece with
        | Source (d, c) ->
            Some
              (Printf.sprintf "A = source %s %s" (string_of_dir d)
                 (string_of_color c))
        | _ -> None)
      (Grid.bindings grid)
  in
  let target_lines =
    List.map
      (fun c ->
        Printf.sprintf "%c = target %s" (letter_of c) (string_of_color c))
      target_colors
  in
  String.concat "\n"
    ([
       "name: " ^ name;
       "pieces: "
       ^ String.concat " " (List.map (fun (_, p) -> kind_word p) solution);
       "";
     ]
    @ List.init rows row @ [ "" ] @ source_lines @ target_lines)
  ^ "\n"

(* ---------- One attempt ---------- *)

(* Each random draw is its own [let] so the draws happen in a fixed order.
   OCaml does not promise the order in which a function's arguments are
   evaluated. *)
let attempt rng ~seed ~rows ~cols =
  let* source_cell = pick_list rng (all_cells rows cols) in
  let dir = pick rng source_dirs in
  let color = pick rng source_colors in
  let base = Grid.singleton source_cell (Source (dir, color)) in
  let* base = add_walls rng rows cols base (wall_count rows cols) in
  let n = min_pieces + Random.State.int rng (max_pieces - min_pieces + 1) in
  let* with_pieces, solution = add_pieces rng rows cols base [] n in
  let* spots = target_spots with_pieces (trace rows cols with_pieces) in
  let level_grid =
    List.fold_left (fun g (p, c) -> Grid.add p (Target c) g) base spots
  in
  if not (passes_checks rows cols level_grid solution) then None
  else
    let name = Printf.sprintf "generated-%d-%dx%d" seed rows cols in
    Some
      {
        rows;
        cols;
        (* [Grid.bindings] is sorted by row, then column: reading order. *)
        fixed = Grid.bindings level_grid;
        solution;
        text = to_text ~name rows cols level_grid solution;
      }

(* ---------- Public functions ---------- *)

let construct ~seed ~rows ~cols =
  let ok_size n = min_size <= n && n <= max_size in
  if not (ok_size rows && ok_size cols) then Error (Invalid_size (rows, cols))
  else
    let rng = Random.State.make [| seed |] in
    let rec loop tries =
      if tries = max_attempts then Error (Gave_up max_attempts)
      else
        match attempt rng ~seed ~rows ~cols with
        | Some c -> Ok c
        | None -> loop (tries + 1)
    in
    loop 0

let generate ~seed ~rows ~cols =
  Result.bind (construct ~seed ~rows ~cols) (fun c ->
      Result.map_error (fun e -> Unreadable_text e) (Level.of_string c.text))
