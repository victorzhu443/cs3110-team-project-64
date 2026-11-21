(** Tests for {!Lumen.Solver} (VIC-3).

    The search is deliberately free of the board and the tracer, so every
    expected answer here follows from the rules of the search itself rather than
    from a drawing of a level. Each case says how it was worked out.

    What is {i not} tested here, because it needs modules that are not on [main]
    yet: that a real level has a real solution, and that applying a solution and
    tracing it reports every target lit. That is VIC-4, and it arrives with
    [Board] (AKS-3) and [Tracer] (ANV-7). *)

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

let tests =
  "test suite for solver" >::: rotation_tests @ search_tests @ pruning_tests

let _ = run_test_tt_main tests
