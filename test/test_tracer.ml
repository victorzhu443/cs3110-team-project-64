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

(* ----- the hand-worked boards (ANV-6) -------------------------------- *)

(* Every board here is drawn, and its answer worked out by hand, in
   docs/tracer-cases/README.md; the expected values are copied from there.
   A path cell is written "(row,col) DIR color", or "(row,col) IN>OUT color"
   where a mirror or splitter turns the beam. Beams are listed in the order
   their sources are found, reading row by row. *)

let blue = { r = false; g = false; b = true }
let pos = Test_util.pos

(** [path_of r] is every segment of [r] in the notation above, in trace order.
*)
let path_of (r : Tracer.result) : string list =
  List.map
    (fun (s : Tracer.segment) ->
      let way =
        if s.entered = s.dir then string_of_dir s.dir
        else string_of_dir s.entered ^ ">" ^ string_of_dir s.dir
      in
      Printf.sprintf "%s %s %s" (string_of_pos s.at) way
        (string_of_color s.color))
    r.segments

(** [targets_of r] is each target as "(row,col) color", or "(row,col) none" if
    no beam reached it. *)
let targets_of (r : Tracer.result) : string list =
  List.map
    (fun (p, c) ->
      string_of_pos p ^ " "
      ^ match c with Some c -> string_of_color c | None -> "none")
    r.targets

(** [board_test name (rows, cols, pieces) ~path ~endings ~targets ~all_lit]
    traces the board and checks all four parts of the hand-worked answer. With
    [~any_order:true], the path and the endings are compared without regard to
    order, for a splitter, whose two branches the interface does not order. *)
let board_test ?(any_order = false) name (rows, cols, pieces) ~path ~endings
    ~targets ~all_lit =
  name >:: fun _ ->
  let r = trace_pieces rows cols pieces in
  let order l = if any_order then List.sort compare l else l in
  assert_equal ~msg:"path" ~printer:printer_strings (order path)
    (order (path_of r));
  assert_equal ~msg:"endings" ~printer:printer_strings (order endings)
    (order (endings_of r));
  assert_equal ~msg:"targets" ~printer:printer_strings targets (targets_of r);
  assert_equal ~msg:"all lit" ~printer:string_of_bool all_lit r.all_lit

(** The 3 by 3 board of boards 3 and 4: a mirror at (1,1) and one source. *)
let mirror_board o source = (3, 3, [ (pos 1 1, Mirror o); source ])

let hand_worked_tests =
  [
    board_test "board 1: a beam leaves the board"
      (4, 5, [ (pos 2 1, Source (E, red)) ])
      ~path:[ "(2,1) E red"; "(2,2) E red"; "(2,3) E red"; "(2,4) E red" ]
      ~endings:[ "(2,4) E left" ] ~targets:[] ~all_lit:true;
    board_test "board 2: a wall stops the beam in its own cell"
      (3, 5, [ (pos 1 0, Source (E, green)); (pos 1 3, Wall) ])
      ~path:
        [ "(1,0) E green"; "(1,1) E green"; "(1,2) E green"; "(1,3) E green" ]
      ~endings:[ "(1,3) E wall" ] ~targets:[] ~all_lit:true;
    board_test "board 3a: east into / turns north"
      (mirror_board Slash (pos 1 0, Source (E, red)))
      ~path:[ "(1,0) E red"; "(1,1) E>N red"; "(0,1) N red" ]
      ~endings:[ "(0,1) N left" ] ~targets:[] ~all_lit:true;
    board_test "board 3b: west into / turns south"
      (mirror_board Slash (pos 1 2, Source (W, green)))
      ~path:[ "(1,2) W green"; "(1,1) W>S green"; "(2,1) S green" ]
      ~endings:[ "(2,1) S left" ] ~targets:[] ~all_lit:true;
    board_test "board 3c: south into / turns west"
      (mirror_board Slash (pos 0 1, Source (S, blue)))
      ~path:[ "(0,1) S blue"; "(1,1) S>W blue"; "(1,0) W blue" ]
      ~endings:[ "(1,0) W left" ] ~targets:[] ~all_lit:true;
    board_test "board 3d: north into / turns east"
      (mirror_board Slash (pos 2 1, Source (N, red)))
      ~path:[ "(2,1) N red"; "(1,1) N>E red"; "(1,2) E red" ]
      ~endings:[ "(1,2) E left" ] ~targets:[] ~all_lit:true;
    board_test "board 4a: east into \\ turns south"
      (mirror_board Backslash (pos 1 0, Source (E, blue)))
      ~path:[ "(1,0) E blue"; "(1,1) E>S blue"; "(2,1) S blue" ]
      ~endings:[ "(2,1) S left" ] ~targets:[] ~all_lit:true;
    board_test "board 4b: south into \\ turns east"
      (mirror_board Backslash (pos 0 1, Source (S, green)))
      ~path:[ "(0,1) S green"; "(1,1) S>E green"; "(1,2) E green" ]
      ~endings:[ "(1,2) E left" ] ~targets:[] ~all_lit:true;
    board_test "board 5: edge-on stops; square-on comes back through its source"
      ( 5,
        5,
        [
          (pos 1 0, Source (E, red));
          (pos 1 2, Mirror Horizontal);
          (pos 3 1, Source (E, green));
          (pos 3 3, Mirror Vertical);
        ] )
      ~path:
        [
          "(1,0) E red";
          "(1,1) E red";
          "(1,2) E red";
          "(3,1) E green";
          "(3,2) E green";
          "(3,3) E>W green";
          "(3,2) W green";
          "(3,1) W green";
          "(3,0) W green";
        ]
      ~endings:[ "(1,2) E edge"; "(3,0) W left" ]
      ~targets:[] ~all_lit:true;
    board_test
      "board 6: a target of the beam's color lights, and the beam goes on"
      (3, 4, [ (pos 1 0, Source (E, blue)); (pos 1 2, Target blue) ])
      ~path:[ "(1,0) E blue"; "(1,1) E blue"; "(1,2) E blue"; "(1,3) E blue" ]
      ~endings:[ "(1,3) E left" ] ~targets:[ "(1,2) blue" ] ~all_lit:true;
    board_test "board 7: a target of another color stays dark"
      (3, 4, [ (pos 1 0, Source (E, red)); (pos 1 2, Target green) ])
      ~path:[ "(1,0) E red"; "(1,1) E red"; "(1,2) E red"; "(1,3) E red" ]
      ~endings:[ "(1,3) E left" ] ~targets:[ "(1,2) red" ] ~all_lit:false;
    board_test "board 8: through one target to a second"
      ( 3,
        5,
        [
          (pos 1 0, Source (E, green));
          (pos 1 2, Target green);
          (pos 1 4, Target green);
        ] )
      ~path:
        [
          "(1,0) E green";
          "(1,1) E green";
          "(1,2) E green";
          "(1,3) E green";
          "(1,4) E green";
        ]
      ~endings:[ "(1,4) E left" ]
      ~targets:[ "(1,2) green"; "(1,4) green" ]
      ~all_lit:true;
    board_test "board 9: red and green mix to light a yellow target"
      ( 4,
        4,
        [
          (pos 0 2, Source (S, red));
          (pos 2 0, Source (E, green));
          (pos 2 2, Target yellow);
        ] )
      ~path:
        [
          "(0,2) S red";
          "(1,2) S red";
          "(2,2) S red";
          "(3,2) S red";
          "(2,0) E green";
          "(2,1) E green";
          "(2,2) E green";
          "(2,3) E green";
        ]
      ~endings:[ "(3,2) S left"; "(2,3) E left" ]
      ~targets:[ "(2,2) yellow" ] ~all_lit:true;
    board_test "board 10: a beam passes through another source's cell"
      (* B at (2,0) comes before A at (2,2) in reading order. *)
      ( 4,
        4,
        [
          (pos 2 0, Source (E, green));
          (pos 2 2, Source (S, red));
          (pos 3 2, Target red);
        ] )
      ~path:
        [
          "(2,0) E green";
          "(2,1) E green";
          "(2,2) E green";
          "(2,3) E green";
          "(2,2) S red";
          "(3,2) S red";
        ]
      ~endings:[ "(2,3) E left"; "(3,2) S left" ]
      ~targets:[ "(3,2) red" ] ~all_lit:true;
    board_test ~any_order:true "board 11: a splitter sends the beam on and up"
      (3, 5, [ (pos 1 0, Source (E, red)); (pos 1 2, Splitter Slash) ])
      ~path:
        [
          "(1,0) E red";
          "(1,1) E red";
          "(1,2) E red";
          "(1,3) E red";
          "(1,4) E red";
          "(1,2) E>N red";
          "(0,2) N red";
        ]
      ~endings:[ "(1,4) E left"; "(0,2) N left" ]
      ~targets:[] ~all_lit:true;
    board_test "board 12: four mirrors make a loop"
      ( 5,
        5,
        [
          (pos 1 1, Mirror Slash);
          (pos 1 2, Source (E, blue));
          (pos 1 3, Mirror Backslash);
          (pos 3 1, Mirror Backslash);
          (pos 3 3, Mirror Slash);
        ] )
      ~path:
        [
          "(1,2) E blue";
          "(1,3) E>S blue";
          "(2,3) S blue";
          "(3,3) S>W blue";
          "(3,2) W blue";
          "(3,1) W>N blue";
          "(2,1) N blue";
          "(1,1) N>E blue";
        ]
      ~endings:[ "(1,1) E loop" ] ~targets:[] ~all_lit:true;
    board_test "board 13: a diagonal beam off a - mirror"
      (4, 5, [ (pos 0 0, Source (SE, blue)); (pos 2 2, Mirror Horizontal) ])
      ~path:
        [
          "(0,0) SE blue";
          "(1,1) SE blue";
          "(2,2) SE>NE blue";
          "(1,3) NE blue";
          "(0,4) NE blue";
        ]
      ~endings:[ "(0,4) NE left" ] ~targets:[] ~all_lit:true;
  ]

let tests =
  "test suite for tracer" >::: reflect_tests @ beam_tests @ hand_worked_tests

let _ = run_test_tt_main tests
