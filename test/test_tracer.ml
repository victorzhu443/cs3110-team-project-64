(** Tests for {!Lumen.Tracer} (ANV-7 and ANV-8, taken by Victor as backup
    owner).

    Every board below is written out as text and small enough to follow by eye,
    and each case says what the beam should do before it says what is asserted.
    The expected answers were worked out from the drawings, not from running the
    tracer.

    The characters:

    {v
      .  empty          #  wall             T  target, white
      >  source east    <  source west      R  target, red
      ^  source north   v  source south
      /  mirror /       \  mirror \         -  mirror -       |  mirror |
      s  splitter /     b  splitter \
    v} *)

open OUnit2
open Lumen
open Lumen.Types

let white = { r = true; g = true; b = true }
let red = { r = true; g = false; b = false }
let green = { r = false; g = true; b = false }
let yellow = { r = true; g = true; b = false }

(** [piece_of_char c] is the piece the test grids write as [c]. *)
let piece_of_char (c : char) : piece option =
  match c with
  | '.' -> None
  | '#' -> Some Wall
  | 'T' -> Some (Target white)
  | 'R' -> Some (Target red)
  | '>' -> Some (Source (E, white))
  | '<' -> Some (Source (W, white))
  | '^' -> Some (Source (N, white))
  | 'v' -> Some (Source (S, white))
  | '/' -> Some (Mirror Slash)
  | '\\' -> Some (Mirror Backslash)
  | '-' -> Some (Mirror Horizontal)
  | '|' -> Some (Mirror Vertical)
  | 's' -> Some (Splitter Slash)
  | 'b' -> Some (Splitter Backslash)
  | 'h' -> Some (Splitter Horizontal)
  | _ -> invalid_arg (Printf.sprintf "test grid: unknown character %C" c)

(** [trace rows] traces the grid drawn by [rows], one string per row. *)
let trace (rows : string list) : Tracer.result =
  let height = List.length rows in
  let width = String.length (List.hd rows) in
  List.iteri
    (fun i r ->
      if String.length r <> width then
        invalid_arg (Printf.sprintf "test grid: row %d is a different width" i))
    rows;
  let cell_at (p : pos) = piece_of_char (List.nth rows p.row).[p.col] in
  Tracer.trace_grid ~rows:height ~cols:width ~cell_at

(** [trace_pieces rows cols pieces] traces a [rows] by [cols] grid holding
    exactly [pieces], for boards that need colors the characters above do not
    have. *)
let trace_pieces (rows : int) (cols : int) (pieces : (pos * piece) list) :
    Tracer.result =
  Tracer.trace_grid ~rows ~cols ~cell_at:(fun p -> List.assoc_opt p pieces)

let string_of_pos (p : pos) = Printf.sprintf "(%d,%d)" p.row p.col

(** [endings_of r] is each beam ending as "(row,col) DIR reason", so a failure
    prints something readable. *)
let endings_of (r : Tracer.result) : string list =
  List.map
    (fun (e : Tracer.ending) ->
      let reason =
        match e.reason with
        | Tracer.Left_board -> "left"
        | Tracer.Hit_wall -> "wall"
        | Tracer.Hit_mirror_edge -> "edge"
        | Tracer.Looped -> "loop"
      in
      Printf.sprintf "%s %s %s" (string_of_pos e.last) (string_of_dir e.heading)
        reason)
    r.endings

let printer_strings l = "[" ^ String.concat "; " l ^ "]"

(* ----- reflect, from the rule in tracer.mli -------------------------- *)

let reflect_tests =
  [
    ( "a horizontal mirror swaps north and south" >:: fun _ ->
      assert_equal ~printer:string_of_dir S (Tracer.reflect Horizontal N);
      assert_equal ~printer:string_of_dir N (Tracer.reflect Horizontal S);
      assert_equal ~printer:string_of_dir SE (Tracer.reflect Horizontal NE);
      assert_equal ~printer:string_of_dir SW (Tracer.reflect Horizontal NW) );
    ( "a vertical mirror swaps east and west" >:: fun _ ->
      assert_equal ~printer:string_of_dir W (Tracer.reflect Vertical E);
      assert_equal ~printer:string_of_dir E (Tracer.reflect Vertical W);
      assert_equal ~printer:string_of_dir NW (Tracer.reflect Vertical NE);
      assert_equal ~printer:string_of_dir SW (Tracer.reflect Vertical SE) );
    ( "a slash mirror turns east to north and south to west" >:: fun _ ->
      assert_equal ~printer:string_of_dir N (Tracer.reflect Slash E);
      assert_equal ~printer:string_of_dir E (Tracer.reflect Slash N);
      assert_equal ~printer:string_of_dir W (Tracer.reflect Slash S);
      assert_equal ~printer:string_of_dir S (Tracer.reflect Slash W);
      assert_equal ~printer:string_of_dir NW (Tracer.reflect Slash SE) );
    ( "a backslash mirror turns east to south and north to west" >:: fun _ ->
      assert_equal ~printer:string_of_dir S (Tracer.reflect Backslash E);
      assert_equal ~printer:string_of_dir W (Tracer.reflect Backslash N);
      assert_equal ~printer:string_of_dir E (Tracer.reflect Backslash S);
      assert_equal ~printer:string_of_dir SW (Tracer.reflect Backslash NE) );
    ( "a direction along the mirror's own line is unchanged" >:: fun _ ->
      (* The tracer treats this case as the beam meeting the mirror edge-on,
         which stops it (D22). *)
      assert_equal ~printer:string_of_dir E (Tracer.reflect Horizontal E);
      assert_equal ~printer:string_of_dir N (Tracer.reflect Vertical N);
      assert_equal ~printer:string_of_dir NE (Tracer.reflect Slash NE);
      assert_equal ~printer:string_of_dir SE (Tracer.reflect Backslash SE) );
    ( "reflecting twice returns the original direction" >:: fun _ ->
      List.iter
        (fun o ->
          List.iter
            (fun d ->
              assert_equal ~printer:string_of_dir d
                (Tracer.reflect o (Tracer.reflect o d)))
            all_dirs)
        [ Horizontal; Slash; Vertical; Backslash ] );
  ]

(* ----- beams --------------------------------------------------------- *)

let beam_tests =
  [
    ( "a beam crosses empty cells and leaves the board" >:: fun _ ->
      (* > . .   the beam leaves east from the last cell. *)
      let r = trace [ ">.." ] in
      assert_equal ~printer:printer_strings [ "(0,2) E left" ] (endings_of r);
      assert_equal ~printer:string_of_int 3 (List.length r.segments) );
    ( "a wall stops the beam at the wall" >:: fun _ ->
      (* > # .   the third cell is never reached. *)
      let r = trace [ ">#." ] in
      assert_equal ~printer:printer_strings [ "(0,1) E wall" ] (endings_of r);
      assert_equal ~printer:string_of_int 2 (List.length r.segments) );
    ( "a target of the beam's own color is lit, and the beam passes through"
    >:: fun _ ->
      (* > . T   the target does not stop the beam, so it leaves the board
         east from the target's own cell (D21). *)
      let r = trace [ ">.T" ] in
      assert_equal ~printer:printer_strings [ "(0,2) E left" ] (endings_of r);
      assert_equal ~printer:string_of_bool true r.all_lit;
      assert_equal [ ({ row = 0; col = 2 }, Some white) ] r.targets );
    ( "a target of another color is reached but not lit" >:: fun _ ->
      (* A white beam reaches a red target: the arrival is recorded, and
         all_lit is false because the colors differ. *)
      let r = trace [ ">.R" ] in
      assert_equal ~printer:string_of_bool false r.all_lit;
      assert_equal [ ({ row = 0; col = 2 }, Some white) ] r.targets );
    ( "a target no beam reaches reports no arrival" >:: fun _ ->
      (* The beam goes east along row 0; the target sits in row 1. *)
      let r = trace [ ">.."; "..T" ] in
      assert_equal ~printer:string_of_bool false r.all_lit;
      assert_equal [ ({ row = 1; col = 2 }, None) ] r.targets );
    ( "a backslash mirror turns the beam down into a target" >:: fun _ ->
      (* > \     east into \ becomes south,
         . T     so the beam reaches the target below the mirror. *)
      let r = trace [ ">\\"; ".T" ] in
      assert_equal ~printer:string_of_bool true r.all_lit;
      assert_equal ~printer:printer_strings [ "(1,1) S left" ] (endings_of r) );
    ( "a slash mirror turns the beam up and off the board" >:: fun _ ->
      (* > /   east into / becomes north, and row 0 is the top row. *)
      let r = trace [ ">/"; ".T" ] in
      assert_equal ~printer:string_of_bool false r.all_lit;
      assert_equal ~printer:printer_strings [ "(0,1) N left" ] (endings_of r) );
    ( "a beam edge-on to a mirror stops in the mirror's cell" >:: fun _ ->
      (* > - T   an eastward beam runs along a horizontal mirror's line, so it
         stops at (0,1) and the target is never reached (D22). *)
      let r = trace [ ">-T" ] in
      assert_equal ~printer:string_of_bool false r.all_lit;
      assert_equal ~printer:printer_strings [ "(0,1) E edge" ] (endings_of r);
      assert_equal [ ({ row = 0; col = 2 }, None) ] r.targets );
    ( "a beam square-on to a mirror goes straight back" >:: fun _ ->
      (* . > |   east into a vertical mirror comes back west, through the
         source's own cell, and leaves the board from (0,0). *)
      let r = trace [ ".>|" ] in
      assert_equal ~printer:printer_strings [ "(0,0) W left" ] (endings_of r) );
    ( "a splitter sends one beam two ways and lights both targets" >:: fun _ ->
      (* . T .   the / splitter at (1,1) passes the beam on east to (1,2)
         > s T   and also reflects it north to (0,1). *)
      let r = trace [ ".T."; ">sT" ] in
      assert_equal ~printer:string_of_bool true r.all_lit;
      assert_equal ~printer:string_of_int 2 (List.length r.targets);
      assert_equal ~printer:string_of_int 2 (List.length r.endings) );
    ( "a splitter edge-on sends only one beam" >:: fun _ ->
      (* > h T   a horizontal splitter reflects an eastward beam onto itself,
         so the two ways out are the same way and only one beam leaves. *)
      let r = trace [ ">hT" ] in
      assert_equal ~printer:printer_strings [ "(0,2) E left" ] (endings_of r);
      assert_equal ~printer:string_of_bool true r.all_lit );
    ( "a splitter against the board edge still splits" >:: fun _ ->
      (* > b .   east into \\ becomes south, and there is no row below, so one
         beam leaves east from (0,2) and the other leaves south from (0,1). *)
      let r = trace [ ">b." ] in
      assert_equal ~printer:printer_strings
        [ "(0,2) E left"; "(0,1) S left" ]
        (endings_of r) );
    ( "a beam that comes back the same way is a loop, not an endless trace"
    >:: fun _ ->
      (* . | > |   the source fires east into the right mirror, which sends it
         back west through its own cell to the left mirror, which sends it east
         again. Its next cell would be the source's, heading east, as at the
         start, so the beam stops in (0,1), the last cell of its path. *)
      let r = trace [ ".|>|" ] in
      assert_equal ~printer:printer_strings [ "(0,1) E loop" ] (endings_of r) );
    ( "a beam lights one target and passes on to light a second" >:: fun _ ->
      (* Board 8: > . T . T   both targets green, the source green, so both see
         green and both light. *)
      let r =
        trace_pieces 3 5
          [
            ({ row = 1; col = 0 }, Source (E, green));
            ({ row = 1; col = 2 }, Target green);
            ({ row = 1; col = 4 }, Target green);
          ]
      in
      assert_equal ~printer:string_of_bool true r.all_lit;
      assert_equal ~printer:printer_strings [ "(1,4) E left" ] (endings_of r) );
    ( "two beams crossing in a target mix their colors" >:: fun _ ->
      (* Board 9: a red beam going south and a green beam going east cross at
         (2,2). Red and green together make yellow, the target's color. *)
      let r =
        trace_pieces 4 4
          [
            ({ row = 0; col = 2 }, Source (S, red));
            ({ row = 2; col = 0 }, Source (E, green));
            ({ row = 2; col = 2 }, Target yellow);
          ]
      in
      assert_equal [ ({ row = 2; col = 2 }, Some yellow) ] r.targets;
      assert_equal ~printer:string_of_bool true r.all_lit );
    ( "a stray beam through a target spoils it" >:: fun _ ->
      (* As board 9, but the target is red: red and green make yellow, which
         is not red, so the target stays dark (D21). *)
      let r =
        trace_pieces 4 4
          [
            ({ row = 0; col = 2 }, Source (S, red));
            ({ row = 2; col = 0 }, Source (E, green));
            ({ row = 2; col = 2 }, Target red);
          ]
      in
      assert_equal ~printer:string_of_bool false r.all_lit );
    ( "a segment records the way in and the way out" >:: fun _ ->
      (* Board 3a: east into / at (1,1) turns north, so that cell is entered
         heading E and left heading N. *)
      let r =
        trace_pieces 3 3
          [
            ({ row = 1; col = 0 }, Source (E, red));
            ({ row = 1; col = 1 }, Mirror Slash);
          ]
      in
      let turn =
        List.find
          (fun (s : Tracer.segment) -> s.at = { row = 1; col = 1 })
          r.segments
      in
      assert_equal ~printer:string_of_dir E turn.entered;
      assert_equal ~printer:string_of_dir N turn.dir );
    ( "two sources are both traced" >:: fun _ ->
      (* > . T   and   T . <   one beam each, both lighting their target. *)
      let r = trace [ ">.T"; "T.<" ] in
      assert_equal ~printer:string_of_bool true r.all_lit;
      assert_equal ~printer:string_of_int 2 (List.length r.endings) );
    ( "a grid with no targets is lit, vacuously" >:: fun _ ->
      let r = trace [ ">.." ] in
      assert_equal [] r.targets;
      assert_equal ~printer:string_of_bool true r.all_lit );
    ( "a grid with no sources traces nothing" >:: fun _ ->
      let r = trace [ "..T" ] in
      assert_equal [] r.segments;
      assert_equal [] r.endings;
      assert_equal ~printer:string_of_bool false r.all_lit );
    ( "a grid must have a row and a column" >:: fun _ ->
      assert_raises
        (Invalid_argument
           "Tracer.trace_grid: the grid must have at least one row and one \
            column") (fun () ->
          Tracer.trace_grid ~rows:0 ~cols:3 ~cell_at:(fun _ -> None)) );
  ]

let tests = "test suite for tracer" >::: reflect_tests @ beam_tests
let _ = run_test_tt_main tests
