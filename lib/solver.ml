open Types

type placement = { piece : Types.piece; at : Types.pos }

(** [orientation_cycle] is the four orientations in the order {!Board.rotate}
    turns through them, so trying them in this order is the same as pressing
    rotate repeatedly. *)
let orientation_cycle = [ Horizontal; Backslash; Vertical; Slash ]

(** [cycle_from o] is {!orientation_cycle} rotated to begin at [o], so the
    orientation a piece already has is tried first and the rest follow in rotate
    order. *)
let cycle_from (o : orientation) : orientation list =
  let rec split before = function
    | [] -> orientation_cycle
    | x :: rest when x = o -> (x :: rest) @ List.rev before
    | x :: rest -> split (x :: before) rest
  in
  split [] orientation_cycle

let rotations (p : piece) : piece list =
  match p with
  | Mirror o -> List.map (fun o' -> Mirror o') (cycle_from o)
  | Splitter o -> List.map (fun o' -> Splitter o') (cycle_from o)
  | Source _ | Wall | Target _ -> [ p ]

(** [has_duplicate ps] is whether [ps] holds the same position twice. The search
    removes a cell once it is used, which is only sound if no cell is listed
    twice to begin with. *)
let has_duplicate (ps : pos list) : bool =
  let sorted = List.sort compare ps in
  let rec walk = function
    | a :: (b :: _ as rest) -> a = b || walk rest
    | _ -> false
  in
  walk sorted

let search ?(candidates = fun _ remaining -> remaining) ~(slots : pos list)
    ~(pieces : piece list) ~(solved : placement list -> bool) () :
    placement list option =
  if has_duplicate slots then
    invalid_arg "Solver.search: slots holds the same position twice";
  (* [go remaining_pieces free placed_rev] tries every way to put
     [remaining_pieces] on cells of [free]. [placed_rev] is what is already
     down, nearest placement first, so the answer is reversed on the way out. *)
  let rec go remaining_pieces free placed_rev =
    match remaining_pieces with
    | [] ->
        let ps = List.rev placed_rev in
        if solved ps then Some ps else None
    | piece :: rest ->
        let placed = List.rev placed_rev in
        (* The hook may narrow the cells; anything it invents that is not still
           free is dropped, as the interface says. *)
        let cells =
          candidates placed free |> List.filter (fun c -> List.mem c free)
        in
        let rec try_cells = function
          | [] -> None
          | cell :: others -> (
              let free' = List.filter (fun c -> c <> cell) free in
              let rec try_forms = function
                | [] -> None
                | form :: more -> (
                    match
                      go rest free' ({ piece = form; at = cell } :: placed_rev)
                    with
                    | Some answer -> Some answer
                    | None -> try_forms more)
              in
              match try_forms (rotations piece) with
              | Some answer -> Some answer
              | None -> try_cells others)
        in
        try_cells cells
  in
  go pieces slots []
