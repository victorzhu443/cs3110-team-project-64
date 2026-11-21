open OUnit2
open Lumen

let renders_board_and_status _ =
  (* A points east. The white beam lights a, then continues into the empty cell. *)
  let game =
    "name: Render test\n\
     pieces: mirror\n\
     Aa.\n\
     A = source E white\n\
     a = target white\n" |> Level.of_string |> Test_util.assert_ok |> Game.start
  in
  assert_equal ~printer:Fun.id "@*-\nPieces left: mirror\nMoves: 0\n"
    (Render.render ~color:false game)

let () =
  run_test_tt_main
    ("render" >::: [ "renders board and status" >:: renders_board_and_status ])
