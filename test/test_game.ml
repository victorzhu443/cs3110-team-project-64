(* Tests for the game module. Placeholder from the project skeleton; Alex
   replaces it with real tests. *)
open OUnit2

let tests =
  "test suite for game"
  >::: [ ("skeleton builds" >:: fun _ -> assert_equal 0 0) ]

let _ = run_test_tt_main tests
