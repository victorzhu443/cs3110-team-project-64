open Types

type t = { name : string; board : Board.t; pieces : piece list }

type error =
  | File_error of string
  | Missing_name
  | Missing_pieces
  | Duplicate_header of int
  | Unknown_piece_name of string
  | Empty_grid
  | Ragged_grid of int
  | Unknown_char of char * pos
  | Undefined_letter of char
  | Bad_legend_line of int
  | No_source
  | No_target

let string_of_error = function
  | File_error msg -> "The level file could not be read: " ^ msg
  | Missing_name -> "The level has no \"name:\" line."
  | Missing_pieces -> "The level has no \"pieces:\" line."
  | Duplicate_header n ->
      Printf.sprintf "Line %d repeats a \"name:\" or \"pieces:\" line." n
  | Unknown_piece_name w ->
      Printf.sprintf
        "\"%s\" on the \"pieces:\" line is not \"mirror\" or \"splitter\"." w
  | Empty_grid -> "The level has no grid."
  | Ragged_grid n ->
      Printf.sprintf "Line %d is not the same width as the first grid row." n
  | Unknown_char (c, p) ->
      Printf.sprintf "'%c' at row %d, column %d does not mean anything." c p.row
        p.col
  | Undefined_letter c -> Printf.sprintf "'%c' has no legend line." c
  | Bad_legend_line n -> Printf.sprintf "Line %d is not a valid legend line." n
  | No_source -> "The level has no source."
  | No_target -> "The level has no target."

let name l = l.name
let board l = l.board
let pieces l = l.pieces
let ( let* ) = Result.bind

(* ---------- Splitting the text into its three parts ---------- *)

let starts_with prefix s =
  String.length s >= String.length prefix
  && String.sub s 0 (String.length prefix) = prefix

let after prefix s =
  String.trim
    (String.sub s (String.length prefix)
       (String.length s - String.length prefix))

(* A well-formed legend line looks like "X = ...". *)
let is_legend_line s = String.length s >= 4 && String.sub s 1 3 = " = "

(* No grid character is [=], so any line containing one is meant as a legend
   line, even a malformed one like "A= source E red". *)
let starts_legend s = String.contains s '='

type parts = {
  name_line : string option;
  pieces_line : string option;
  grid : (int * string) list;  (** Line number and text, top row first. *)
  legend : (int * string) list;  (** Line number and text. *)
}

(* Reads the non-blank lines in order: header lines first, then grid rows, then
   legend lines. Each header line may appear once. The first line containing
   [=] starts the legend, and every line after it belongs to the legend, so a
   stray grid row there is a bad legend line. Once the grid starts, a header
   line is just a bad grid row. *)
let split_parts text =
  let lines =
    List.mapi
      (fun i l -> (i + 1, String.trim l))
      (String.split_on_char '\n' text)
    |> List.filter (fun (_, l) -> l <> "")
  in
  let rec header acc = function
    | (n, l) :: rest when starts_with "name:" l ->
        if acc.name_line <> None then Error (Duplicate_header n)
        else header { acc with name_line = Some (after "name:" l) } rest
    | (n, l) :: rest when starts_with "pieces:" l ->
        if acc.pieces_line <> None then Error (Duplicate_header n)
        else header { acc with pieces_line = Some (after "pieces:" l) } rest
    | lines -> grid acc lines
  and grid acc = function
    | (_, l) :: _ as lines when starts_legend l ->
        Ok { acc with legend = lines }
    | row :: rest -> grid { acc with grid = acc.grid @ [ row ] } rest
    | [] -> Ok acc
  in
  header { name_line = None; pieces_line = None; grid = []; legend = [] } lines

(* ---------- Each part ---------- *)

let parse_pieces line =
  let words = List.filter (( <> ) "") (String.split_on_char ' ' line) in
  List.fold_left
    (fun acc w ->
      let* acc = acc in
      match w with
      | "mirror" -> Ok (acc @ [ Mirror Horizontal ])
      | "splitter" -> Ok (acc @ [ Splitter Horizontal ])
      | _ -> Error (Unknown_piece_name w))
    (Ok []) words

let all_colors =
  let b = [ false; true ] in
  List.concat_map
    (fun r -> List.concat_map (fun g -> List.map (fun b -> { r; g; b }) b) b)
    b

let find_by_name to_string values word =
  List.find_opt (fun v -> to_string v = word) values

(* "A = source E white" or "a = target red". The letter's case must match the
   kind of piece. *)
let parse_legend_line (n, l) =
  let bad = Error (Bad_legend_line n) in
  if not (is_legend_line l) then bad
  else
    let letter = l.[0] in
    let words =
      List.filter (( <> ) "") (String.split_on_char ' ' (after "X =" l))
    in
    match words with
    | [ "source"; d; c ] when 'A' <= letter && letter <= 'Z' -> (
        match
          ( find_by_name string_of_dir all_dirs d,
            find_by_name string_of_color all_colors c )
        with
        | Some d, Some c -> Ok (letter, Source (d, c))
        | _ -> bad)
    | [ "target"; c ] when 'a' <= letter && letter <= 'z' -> (
        match find_by_name string_of_color all_colors c with
        | Some c -> Ok (letter, Target c)
        | None -> bad)
    | _ -> bad

(* Every legend line, with no letter defined twice. *)
let parse_legend lines =
  List.fold_left
    (fun acc line ->
      let* acc = acc in
      let* letter, piece = parse_legend_line line in
      if List.mem_assoc letter acc then Error (Bad_legend_line (fst line))
      else Ok ((letter, piece) :: acc))
    (Ok []) lines

let check_widths = function
  | [] -> Error Empty_grid
  | (_, first) :: rest -> (
      let width = String.length first in
      match List.find_opt (fun (_, l) -> String.length l <> width) rest with
      | Some (n, _) -> Error (Ragged_grid n)
      | None -> Ok (List.length rest + 1, width))

(* The fixed piece a grid character stands for, or [None] for an empty cell. *)
let piece_of_char legend p c =
  match c with
  | '.' -> Ok None
  | '#' -> Ok (Some Wall)
  | '/' -> Ok (Some (Mirror Slash))
  | '\\' -> Ok (Some (Mirror Backslash))
  | '-' -> Ok (Some (Mirror Horizontal))
  | '|' -> Ok (Some (Mirror Vertical))
  | ('A' .. 'Z' | 'a' .. 'z') as c -> (
      match List.assoc_opt c legend with
      | Some piece -> Ok (Some piece)
      | None -> Error (Undefined_letter c))
  | c -> Error (Unknown_char (c, p))

(* Adds every grid character to the board, top row first, left to right. *)
let fill_board legend grid board =
  let add_row board (row, (_, line)) =
    let chars = List.init (String.length line) (fun col -> (col, line.[col])) in
    List.fold_left
      (fun board (col, c) ->
        let* board = board in
        let p = { row; col } in
        let* piece = piece_of_char legend p c in
        match piece with
        | None -> Ok board
        | Some piece -> (
            (* Cannot fail: [p] is in bounds and each cell is visited once. *)
            match Board.add_fixed board p piece with
            | Ok b -> Ok b
            | Error _ -> Error Empty_grid))
      (Ok board) chars
  in
  List.fold_left
    (fun board row ->
      let* board = board in
      add_row board row)
    (Ok board)
    (List.mapi (fun i line -> (i, line)) grid)

(* ---------- Putting it together ---------- *)

let of_string text =
  let* parts = split_parts text in
  let* name = Option.to_result ~none:Missing_name parts.name_line in
  let* pieces_line = Option.to_result ~none:Missing_pieces parts.pieces_line in
  let* pieces = parse_pieces pieces_line in
  let* rows, cols = check_widths parts.grid in
  let* legend = parse_legend parts.legend in
  let* board =
    match Board.empty rows cols with
    | Ok b -> Ok b
    (* Cannot happen: [check_widths] found at least one non-blank row. *)
    | Error _ -> Error Empty_grid
  in
  let* board = fill_board legend parts.grid board in
  if Board.sources board = [] then Error No_source
  else if Board.targets board = [] then Error No_target
  else Ok { name; board; pieces }

let load path =
  match In_channel.with_open_text path In_channel.input_all with
  | text -> of_string text
  | exception Sys_error msg -> Error (File_error msg)
