(* Helpers shared by the test files (task SOH-1). Only things that several test
   files need belong here; helpers for one module stay in that module's test
   file. *)

open OUnit2
open Lumen.Types

(* [pos row col] is the cell at [row], [col]. Row 0 is the top. *)
let pos row col = { row; col }
let string_of_pos p = Printf.sprintf "(row %d, col %d)" p.row p.col

(* The eight colors by name, so a test can say [red] instead of writing out
   the record. *)
let black = { r = false; g = false; b = false }
let red = { r = true; g = false; b = false }
let green = { r = false; g = true; b = false }
let blue = { r = false; g = false; b = true }
let yellow = { r = true; g = true; b = false }
let magenta = { r = true; g = false; b = true }
let cyan = { r = false; g = true; b = true }
let white = { r = true; g = true; b = true }

(* Every public function that can fail returns a result (plan section 5.3).
   [assert_ok r] is the value inside [Ok], and fails the test on [Error].
   [assert_error r] is the error inside [Error], and fails the test on [Ok]. *)
let assert_ok ?(msg = "expected Ok, got Error") = function
  | Ok x -> x
  | Error _ -> assert_failure msg

let assert_error ?(msg = "expected Error, got Ok") = function
  | Ok _ -> assert_failure msg
  | Error e -> e
