(** Tests for {!Lumen.Solver} (VIC-3).

    The search is deliberately free of the board and the tracer, so every
    expected answer here follows from the rules of the search itself rather than
    from a drawing of a level. Each case says how it was worked out.

    The second half (VIC-4) tests {!Lumen.Solver.solve} on real levels. A
    solution is never compared with a stored answer: it is applied to the board
    and traced, and the test checks that every target is lit (D13). *)

open OUnit2
open Lumen
open Lumen.Types

let p row col = { row; col }

(** [printer_placements ps] shows a solution compactly, so a failing test says
    what came back rather than only that something did. *)
let printer_placements (ps : Solver.placement list option) : string =
  match ps with
  | None -> "None"
  | Some ps ->
      ps
      |> List.map (fun (q : Solver.placement) ->
          Printf.sprintf "%s@(%d,%d)" (string_of_piece q.piece) q.at.row
            q.at.col)
      |> String.concat " " |> Printf.sprintf "Some [%s]"

let red = { r = true; g = false; b = false }
let white = { r = true; g = true; b = true }

(* ----- rotations ----------------------------------------------------- *)

let rotation_tests =
  [
    ( "a mirror has four forms, its own first" >:: fun _ ->
      (* Board.rotate cycles Horizontal -> Backslash -> Vertical -> Slash, so a
         mirror already on Vertical is tried as V, S, H, B. *)
      assert_equal
        ~printer:(fun ps -> String.concat " " (List.map string_of_piece ps))
        [ Mirror Vertical; Mirror Slash; Mirror Horizontal; Mirror Backslash ]
        (Solver.rotations (Mirror Vertical)) );
    ( "a splitter rotates the way a mirror does" >:: fun _ ->
      assert_equal 4 (List.length (Solver.rotations (Splitter Horizontal)));
      assert_equal (Splitter Horizontal)
        (List.hd (Solver.rotations (Splitter Horizontal))) );
    ( "pieces the player cannot rotate have exactly one form" >:: fun _ ->
      assert_equal [ Wall ] (Solver.rotations Wall);
      assert_equal [ Target white ] (Solver.rotations (Target white));
      assert_equal [ Source (N, white) ] (Solver.rotations (Source (N, white)))
    );
  ]

(* ----- search -------------------------------------------------------- *)

let solve_for ~slots ~pieces ~solved = Solver.search ~slots ~pieces ~solved ()

let search_tests =
  [
    ( "no pieces to place is complete before it starts" >:: fun _ ->
      assert_equal ~printer:printer_placements (Some [])
        (solve_for ~slots:[ p 0 0 ] ~pieces:[] ~solved:(fun ps -> ps = [])) );
    ( "no pieces and a goal nothing satisfies is None" >:: fun _ ->
      assert_equal ~printer:printer_placements None
        (solve_for ~slots:[ p 0 0 ] ~pieces:[] ~solved:(fun _ -> false)) );
    ( "one piece finds the one cell the goal accepts" >:: fun _ ->
      (* Three cells, only (1,2) accepted, and it is last in the list, so the
         search has to reject the first two. *)
      let goal = p 1 2 in
      match
        solve_for
          ~slots:[ p 0 0; p 0 1; goal ]
          ~pieces:[ Mirror Horizontal ]
          ~solved:(function [ q ] -> q.Solver.at = goal | _ -> false)
      with
      | Some [ q ] -> assert_equal goal q.Solver.at
      | other ->
          assert_failure
            ("expected a placement at (1,2), got " ^ printer_placements other)
    );
    ( "the goal can demand an orientation the piece did not start in"
    >:: fun _ ->
      (* Given a Horizontal mirror but only Slash accepted, so it must rotate. *)
      assert_equal ~printer:printer_placements
        (Some [ { Solver.piece = Mirror Slash; at = p 0 0 } ])
        (solve_for
           ~slots:[ p 0 0 ]
           ~pieces:[ Mirror Horizontal ]
           ~solved:(function
             | [ q ] -> q.Solver.piece = Mirror Slash | _ -> false)) );
    ( "two pieces never share a cell" >:: fun _ ->
      match
        solve_for
          ~slots:[ p 0 0; p 0 1 ]
          ~pieces:[ Mirror Horizontal; Splitter Horizontal ]
          ~solved:(fun _ -> true)
      with
      | Some [ a; b ] ->
          assert_bool "distinct cells" (a.Solver.at <> b.Solver.at)
      | other ->
          assert_failure
            ("expected two placements, got " ^ printer_placements other) );
    ( "placements come back in the order the pieces were given" >:: fun _ ->
      match
        solve_for
          ~slots:[ p 0 0; p 0 1 ]
          ~pieces:[ Wall; Target red ]
          ~solved:(fun _ -> true)
      with
      | Some [ a; b ] ->
          assert_equal ~printer:string_of_piece Wall a.Solver.piece;
          assert_equal ~printer:string_of_piece (Target red) b.Solver.piece
      | other ->
          assert_failure
            ("expected two placements, got " ^ printer_placements other) );
    ( "more pieces than cells is None, not a crash" >:: fun _ ->
      assert_equal ~printer:printer_placements None
        (solve_for
           ~slots:[ p 0 0 ]
           ~pieces:[ Wall; Wall ]
           ~solved:(fun _ -> true)) );
    ( "a goal nothing satisfies is None after an exhaustive search" >:: fun _ ->
      assert_equal ~printer:printer_placements None
        (solve_for
           ~slots:[ p 0 0; p 0 1; p 1 0; p 1 1 ]
           ~pieces:[ Mirror Horizontal; Mirror Horizontal ]
           ~solved:(fun _ -> false)) );
    ( "the search is deterministic" >:: fun _ ->
      let run () =
        solve_for
          ~slots:[ p 0 0; p 0 1; p 1 0 ]
          ~pieces:[ Mirror Horizontal ]
          ~solved:(function [ q ] -> q.Solver.at <> p 0 0 | _ -> false)
      in
      assert_equal ~printer:printer_placements (run ()) (run ()) );
    ( "a repeated cell is refused rather than quietly used twice" >:: fun _ ->
      assert_raises
        (Invalid_argument "Solver.search: slots holds the same position twice")
        (fun () ->
          solve_for
            ~slots:[ p 0 0; p 0 0 ]
            ~pieces:[ Wall ]
            ~solved:(fun _ -> true)) );
  ]

(* ----- pruning ------------------------------------------------------- *)

let pruning_tests =
  [
    ( "the pruning hook narrows which cells are tried" >:: fun _ ->
      (* The goal accepts anything, so without the hook the answer would be
         (0,0), the first cell. Allowing only (0,1) proves the hook is used. *)
      assert_equal ~printer:printer_placements
        (Some [ { Solver.piece = Wall; at = p 0 1 } ])
        (Solver.search
           ~candidates:(fun _ _ -> [ p 0 1 ])
           ~slots:[ p 0 0; p 0 1 ]
           ~pieces:[ Wall ]
           ~solved:(fun _ -> true)
           ()) );
    ( "pruning away every cell gives None" >:: fun _ ->
      assert_equal ~printer:printer_placements None
        (Solver.search
           ~candidates:(fun _ _ -> [])
           ~slots:[ p 0 0; p 0 1 ]
           ~pieces:[ Wall ]
           ~solved:(fun _ -> true)
           ()) );
    ( "a cell the hook invents is ignored, not placed on" >:: fun _ ->
      assert_equal ~printer:printer_placements
        (Some [ { Solver.piece = Wall; at = p 0 0 } ])
        (Solver.search
           ~candidates:(fun _ free -> p 9 9 :: free)
           ~slots:[ p 0 0 ]
           ~pieces:[ Wall ]
           ~solved:(fun _ -> true)
           ()) );
    ( "the hook sees the placements made so far" >:: fun _ ->
      (* Two pieces, so the hook is asked twice: with nothing down, then with
         one piece down. *)
      let seen = ref [] in
      let watcher placed free =
        seen := List.length placed :: !seen;
        free
      in
      ignore
        (Solver.search ~candidates:watcher
           ~slots:[ p 0 0; p 0 1 ]
           ~pieces:[ Wall; Wall ]
           ~solved:(fun _ -> true)
           ());
      assert_equal
        ~printer:(fun l -> String.concat "," (List.map string_of_int l))
        [ 0; 1 ] (List.rev !seen) );
  ]

(* ----- solve, on real levels (VIC-4) --------------------------------- *)

(* The tutorial is levels/tutorial01.lvl, drawn in test_level.ml: a white source
   at (1,0) facing east, white targets at (4,3) and (5,5), three walls, and a
   splitter and a mirror to place. [dune test] runs in _build/default/test and
   the levels folder is copied next to it. *)
let tutorial_path = "../levels/tutorial01.lvl"

let tutorial () =
  Test_util.assert_ok ~msg:"tutorial01.lvl should load"
    (Level.load tutorial_path)

let level text =
  Test_util.assert_ok ~msg:"the level text should parse" (Level.of_string text)

(* One row, three cells: a red source facing east, an empty cell, a blue
   target. Whatever the one mirror does on the middle cell, the target gets red
   light or none, never blue, so there is no solution.

       A.b      A = source E red, b = target blue, pieces: mirror *)
let red_to_blue =
  "name: Red to blue\npieces: mirror\nA.b\nA = source E red\nb = target blue"

(* The same row with a red target and nothing to place: the beam already
   lights it, so placing nothing is the solution. *)
let already_lit =
  "name: Already lit\npieces:\nA.a\nA = source E red\na = target red"

(* The blue target again, but with nothing to place: no solution. *)
let nothing_to_place =
  "name: Nothing to place\npieces:\nA.b\nA = source E red\nb = target blue"

(* [kind piece] forgets the orientation, so a solution's pieces can be compared
   with the level's, which are all Horizontal until placed. *)
let kind = function
  | Mirror _ -> "mirror"
  | Splitter _ -> "splitter"
  | Source _ -> "source"
  | Wall -> "wall"
  | Target _ -> "target"

let solve_tutorial () =
  let l = tutorial () in
  let b = Level.board l in
  match Solver.solve b (Level.pieces l) with
  | Some ps -> (l, b, ps)
  | None -> assert_failure "the tutorial should have a solution"

let solve_tests =
  [
    ( "the tutorial has a solution, and applying it lights every target"
    >:: fun _ ->
      let _, b, ps = solve_tutorial () in
      let b' =
        Test_util.assert_ok ~msg:"the solution should apply" (Solver.apply b ps)
      in
      assert_bool "not every target is lit" (Tracer.trace b').all_lit );
    ( "the tutorial's solution uses exactly the pieces the level gives"
    >:: fun _ ->
      let l, _, ps = solve_tutorial () in
      let kinds pieces = List.sort compare (List.map kind pieces) in
      assert_equal ~printer:(String.concat " ")
        (kinds (Level.pieces l))
        (kinds (List.map (fun (q : Solver.placement) -> q.piece) ps)) );
    ( "the tutorial's solution goes only on cells that were empty" >:: fun _ ->
      let _, b, ps = solve_tutorial () in
      let empty = Board.empty_cells b in
      List.iter
        (fun (q : Solver.placement) ->
          assert_bool
            (Printf.sprintf "(%d,%d) was not empty" q.at.row q.at.col)
            (List.mem q.at empty))
        ps );
    ( "a red source cannot light a blue target, whatever one mirror does"
    >:: fun _ ->
      let l = level red_to_blue in
      assert_equal ~printer:printer_placements None
        (Solver.solve (Level.board l) (Level.pieces l)) );
    ( "a level whose targets are already lit is solved by placing nothing"
    >:: fun _ ->
      let l = level already_lit in
      assert_equal ~printer:printer_placements (Some [])
        (Solver.solve (Level.board l) (Level.pieces l)) );
    ( "a dark target and nothing to place has no solution" >:: fun _ ->
      let l = level nothing_to_place in
      assert_equal ~printer:printer_placements None
        (Solver.solve (Level.board l) (Level.pieces l)) );
    ( "apply refuses a second placement on the same cell" >:: fun _ ->
      let b = Level.board (tutorial ()) in
      let twice =
        [
          { Solver.piece = Splitter Backslash; at = p 1 3 };
          { Solver.piece = Mirror Backslash; at = p 1 3 };
        ]
      in
      assert_equal ~printer:Board.string_of_error
        (Board.Occupied (p 1 3))
        (Test_util.assert_error (Solver.apply b twice)) );
    ( "apply leaves the board it was given unchanged" >:: fun _ ->
      let b = Level.board (tutorial ()) in
      ignore
        (Solver.apply b [ { Solver.piece = Mirror Backslash; at = p 1 5 } ]);
      assert_equal [] (Board.placed b) );
  ]

let tests =
  "test suite for solver"
  >::: rotation_tests @ search_tests @ pruning_tests @ solve_tests

let _ = run_test_tt_main tests
