(* VIC-6: how long does the brute-force solver take, and what does pruning buy?

   Not part of the build: it is kept here for the record. To run it, copy this
   folder to bench/ at the repository root, add the dune file shown in
   solver-timing.md, and run: dune exec bench/bench.exe
   from the repository root, on a branch that has Solver.solve.

   For each level it runs the search twice: as Solver.solve does it (every empty
   cell is a candidate), and with a pruning hook that offers only the cells a
   beam currently passes through. It counts the traces (calls of the goal
   predicate) and the CPU seconds, and gives up on a run after [cap] seconds. *)

open Lumen
open Lumen.Types

let cap = 60.0

exception Timed_out

type outcome = { traces : int; seconds : float; found : bool option }
(* [found = None] means the run hit the cap. *)

(* The goal predicate Solver.solve uses, with a counter and a deadline. *)
let run ?candidates (b : Board.t) (pieces : piece list) : outcome =
  let traces = ref 0 in
  let start = Sys.time () in
  let solved ps =
    incr traces;
    if Sys.time () -. start > cap then raise Timed_out;
    match Solver.apply b ps with
    | Ok b' -> (Tracer.trace b').all_lit
    | Error _ -> false
  in
  let slots = Board.empty_cells b in
  match Solver.search ?candidates ~slots ~pieces ~solved () with
  | Some ps ->
      (* Never trust the search: apply and trace the answer. *)
      let ok =
        match Solver.apply b ps with
        | Ok b' -> (Tracer.trace b').all_lit
        | Error _ -> false
      in
      if not ok then failwith "the search returned a non-solution";
      { traces = !traces; seconds = Sys.time () -. start; found = Some true }
  | None ->
      { traces = !traces; seconds = Sys.time () -. start; found = Some false }
  | exception Timed_out ->
      { traces = !traces; seconds = Sys.time () -. start; found = None }

(* Pruning: only the cells some beam passes through on the board as it stands
   with the pieces placed so far. A piece anywhere else cannot change the
   light. *)
let on_beam (b : Board.t) (placed : Solver.placement list)
    (remaining : pos list) =
  match Solver.apply b placed with
  | Error _ -> remaining
  | Ok b' ->
      let lit =
        List.map (fun (s : Tracer.segment) -> s.at) (Tracer.trace b').segments
      in
      List.filter (fun c -> List.mem c lit) remaining

(* ----- the levels ------------------------------------------------------ *)

type level = { label : string; text : string }

(* Generated levels: the first seeds, from 1 upward, whose level has [k]
   pieces. The same seed gives the same level on the same OCaml version. *)
let generated ~rows ~cols ~k ~want =
  let rec go seed acc =
    if List.length acc = want then List.rev acc
    else
      match Generator.construct ~seed ~rows ~cols with
      | Ok c when List.length c.solution = k ->
          go (seed + 1)
            ({
               label = Printf.sprintf "%dx%d seed %d" rows cols seed;
               text = c.text;
             }
            :: acc)
      | _ -> go (seed + 1) acc
  in
  go 1 []

(* Hand-drawn levels needing all four mirrors. The walls close every shorter
   route: the beam can only reach the target travelling west out of the
   bottom-right corner, which takes four turns from a source firing east along
   the top row. Intended solutions: 6x6: \ (0,2), \ (2,2), \ (2,5), / (5,5);
   8x8: \ (0,4), \ (3,4), \ (3,7), / (7,7). *)
let four_6 =
  {
    label = "6x6 hand-drawn";
    text =
      "name: Four mirrors 6\n\
       pieces: mirror mirror mirror mirror\n\
       A..#..\n\
       ......\n\
       ......\n\
       ......\n\
       ....#.\n\
       ...#a.\n\
       A = source E red\n\
       a = target red";
  }

let four_8 =
  {
    label = "8x8 hand-drawn";
    text =
      "name: Four mirrors 8\n\
       pieces: mirror mirror mirror mirror\n\
       A....#..\n\
       ........\n\
       ........\n\
       ........\n\
       ........\n\
       ........\n\
       ......#.\n\
       .....#a.\n\
       A = source E red\n\
       a = target red";
  }

let load { label; text } =
  match Level.of_string text with
  | Ok l -> (label, l)
  | Error e -> failwith (label ^ ": " ^ Level.string_of_error e)

(* ----- the runs -------------------------------------------------------- *)

let show label k mode (o : outcome) =
  let result =
    match o.found with
    | Some true -> "found"
    | Some false -> "none"
    | None -> Printf.sprintf "> %.0f s" cap
  in
  Printf.printf "| %s | %d | %s | %d | %.3f | %s |\n%!" label k mode o.traces
    o.seconds result

let () =
  (* How long is one trace? *)
  let _, tut =
    load
      {
        label = "tutorial";
        text =
          In_channel.with_open_text "levels/tutorial01.lvl" In_channel.input_all;
      }
  in
  let b = Level.board tut in
  let n = 10_000 in
  let t0 = Sys.time () in
  for _ = 1 to n do
    ignore (Tracer.trace b)
  done;
  Printf.printf "one trace of the tutorial board: %.1f microseconds\n\n%!"
    ((Sys.time () -. t0) /. float_of_int n *. 1e6);
  Printf.printf "| level | pieces | search | traces | CPU s | result |\n";
  Printf.printf "|---|---|---|---|---|---|\n%!";
  let sizes = [ 6; 8 ] in
  List.iter
    (fun s ->
      let levels =
        generated ~rows:s ~cols:s ~k:2 ~want:2
        @ generated ~rows:s ~cols:s ~k:3 ~want:2
        @ [ (if s = 6 then four_6 else four_8) ]
      in
      List.iter
        (fun lv ->
          let label, l = load lv in
          let b = Level.board l and pieces = Level.pieces l in
          let k = List.length pieces in
          show label k "every cell" (run b pieces);
          show label k "on a beam" (run ~candidates:(on_beam b) b pieces))
        levels)
    sizes
