open OUnit2
open Lumen
open Types
open Test_util

let start_game () =
  (* A..a: A sends white light east, and a needs white light. *)
  "name: Game test\n\
   pieces: mirror\n\
   A..a\n\
   A = source E white\n\
   a = target white\n" |> Level.of_string |> assert_ok |> Game.start

let first_cell = pos 0 1
let second_cell = pos 0 2

let place_mirror game =
  assert_ok (Game.apply game (Place (first_cell, Mirror Slash)))

let assert_state game inventory moves won =
  assert_equal ~msg:"pieces left"
    ~printer:(fun ps -> String.concat ", " (List.map string_of_piece ps))
    inventory (Game.pieces_left game);
  assert_equal ~msg:"move count" ~printer:string_of_int moves
    (Game.move_count game);
  assert_equal ~msg:"target lit" ~printer:string_of_bool won (Game.is_won game)

let test_place _ =
  let initial = start_game () in
  let placed = place_mirror initial in
  assert_state placed [] 1 false;
  assert_equal (Ok (Board.Placed (Mirror Slash)))
    (Board.get (Game.board placed) first_cell);
  assert_state initial [ Mirror Horizontal ] 0 true

let test_unavailable _ =
  let placed = place_mirror (start_game ()) in
  assert_equal (Error (Game.Piece_unavailable (Mirror Backslash)))
    (Game.apply placed (Place (second_cell, Mirror Backslash)));
  assert_equal (Ok Board.Empty) (Board.get (Game.board placed) second_cell);
  assert_state placed [] 1 false

let test_rotate_and_remove _ =
  let placed = place_mirror (start_game ()) in
  let rotated = assert_ok (Game.apply placed (Rotate first_cell)) in
  assert_state rotated [] 2 false;
  assert_equal (Ok (Board.Placed (Mirror Horizontal)))
    (Board.get (Game.board rotated) first_cell);
  let removed = assert_ok (Game.apply rotated (Remove first_cell)) in
  assert_state removed [ Mirror Horizontal ] 3 true;
  assert_equal (Ok Board.Empty) (Board.get (Game.board removed) first_cell)

let test_remove_returns_inventory_orientation _ =
  let placed = place_mirror (start_game ()) in
  let removed = assert_ok (Game.apply placed (Remove first_cell)) in
  assert_state removed [ Mirror Horizontal ] 2 true

let test_parse_valid _ =
  assert_equal
    (Ok (Game.Move (Place (first_cell, Mirror Slash))))
    (Game.parse_command "place 0 1 mirror /")

let test_parse_invalid _ =
  let error = assert_error (Game.parse_command "place 0 x mirror /") in
  assert_equal Game.Invalid_command error;
  assert_equal ~printer:Fun.id "Invalid command. Type help for usage."
    (Game.string_of_parse_error error)

let () =
  run_test_tt_main
    ("game"
    >::: [
           "placing consumes one piece" >:: test_place;
           "unavailable piece leaves the state unchanged" >:: test_unavailable;
           "rotating and removing count as moves" >:: test_rotate_and_remove;
           "removing restores the inventory orientation"
           >:: test_remove_returns_inventory_orientation;
           "parse a valid placement" >:: test_parse_valid;
           "reject an invalid coordinate" >:: test_parse_invalid;
         ])
