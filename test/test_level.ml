(* Tests for the level module. Placeholder from the project skeleton; Akshay
   replaces it with real tests. *)
open OUnit2

let tests =
  "test suite for level"
  >::: [ ("skeleton builds" >:: fun _ -> assert_equal 0 0) ]

let _ = run_test_tt_main tests
