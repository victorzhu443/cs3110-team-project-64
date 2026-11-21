(* Tests for Board (task AKS-3).

   Every expected answer comes from the rules in board.mli, worked out by hand.
   Most tests use this 3 by 4 board, called [sample]:

       col: 0 1 2 3
     row 0: A . / b      A = source E white (fixed)    / = mirror Slash (placed)
     row 1: # . . .      b = target blue (fixed)       # = wall (fixed)
     row 2: . . . r      r = target red (fixed)
*)

open OUnit2
open Lumen
open Lumen.Types
open Test_util

let ok r = assert_ok ~msg:"expected Ok" r
let err r = assert_error ~msg:"expected an error" r
let board rows cols = ok (Board.empty rows cols)

let cell_printer = function
  | Board.Empty -> "Empty"
  | Board.Fixed pc -> "Fixed " ^ string_of_piece pc
  | Board.Placed pc -> "Placed " ^ string_of_piece pc

let assert_cell ?(msg = "cell") expected b p =
  assert_equal ~msg ~printer:cell_printer expected (ok (Board.get b p))

let assert_err expected r =
  assert_equal ~printer:Board.string_of_error expected (err r)

let source = Source (E, white)

let sample =
  let b = board 3 4 in
  let b = ok (Board.add_fixed b (pos 0 0) source) in
  let b = ok (Board.add_fixed b (pos 0 3) (Target blue)) in
  let b = ok (Board.add_fixed b (pos 1 0) Wall) in
  let b = ok (Board.add_fixed b (pos 2 3) (Target red)) in
  ok (Board.place b (pos 0 2) (Mirror Slash))

(* ---------- empty, size, get ---------- *)

let empty_tests =
  [
    ( "a 3x4 board has 3 rows and 4 columns" >:: fun _ ->
      let b = board 3 4 in
      assert_equal ~printer:string_of_int 3 (Board.rows b);
      assert_equal ~printer:string_of_int 4 (Board.cols b) );
    ( "every cell of a new board is empty" >:: fun _ ->
      let b = board 3 4 in
      assert_equal ~printer:string_of_int 12 (List.length (Board.empty_cells b));
      assert_cell Board.Empty b (pos 0 0);
      assert_cell Board.Empty b (pos 2 3) );
    ( "zero rows is a bad size" >:: fun _ ->
      assert_err (Board.Bad_size (0, 5)) (Board.empty 0 5) );
    ( "negative columns is a bad size" >:: fun _ ->
      assert_err (Board.Bad_size (2, -1)) (Board.empty 2 (-1)) );
    ( "a 1x1 board is allowed" >:: fun _ ->
      assert_equal 1 (List.length (Board.empty_cells (board 1 1))) );
    ( "in_bounds: corners in, one past each edge out" >:: fun _ ->
      let b = board 3 4 in
      assert_bool "(0,0)" (Board.in_bounds b (pos 0 0));
      assert_bool "(2,3)" (Board.in_bounds b (pos 2 3));
      assert_bool "(3,0)" (not (Board.in_bounds b (pos 3 0)));
      assert_bool "(0,4)" (not (Board.in_bounds b (pos 0 4)));
      assert_bool "(-1,0)" (not (Board.in_bounds b (pos (-1) 0)));
      assert_bool "(0,-1)" (not (Board.in_bounds b (pos 0 (-1)))) );
    ( "get off the board is Out_of_bounds" >:: fun _ ->
      assert_err (Board.Out_of_bounds (pos 3 0)) (Board.get sample (pos 3 0)) );
  ]

(* ---------- add_fixed and place ---------- *)

let placing_tests =
  [
    ( "fixed pieces are Fixed" >:: fun _ ->
      assert_cell (Board.Fixed source) sample (pos 0 0);
      assert_cell (Board.Fixed Wall) sample (pos 1 0);
      assert_cell (Board.Fixed (Target red)) sample (pos 2 3) );
    ( "a placed mirror is Placed" >:: fun _ ->
      assert_cell (Board.Placed (Mirror Slash)) sample (pos 0 2) );
    ( "placing a splitter on an empty cell works" >:: fun _ ->
      let b = ok (Board.place sample (pos 1 1) (Splitter Backslash)) in
      assert_cell (Board.Placed (Splitter Backslash)) b (pos 1 1) );
    ( "placing on a placed piece is Occupied" >:: fun _ ->
      assert_err
        (Board.Occupied (pos 0 2))
        (Board.place sample (pos 0 2) (Mirror Vertical)) );
    ( "placing on a fixed wall is Occupied" >:: fun _ ->
      assert_err
        (Board.Occupied (pos 1 0))
        (Board.place sample (pos 1 0) (Mirror Slash)) );
    ( "placing off the board is Out_of_bounds" >:: fun _ ->
      assert_err
        (Board.Out_of_bounds (pos 0 4))
        (Board.place sample (pos 0 4) (Mirror Slash)) );
    ( "players cannot place a wall, source or target" >:: fun _ ->
      assert_err (Board.Not_placeable Wall) (Board.place sample (pos 1 1) Wall);
      assert_err (Board.Not_placeable source)
        (Board.place sample (pos 1 1) source);
      assert_err (Board.Not_placeable (Target green))
        (Board.place sample (pos 1 1) (Target green)) );
    ( "placing right in front of a source is allowed" >:: fun _ ->
      let b = ok (Board.place sample (pos 0 1) (Mirror Backslash)) in
      assert_cell (Board.Placed (Mirror Backslash)) b (pos 0 1) );
    ( "add_fixed on an occupied cell is Occupied" >:: fun _ ->
      assert_err
        (Board.Occupied (pos 0 0))
        (Board.add_fixed sample (pos 0 0) Wall) );
    ( "add_fixed off the board is Out_of_bounds" >:: fun _ ->
      assert_err
        (Board.Out_of_bounds (pos (-1) 2))
        (Board.add_fixed sample (pos (-1) 2) Wall) );
  ]

(* ---------- rotate and remove ---------- *)

let rotate_n n b p =
  let rec go n b = if n = 0 then b else go (n - 1) (ok (Board.rotate b p)) in
  go n b

let changing_tests =
  [
    ( "rotate turns a mirror clockwise: - to \\ to | to / and back" >:: fun _ ->
      let p = pos 1 2 in
      let b = ok (Board.place sample p (Mirror Horizontal)) in
      assert_cell ~msg:"1 turn" (Board.Placed (Mirror Backslash))
        (rotate_n 1 b p) p;
      assert_cell ~msg:"2 turns" (Board.Placed (Mirror Vertical))
        (rotate_n 2 b p) p;
      assert_cell ~msg:"3 turns" (Board.Placed (Mirror Slash)) (rotate_n 3 b p)
        p;
      assert_cell ~msg:"4 turns" (Board.Placed (Mirror Horizontal))
        (rotate_n 4 b p) p );
    ( "rotate turns a splitter the same way" >:: fun _ ->
      let p = pos 1 2 in
      let b = ok (Board.place sample p (Splitter Slash)) in
      assert_cell (Board.Placed (Splitter Horizontal)) (rotate_n 1 b p) p );
    ( "rotating a fixed piece is Not_player_piece" >:: fun _ ->
      assert_err
        (Board.Not_player_piece (pos 1 0))
        (Board.rotate sample (pos 1 0)) );
    ( "rotating an empty cell is Not_player_piece" >:: fun _ ->
      assert_err
        (Board.Not_player_piece (pos 1 1))
        (Board.rotate sample (pos 1 1)) );
    ( "rotating off the board is Out_of_bounds" >:: fun _ ->
      assert_err (Board.Out_of_bounds (pos 5 5)) (Board.rotate sample (pos 5 5))
    );
    ( "remove empties the cell" >:: fun _ ->
      assert_cell Board.Empty (ok (Board.remove sample (pos 0 2))) (pos 0 2) );
    ( "a removed cell can be placed on again" >:: fun _ ->
      let b = ok (Board.remove sample (pos 0 2)) in
      let b = ok (Board.place b (pos 0 2) (Splitter Vertical)) in
      assert_cell (Board.Placed (Splitter Vertical)) b (pos 0 2) );
    ( "removing a fixed piece is Not_player_piece" >:: fun _ ->
      assert_err
        (Board.Not_player_piece (pos 2 3))
        (Board.remove sample (pos 2 3)) );
    ( "removing from an empty cell is Not_player_piece" >:: fun _ ->
      assert_err
        (Board.Not_player_piece (pos 2 0))
        (Board.remove sample (pos 2 0)) );
    ( "removing off the board is Out_of_bounds" >:: fun _ ->
      assert_err
        (Board.Out_of_bounds (pos 0 (-1)))
        (Board.remove sample (pos 0 (-1))) );
  ]

(* ---------- The old board never changes (D4) ---------- *)

let unchanged_tests =
  [
    ( "place leaves the old board unchanged" >:: fun _ ->
      ignore (ok (Board.place sample (pos 1 1) (Mirror Slash)));
      assert_cell Board.Empty sample (pos 1 1) );
    ( "rotate leaves the old board unchanged" >:: fun _ ->
      ignore (ok (Board.rotate sample (pos 0 2)));
      assert_cell (Board.Placed (Mirror Slash)) sample (pos 0 2) );
    ( "remove leaves the old board unchanged" >:: fun _ ->
      ignore (ok (Board.remove sample (pos 0 2)));
      assert_cell (Board.Placed (Mirror Slash)) sample (pos 0 2) );
    ( "add_fixed leaves the old board unchanged" >:: fun _ ->
      ignore (ok (Board.add_fixed sample (pos 1 1) Wall));
      assert_cell Board.Empty sample (pos 1 1) );
  ]

(* ---------- Lists, in reading order ---------- *)

let pos_list_printer ps = String.concat "; " (List.map string_of_pos ps)

let list_tests =
  [
    ( "sources" >:: fun _ ->
      assert_equal [ (pos 0 0, E, white) ] (Board.sources sample) );
    ( "targets, in reading order" >:: fun _ ->
      assert_equal [ (pos 0 3, blue); (pos 2 3, red) ] (Board.targets sample) );
    ( "placed" >:: fun _ ->
      assert_equal [ (pos 0 2, Mirror Slash) ] (Board.placed sample) );
    ( "empty_cells, in reading order" >:: fun _ ->
      assert_equal ~printer:pos_list_printer
        [ pos 0 1; pos 1 1; pos 1 2; pos 1 3; pos 2 0; pos 2 1; pos 2 2 ]
        (Board.empty_cells sample) );
    ( "placed is empty on a board with only fixed pieces" >:: fun _ ->
      assert_equal [] (Board.placed (ok (Board.remove sample (pos 0 2)))) );
  ]

let suite =
  "test suite for board"
  >::: empty_tests @ placing_tests @ changing_tests @ unchanged_tests
       @ list_tests

let () = run_test_tt_main suite
