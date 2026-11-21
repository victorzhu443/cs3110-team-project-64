(* Tests for Level (task AKS-4).

   Every expected answer comes from docs/LEVEL-FORMAT.md and level.mli, worked
   out by hand from the level text in each test. The tutorial level is
   levels/tutorial01.lvl:

         col 0123456
       row 0 ......#      A = source E white
       row 1 A......      a, b = target white
       row 2 .......      # = wall
       row 3 .#.....      pieces: splitter mirror
       row 4 ...a..#
       row 5 .....b.

   Its solution: a splitter \ at (1,3) and a mirror \ at (1,5). The beam goes
   east along row 1. The splitter sends one beam on east and turns a copy south
   down column 3, through a at (4,3). The mirror turns the east beam south down
   column 5, through b at (5,5). Both targets get white light. *)

open OUnit2
open Lumen
open Lumen.Types
open Test_util

(* [dune test] runs in _build/default/test; the levels folder is copied next to
   it by the [deps] field in test/dune. *)
let tutorial_path = "../levels/tutorial01.lvl"
let ok r = assert_ok ~msg:"expected the level to load" r
let err_printer = Level.string_of_error

let assert_level_error expected text =
  match Level.of_string text with
  | Ok _ -> assert_failure "expected an error, but the level loaded"
  | Error e -> assert_equal ~printer:err_printer expected e

let cell b p =
  match Board.get b p with
  | Ok c -> c
  | Error e -> assert_failure (Board.string_of_error e)

(* A small valid level that the error tests change one thing in. *)
let small =
  String.concat "\n"
    [
      "name: Small";
      "pieces: mirror";
      "";
      "A..a";
      "....";
      "";
      "A = source E red";
      "a = target red";
    ]

(* ---------- The tutorial ---------- *)

let tutorial () = ok (Level.load tutorial_path)

let tutorial_tests =
  [
    ( "tutorial name" >:: fun _ ->
      assert_equal ~printer:Fun.id "Tutorial 1" (Level.name (tutorial ())) );
    ( "tutorial is 6 rows by 7 columns" >:: fun _ ->
      let b = Level.board (tutorial ()) in
      assert_equal ~printer:string_of_int 6 (Board.rows b);
      assert_equal ~printer:string_of_int 7 (Board.cols b) );
    ( "tutorial gives a splitter and a mirror, in file order" >:: fun _ ->
      assert_equal
        [ Splitter Horizontal; Mirror Horizontal ]
        (Level.pieces (tutorial ())) );
    ( "tutorial source" >:: fun _ ->
      assert_equal
        [ (pos 1 0, E, white) ]
        (Board.sources (Level.board (tutorial ()))) );
    ( "tutorial targets, in reading order" >:: fun _ ->
      assert_equal
        [ (pos 4 3, white); (pos 5 5, white) ]
        (Board.targets (Level.board (tutorial ()))) );
    ( "tutorial walls" >:: fun _ ->
      let b = Level.board (tutorial ()) in
      List.iter
        (fun p -> assert_equal (Board.Fixed Wall) (cell b p))
        [ pos 0 6; pos 3 1; pos 4 6 ] );
    ( "tutorial starts with no player pieces and 36 empty cells" >:: fun _ ->
      let b = Level.board (tutorial ()) in
      assert_equal [] (Board.placed b);
      assert_equal ~printer:string_of_int 36 (List.length (Board.empty_cells b))
    );
    ( "tutorial is not solved before any piece is placed" >:: fun _ ->
      assert_bool "already solved"
        (not (Tracer.trace (Level.board (tutorial ()))).all_lit) );
    ( "tutorial's written solution lights every target" >:: fun _ ->
      let b = Level.board (tutorial ()) in
      let b = assert_ok (Board.place b (pos 1 3) (Splitter Backslash)) in
      let b = assert_ok (Board.place b (pos 1 5) (Mirror Backslash)) in
      assert_bool "not every target is lit" (Tracer.trace b).all_lit );
  ]

(* ---------- Reading valid text ---------- *)

let reading_tests =
  [
    ( "the small level loads" >:: fun _ ->
      let l = ok (Level.of_string small) in
      assert_equal ~printer:Fun.id "Small" (Level.name l);
      assert_equal [ Mirror Horizontal ] (Level.pieces l);
      assert_equal [ (pos 0 0, E, red) ] (Board.sources (Level.board l));
      assert_equal [ (pos 0 3, red) ] (Board.targets (Level.board l)) );
    ( "fixed mirror characters" >:: fun _ ->
      let l =
        ok
          (Level.of_string
             "name: M\npieces:\nA/\\-|a\nA = source E white\na = target white")
      in
      let b = Level.board l in
      assert_equal (Board.Fixed (Mirror Slash)) (cell b (pos 0 1));
      assert_equal (Board.Fixed (Mirror Backslash)) (cell b (pos 0 2));
      assert_equal (Board.Fixed (Mirror Horizontal)) (cell b (pos 0 3));
      assert_equal (Board.Fixed (Mirror Vertical)) (cell b (pos 0 4)) );
    ( "an empty pieces: line gives no pieces" >:: fun _ ->
      let l =
        ok
          (Level.of_string
             "name: N\npieces:\nAa\nA = source E red\na = target red")
      in
      assert_equal [] (Level.pieces l) );
    ( "header lines may come in either order" >:: fun _ ->
      let l =
        ok
          (Level.of_string
             "pieces: splitter\n\
              name: Swapped\n\
              Aa\n\
              A = source E red\n\
              a = target red")
      in
      assert_equal ~printer:Fun.id "Swapped" (Level.name l);
      assert_equal [ Splitter Horizontal ] (Level.pieces l) );
    ( "a letter used twice gives the same piece in both cells" >:: fun _ ->
      let l =
        ok
          (Level.of_string
             "name: T\npieces:\nAa.a\nA = source E red\na = target red")
      in
      assert_equal
        [ (pos 0 1, red); (pos 0 3, red) ]
        (Board.targets (Level.board l)) );
    ( "Windows line endings are fine" >:: fun _ ->
      let l =
        ok
          (Level.of_string
             "name: W\r\n\
              pieces: mirror\r\n\
              Aa\r\n\
              A = source N blue\r\n\
              a = target blue\r\n")
      in
      assert_equal ~printer:Fun.id "W" (Level.name l);
      assert_equal [ (pos 0 0, N, blue) ] (Board.sources (Level.board l)) );
  ]

(* ---------- Levels from Sohan's generator ---------- *)

(* The generator promises its text follows docs/LEVEL-FORMAT.md, so every
   generated level should load, with the same fixed pieces it was built from. *)
let generator_tests =
  [
    ( "generated levels load with the pieces they were built from" >:: fun _ ->
      List.iter
        (fun seed ->
          match Generator.construct ~seed ~rows:6 ~cols:6 with
          | Error e -> assert_failure (Generator.string_of_error e)
          | Ok c ->
              let l =
                assert_ok
                  ~msg:(Printf.sprintf "seed %d did not load" seed)
                  (Level.of_string c.text)
              in
              let fixed =
                List.filter_map
                  (fun (p, _) ->
                    match Board.get (Level.board l) p with
                    | Ok (Board.Fixed got) -> Some (p, got)
                    | _ -> None)
                  c.fixed
              in
              assert_equal
                ~msg:(Printf.sprintf "seed %d fixed pieces" seed)
                c.fixed fixed)
        (List.init 50 (fun i -> i + 1)) );
  ]

(* ---------- Each bad file gives its own error ---------- *)

let error_tests =
  [
    ( "no name: line" >:: fun _ ->
      assert_level_error Level.Missing_name
        "pieces: mirror\nAa\nA = source E red\na = target red" );
    ( "no pieces: line" >:: fun _ ->
      assert_level_error Level.Missing_pieces
        "name: X\nAa\nA = source E red\na = target red" );
    ( "a second name: line" >:: fun _ ->
      (* Line 1 name, line 2 pieces, line 3 the repeated name. *)
      assert_level_error (Level.Duplicate_header 3)
        "name: First\n\
         pieces: mirror\n\
         name: Second\n\
         Aa\n\
         A = source E red\n\
         a = target red" );
    ( "a second pieces: line" >:: fun _ ->
      assert_level_error (Level.Duplicate_header 2)
        "pieces: mirror\n\
         pieces: splitter\n\
         name: X\n\
         Aa\n\
         A = source E red\n\
         a = target red" );
    ( "a malformed first legend line is a bad legend line, not a ragged row"
    >:: fun _ ->
      (* Line 1 name, line 2 pieces, line 3 grid, line 4 "A= ..." (no space). *)
      assert_level_error (Level.Bad_legend_line 4)
        "name: X\npieces:\nAa\nA= source E red\na = target red" );
    ( "unknown piece name" >:: fun _ ->
      assert_level_error (Level.Unknown_piece_name "prism")
        "name: X\npieces: mirror prism\nAa\nA = source E red\na = target red" );
    ( "no grid" >:: fun _ ->
      assert_level_error Level.Empty_grid "name: X\npieces: mirror\n" );
    ( "ragged grid names the line of the short row" >:: fun _ ->
      (* Line 1 name, line 2 pieces, line 3 blank, lines 4 and 5 the grid. *)
      assert_level_error (Level.Ragged_grid 5)
        "name: X\npieces: mirror\n\nA..a\n...\nA = source E red\na = target red"
    );
    ( "unknown grid character" >:: fun _ ->
      assert_level_error
        (Level.Unknown_char ('?', pos 1 2))
        "name: X\npieces:\nA..a\n..?.\nA = source E red\na = target red" );
    ( "a letter with no legend line" >:: fun _ ->
      assert_level_error (Level.Undefined_letter 'b')
        "name: X\npieces:\nA.ab\nA = source E red\na = target red" );
    ( "a lowercase letter defined as a source" >:: fun _ ->
      (* Line 1 name, line 2 pieces, line 3 grid, line 4 the bad legend line. *)
      assert_level_error (Level.Bad_legend_line 4)
        "name: X\npieces:\nAa\na = source E red\nA = source E red" );
    ( "an unknown color in the legend" >:: fun _ ->
      assert_level_error (Level.Bad_legend_line 5)
        "name: X\npieces:\nAa\nA = source E red\na = target pink" );
    ( "an unknown direction in the legend" >:: fun _ ->
      assert_level_error (Level.Bad_legend_line 4)
        "name: X\npieces:\nAa\nA = source UP red\na = target red" );
    ( "a letter defined twice" >:: fun _ ->
      assert_level_error (Level.Bad_legend_line 6)
        "name: X\n\
         pieces:\n\
         Aa\n\
         A = source E red\n\
         a = target red\n\
         a = target blue" );
    ( "a grid row after the legend" >:: fun _ ->
      assert_level_error (Level.Bad_legend_line 6)
        "name: X\npieces:\nAa\nA = source E red\na = target red\n...." );
    ( "no source" >:: fun _ ->
      assert_level_error Level.No_source "name: X\npieces:\n.a\na = target red"
    );
    ( "no target" >:: fun _ ->
      assert_level_error Level.No_target
        "name: X\npieces:\nA.\nA = source E red" );
    ( "a missing file is a File_error" >:: fun _ ->
      match Level.load "../levels/does-not-exist.lvl" with
      | Error (Level.File_error _) -> ()
      | Error e -> assert_failure ("a different error: " ^ err_printer e)
      | Ok _ -> assert_failure "a missing file loaded" );
  ]

let suite =
  "test suite for level"
  >::: tutorial_tests @ reading_tests @ generator_tests @ error_tests

let () = run_test_tt_main suite
