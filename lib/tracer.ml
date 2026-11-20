open Types

type segment = { at : pos; dir : dir; color : color }

type ending = { last : pos; heading : dir; beam_color : color; reason : stop }
and stop = Left_board | Hit_wall | Hit_target | Looped

type result = {
  segments : segment list;
  endings : ending list;
  targets : (pos * color option) list;
  all_lit : bool;
}

(** [delta d] is the change in row and column of one step in direction [d]. Row
    numbers grow downwards, so [N] decreases the row. *)
let delta (d : dir) : int * int =
  match d with
  | N -> (-1, 0)
  | NE -> (-1, 1)
  | E -> (0, 1)
  | SE -> (1, 1)
  | S -> (1, 0)
  | SW -> (1, -1)
  | W -> (0, -1)
  | NW -> (-1, -1)

(** [dir_of_delta dr dc] is the direction whose step is [(dr, dc)].

    @raise Invalid_argument if no direction has that step. *)
let dir_of_delta (dr : int) (dc : int) : dir =
  match List.find_opt (fun d -> delta d = (dr, dc)) all_dirs with
  | Some d -> d
  | None ->
      invalid_arg (Printf.sprintf "Tracer: (%d, %d) is not a direction" dr dc)

let reflect (o : orientation) (d : dir) : dir =
  let dr, dc = delta d in
  (* Mirroring a vector in a line: flip the component across the line. A
     direction lying along the line comes back unchanged, which is why a beam
     meeting a mirror edge-on carries straight on. *)
  let dr', dc' =
    match o with
    | Horizontal -> (-dr, dc)
    | Vertical -> (dr, -dc)
    | Slash -> (-dc, -dr)
    | Backslash -> (dc, dr)
  in
  dir_of_delta dr' dc'

let trace_grid ~(rows : int) ~(cols : int) ~(cell_at : pos -> piece option) :
    result =
  if rows < 1 || cols < 1 then
    invalid_arg
      "Tracer.trace_grid: the grid must have at least one row and one column";
  let in_bounds (p : pos) =
    p.row >= 0 && p.row < rows && p.col >= 0 && p.col < cols
  in
  let cells =
    List.concat_map
      (fun row -> List.init cols (fun col -> { row; col }))
      (List.init rows (fun row -> row))
  in
  let segments = ref [] and endings = ref [] in
  (* The first beam to reach a target is the one reported, so later arrivals do
     not overwrite it. *)
  let arrivals : (pos, color) Hashtbl.t = Hashtbl.create 16 in
  (* A beam is in a loop when it re-enters a cell travelling the same way. The
     table is per source: two different sources crossing one cell alike is not a
     loop, but a splitter's own branch coming back around is. *)
  let visited : (pos * dir, unit) Hashtbl.t = Hashtbl.create 64 in
  let record_segment at dir color =
    segments := { at; dir; color } :: !segments
  in
  let record_ending last heading beam_color reason =
    endings := { last; heading; beam_color; reason } :: !endings
  in
  (* [walk ~first p d c] follows a beam that is on cell [p] heading [d]. On the
     source's own cell [first] is true, so the source does not act on its own
     beam. [emit] leaves a cell in direction [d]; [halt] ends the beam there. *)
  let rec walk ~(first : bool) (p : pos) (d : dir) (c : color) : unit =
    if Hashtbl.mem visited (p, d) then record_ending p d c Looped
    else begin
      Hashtbl.replace visited (p, d) ();
      match if first then None else cell_at p with
      | Some Wall -> halt p d c Hit_wall
      | Some (Target _) ->
          if not (Hashtbl.mem arrivals p) then Hashtbl.replace arrivals p c;
          halt p d c Hit_target
      | Some (Mirror o) -> emit p (reflect o d) c
      | Some (Splitter o) ->
          let reflected = reflect o d in
          emit p d c;
          (* Edge-on, the two ways out are the same way, so only one beam
             leaves. *)
          if reflected <> d then emit p reflected c
      | Some (Source _) | None -> emit p d c
    end
  and emit (p : pos) (d : dir) (c : color) : unit =
    record_segment p d c;
    let next = step p d in
    if in_bounds next then walk ~first:false next d c
    else record_ending p d c Left_board
  and halt (p : pos) (d : dir) (c : color) (reason : stop) : unit =
    record_segment p d c;
    record_ending p d c reason
  in
  List.iter
    (fun p ->
      match cell_at p with
      | Some (Source (d, c)) ->
          Hashtbl.reset visited;
          walk ~first:true p d c
      | _ -> ())
    cells;
  let targets =
    List.filter_map
      (fun p ->
        match cell_at p with
        | Some (Target _) -> Some (p, Hashtbl.find_opt arrivals p)
        | _ -> None)
      cells
  in
  let lit p =
    match (cell_at p, Hashtbl.find_opt arrivals p) with
    | Some (Target wanted), Some arrived -> wanted = arrived
    | _ -> false
  in
  {
    segments = List.rev !segments;
    endings = List.rev !endings;
    targets;
    all_lit = List.for_all (fun (p, _) -> lit p) targets;
  }
