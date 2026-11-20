(* Tests for the tracer module. Placeholder from the project skeleton; Anvi
   replaces it with real tests. *)
open OUnit2

let tests =
  "test suite for tracer"
  >::: [ ("skeleton builds" >:: fun _ -> assert_equal 0 0) ]

let _ = run_test_tt_main tests
