open Types

type segment = { at : pos; entered : dir; dir : dir; color : color }

type ending = { last : pos; heading : dir; beam_color : color; reason : stop }
and stop = Left_board | Hit_wall | Hit_mirror_edge | Looped

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
     direction lying along the line comes back unchanged; the tracer treats that
     case as the beam meeting the mirror edge-on, which stops it. *)
  let dr', dc' =
    match o with
    | Horizontal -> (-dr, dc)
    | Vertical -> (dr, -dc)
    | Slash -> (-dc, -dr)
    | Backslash -> (dc, dr)
  in
  dir_of_delta dr' dc'

(** [mix a b] is the color made by two beams together: each channel is on if it
    is on in either beam. *)
let mix (a : color) (b : color) : color =
  { r = a.r || b.r; g = a.g || b.g; b = a.b || b.b }

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
  (* The color reaching each target: the mix of every beam that passed
     through it so far. *)
  let arrivals : (pos, color) Hashtbl.t = Hashtbl.create 16 in
  (* A beam is in a loop when it is about to enter a cell travelling the same
     way as before. The table is per source: two different sources crossing one
     cell alike is not a loop, but a splitter's own branch coming back around
     is. *)
  let visited : (pos * dir, unit) Hashtbl.t = Hashtbl.create 64 in
  let record_segment at entered dir color =
    segments := { at; entered; dir; color } :: !segments
  in
  let record_ending last heading beam_color reason =
    endings := { last; heading; beam_color; reason } :: !endings
  in
  (* [walk ~first p d c] follows a beam that has just entered cell [p] heading
     [d]. On the source's own cell [first] is true, so the source does not act
     on its own beam. [emit] leaves a cell in a direction; [halt] ends the beam
     in the cell it is in. *)
  let rec walk ~(first : bool) (p : pos) (d : dir) (c : color) : unit =
    Hashtbl.replace visited (p, d) ();
    match if first then None else cell_at p with
    | Some Wall -> halt p d c Hit_wall
    | Some (Target _) ->
        let so_far = Hashtbl.find_opt arrivals p in
        Hashtbl.replace arrivals p
          (match so_far with None -> c | Some m -> mix m c);
        emit p d d c
    | Some (Mirror o) ->
        let out = reflect o d in
        (* Edge-on, the beam runs along the mirror's own line and stops. *)
        if out = d then halt p d c Hit_mirror_edge else emit p d out c
    | Some (Splitter o) ->
        let reflected = reflect o d in
        emit p d d c;
        (* Edge-on, the two ways out are the same way, so only one beam
           leaves. *)
        if reflected <> d then emit p d reflected c
    | Some (Source _) | None -> emit p d d c
  and emit (p : pos) (entered : dir) (out : dir) (c : color) : unit =
    record_segment p entered out c;
    let next = step p out in
    if not (in_bounds next) then record_ending p out c Left_board
    else if Hashtbl.mem visited (next, out) then record_ending p out c Looped
    else walk ~first:false next out c
  and halt (p : pos) (d : dir) (c : color) (reason : stop) : unit =
    record_segment p d d c;
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

let trace (b : Board.t) : result =
  trace_grid ~rows:(Board.rows b) ~cols:(Board.cols b) ~cell_at:(fun p ->
      match Board.get b p with
      | Ok (Board.Fixed piece | Board.Placed piece) -> Some piece
      | Ok Board.Empty | Error _ -> None)
