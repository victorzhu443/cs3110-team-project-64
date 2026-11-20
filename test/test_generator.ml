(* Tests for Generator (tasks SOH-1 and SOH-4).

   Every check is a rule stated in generator.mli that must hold for every seed
   (D13: a generator result is checked by a property). No expected value comes
   from running the generator and copying what it printed. *)

open OUnit2
open Lumen
open Lumen.Types

let seeds = List.init 200 (fun i -> i + 1)
let say seed what = Printf.sprintf "seed %d: %s" seed what
let where p = Test_util.string_of_pos p

let construct_ok ~seed ~rows ~cols =
  match Generator.construct ~seed ~rows ~cols with
  | Ok c -> c
  | Error e -> assert_failure (say seed (Generator.string_of_error e))

(* Each size's 200 constructions are built once and shared by the tests. *)
let memo = Hashtbl.create 4

let constructions rows cols =
  match Hashtbl.find_opt memo (rows, cols) with
  | Some l -> l
  | None ->
      let l =
        List.map (fun seed -> (seed, construct_ok ~seed ~rows ~cols)) seeds
      in
      Hashtbl.add memo (rows, cols) l;
      l

let for_each_seed rows cols check =
  List.iter (fun (seed, c) -> check seed c) (constructions rows cols)

(* [trace c pieces] traces [pieces] on a grid the size of [c], as
   generator.mli defines "tracing". *)
let trace (c : Generator.construction) pieces =
  Tracer.trace_grid ~rows:c.rows ~cols:c.cols ~cell_at:(fun p ->
      List.assoc_opt p pieces)

let kind = function
  | Mirror _ -> "mirror"
  | Splitter _ -> "splitter"
  | Source _ | Wall | Target _ -> "not a player piece"

(* ---------- Properties that hold for every seed ---------- *)

let right_size rows cols _ =
  for_each_seed rows cols (fun seed (c : Generator.construction) ->
      assert_equal ~msg:(say seed "rows") ~printer:string_of_int rows c.rows;
      assert_equal ~msg:(say seed "cols") ~printer:string_of_int cols c.cols)

let cells_on_grid_and_distinct rows cols _ =
  for_each_seed rows cols (fun seed (c : Generator.construction) ->
      let cells = List.map fst c.fixed @ List.map fst c.solution in
      List.iter
        (fun p ->
          assert_bool
            (say seed (where p ^ " is off the grid"))
            (0 <= p.row && p.row < rows && 0 <= p.col && p.col < cols))
        cells;
      assert_equal
        ~msg:(say seed "a cell is used twice")
        (List.length cells)
        (List.length (List.sort_uniq compare cells)))

let fixed_pieces_are_right rows cols _ =
  for_each_seed rows cols (fun seed (c : Generator.construction) ->
      let sources =
        List.filter_map
          (function _, Source (d, col) -> Some (d, col) | _ -> None)
          c.fixed
      in
      (match sources with
      | [ (d, col) ] ->
          assert_bool
            (say seed "the source does not point N, E, S or W")
            (List.mem d [ N; E; S; W ]);
          assert_bool (say seed "the source is black") (col <> Test_util.black)
      | _ ->
          assert_failure
            (say seed (Printf.sprintf "%d sources" (List.length sources))));
      assert_bool (say seed "no targets")
        (List.exists (function _, Target _ -> true | _ -> false) c.fixed);
      List.iter
        (fun (p, piece) ->
          match piece with
          | Source _ | Target _ | Wall -> ()
          | Mirror _ | Splitter _ ->
              assert_failure
                (say seed ("a player piece is fixed at " ^ where p)))
        c.fixed)

let solution_pieces_are_right rows cols _ =
  for_each_seed rows cols (fun seed (c : Generator.construction) ->
      let n = List.length c.solution in
      assert_bool
        (say seed (Printf.sprintf "%d pieces, not 2 or 3" n))
        (n = 2 || n = 3);
      List.iter
        (fun (p, piece) ->
          match piece with
          | Mirror (Slash | Backslash) | Splitter (Slash | Backslash) -> ()
          | _ ->
              assert_failure
                (say seed ("not a diagonal mirror or splitter at " ^ where p)))
        c.solution)

(* The main promise of backwards construction. *)
let solution_lights_every_target rows cols _ =
  for_each_seed rows cols (fun seed (c : Generator.construction) ->
      assert_bool
        (say seed "the solution does not light every target")
        (trace c (c.fixed @ c.solution)).all_lit)

let every_piece_is_hit rows cols _ =
  for_each_seed rows cols (fun seed (c : Generator.construction) ->
      let hit =
        List.map
          (fun (s : Tracer.segment) -> s.at)
          (trace c (c.fixed @ c.solution)).segments
      in
      List.iter
        (fun (p, _) ->
          assert_bool
            (say seed ("no beam reaches the piece at " ^ where p))
            (List.mem p hit))
        c.solution)

let not_solved_before_placing rows cols _ =
  for_each_seed rows cols (fun seed (c : Generator.construction) ->
      assert_bool
        (say seed "the level is already solved with no pieces placed")
        (not (trace c c.fixed).all_lit))

(* ---------- The text follows docs/LEVEL-FORMAT.md ---------- *)

let starts_with prefix s =
  String.length s >= String.length prefix
  && String.sub s 0 (String.length prefix) = prefix

let after prefix s =
  String.trim
    (String.sub s (String.length prefix)
       (String.length s - String.length prefix))

let is_legend_line s = String.length s >= 4 && String.sub s 1 3 = " = "

let text_matches rows cols _ =
  for_each_seed rows cols (fun seed (c : Generator.construction) ->
      let lines =
        List.filter
          (fun l -> String.trim l <> "")
          (String.split_on_char '\n' c.text)
      in
      let names = List.filter (starts_with "name:") lines in
      let pieces = List.filter (starts_with "pieces:") lines in
      let legend = List.filter is_legend_line lines in
      let grid =
        List.filter
          (fun l ->
            not
              (starts_with "name:" l || starts_with "pieces:" l
             || is_legend_line l))
          lines
      in
      assert_equal ~msg:(say seed "name: lines") 1 (List.length names);
      (match pieces with
      | [ line ] ->
          assert_equal
            ~msg:(say seed "the pieces: line")
            ~printer:(String.concat " ")
            (List.map (fun (_, p) -> kind p) c.solution)
            (List.filter (( <> ) "")
               (String.split_on_char ' ' (after "pieces:" line)))
      | _ -> assert_failure (say seed "not exactly one pieces: line"));
      assert_equal ~msg:(say seed "grid rows") ~printer:string_of_int rows
        (List.length grid);
      (* Each letter has exactly one legend line, and it is [expected]. *)
      let check_legend letter expected =
        match List.filter (fun l -> l.[0] = letter) legend with
        | [ l ] ->
            assert_equal ~msg:(say seed "legend line") ~printer:Fun.id expected
              l
        | ls ->
            assert_failure
              (say seed
                 (Printf.sprintf "%d legend lines for %c" (List.length ls)
                    letter))
      in
      List.iteri
        (fun row line ->
          assert_equal ~msg:(say seed "grid width") ~printer:string_of_int cols
            (String.length line);
          String.iteri
            (fun col ch ->
              let p = { row; col } in
              let wrong what = say seed (what ^ " at " ^ where p) in
              match List.assoc_opt p c.fixed with
              | None -> assert_equal ~msg:(wrong "not '.'") '.' ch
              | Some Wall -> assert_equal ~msg:(wrong "not '#'") '#' ch
              | Some (Source (d, col)) ->
                  assert_bool
                    (wrong "source not a capital")
                    ('A' <= ch && ch <= 'Z');
                  check_legend ch
                    (Printf.sprintf "%c = source %s %s" ch (string_of_dir d)
                       (string_of_color col))
              | Some (Target col) ->
                  assert_bool
                    (wrong "target not lowercase")
                    ('a' <= ch && ch <= 'z');
                  check_legend ch
                    (Printf.sprintf "%c = target %s" ch (string_of_color col))
              | Some (Mirror _ | Splitter _) ->
                  assert_failure (wrong "player piece in the level"))
            line)
        grid)

(* ---------- Seeds ---------- *)

let same_seed_same_level _ =
  List.iter
    (fun (seed, first) ->
      assert_equal
        ~msg:(say seed "a second run gave a different level")
        first
        (construct_ok ~seed ~rows:6 ~cols:6))
    (constructions 6 6)

(* A weak check that the seed is actually used: seeds 1 to 200 do not all give
   the same level. *)
let seeds_are_used _ =
  match constructions 6 6 with
  | [] -> assert_failure "no constructions"
  | (_, (first : Generator.construction)) :: rest ->
      assert_bool "all 200 seeds gave the same level"
        (List.exists
           (fun (_, (c : Generator.construction)) -> c.fixed <> first.fixed)
           rest)

(* ---------- Size limits ---------- *)

let rejects_size rows cols _ =
  match Generator.construct ~seed:1 ~rows ~cols with
  | Error (Generator.Invalid_size (r, c)) ->
      assert_equal ~msg:"reported size" (rows, cols) (r, c)
  | Error _ -> assert_failure "a different error instead of Invalid_size"
  | Ok _ -> assert_failure (Printf.sprintf "accepted a %dx%d board" rows cols)

let accepts_size ~seeds rows cols _ =
  List.iter (fun seed -> ignore (construct_ok ~seed ~rows ~cols)) seeds

let lo = Generator.min_size
let hi = Generator.max_size
let first n = List.init n (fun i -> i + 1)

let size_tests =
  [
    "rejects rows below min" >:: rejects_size (lo - 1) 6;
    "rejects cols below min" >:: rejects_size 6 (lo - 1);
    "rejects rows above max" >:: rejects_size (hi + 1) 6;
    "rejects cols above max" >:: rejects_size 6 (hi + 1);
    "rejects zero" >:: rejects_size 0 0;
    "rejects negative" >:: rejects_size (-3) 6;
    "accepts the smallest size" >:: accepts_size ~seeds:(first 20) lo lo;
    "accepts the largest size" >:: accepts_size ~seeds:(first 5) hi hi;
    "accepts a non-square board" >:: accepts_size ~seeds:(first 20) 5 9;
  ]

(* ---------- generate, through the real Level and Board ---------- *)

(* [Level] and [Board] are stubs that raise until AKS-3 and AKS-4 land. These
   tests skip themselves until then, and run on their own once the real modules
   are merged. *)
let level_ready =
  match Level.of_string "" with _ -> true | exception Failure _ -> false

let board_ready =
  match Board.empty 1 1 with _ -> true | exception Failure _ -> false

let generate_ok ~seed ~rows ~cols =
  match Generator.generate ~seed ~rows ~cols with
  | Ok l -> l
  | Error e -> assert_failure (say seed (Generator.string_of_error e))

let generate_reads_back _ =
  skip_if (not level_ready) "Level.of_string is still a stub (AKS-4)";
  List.iter
    (fun (seed, (c : Generator.construction)) ->
      let l = generate_ok ~seed ~rows:6 ~cols:6 in
      assert_equal ~msg:(say seed "pieces given") ~printer:(String.concat " ")
        (List.map (fun (_, p) -> kind p) c.solution)
        (List.map kind (Level.pieces l)))
    (constructions 6 6)

let generate_board_matches _ =
  skip_if (not (level_ready && board_ready)) "Level or Board is still a stub";
  List.iter
    (fun (seed, (c : Generator.construction)) ->
      let b = Level.board (generate_ok ~seed ~rows:6 ~cols:6) in
      assert_equal ~msg:(say seed "rows") 6 (Board.rows b);
      assert_equal ~msg:(say seed "cols") 6 (Board.cols b);
      for row = 0 to 5 do
        for col = 0 to 5 do
          let p = { row; col } in
          let expected =
            match List.assoc_opt p c.fixed with
            | None -> Ok Board.Empty
            | Some piece -> Ok (Board.Fixed piece)
          in
          assert_bool
            (say seed ("the cell at " ^ where p ^ " differs"))
            (Board.get b p = expected)
        done
      done)
    (constructions 6 6)

(* ---------- The suite ---------- *)

(* The seed properties run on 6x6 and 8x8, the sizes in Victor's timing
   experiment (VIC-6). *)
let property_tests (rows, cols) =
  let name s = Printf.sprintf "%dx%d, seeds 1-200: %s" rows cols s in
  [
    name "right size" >:: right_size rows cols;
    name "cells on the grid and distinct"
    >:: cells_on_grid_and_distinct rows cols;
    name "one source, targets, walls" >:: fixed_pieces_are_right rows cols;
    name "two or three diagonal pieces" >:: solution_pieces_are_right rows cols;
    name "solution lights every target"
    >:: solution_lights_every_target rows cols;
    name "every piece is hit by a beam" >:: every_piece_is_hit rows cols;
    name "not solved before placing" >:: not_solved_before_placing rows cols;
    name "text matches the level" >:: text_matches rows cols;
  ]

let suite =
  "generator"
  >::: property_tests (6, 6)
       @ property_tests (8, 8)
       @ [
           "same seed gives the same level" >:: same_seed_same_level;
           "different seeds are used" >:: seeds_are_used;
           "generate reads back the pieces" >:: generate_reads_back;
           "generate's board matches the construction"
           >:: generate_board_matches;
         ]
       @ size_tests

let () = run_test_tt_main suite
