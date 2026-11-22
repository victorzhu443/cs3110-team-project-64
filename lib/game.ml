open Types

type t = { board : Board.t; pieces_left : piece list; move_count : int }

type move =
  | Place of Types.pos * Types.piece
  | Rotate of Types.pos
  | Remove of Types.pos

type command = Move of move | Help | Quit
type parse_error = Invalid_command
type move_error = Piece_unavailable of piece | Board_error of Board.error

let string_of_parse_error Invalid_command =
  "Invalid command. Type help for usage."

let string_of_move_error = function
  | Board_error error -> Board.string_of_error error
  | Piece_unavailable (Mirror _) -> "No mirror pieces left."
  | Piece_unavailable (Splitter _) -> "No splitter pieces left."
  | Piece_unavailable piece -> "No " ^ string_of_piece piece ^ " pieces left."

let start level =
  {
    board = Level.board level;
    pieces_left = Level.pieces level;
    move_count = 0;
  }

let board game = game.board
let pieces_left game = game.pieces_left
let move_count game = game.move_count
let is_won game = (Tracer.trace (board game)).all_lit

let words line =
  line
  |> String.map (function
    | '\t' | '\n' | '\r' | '\011' | '\012' -> ' '
    | ch -> ch)
  |> String.split_on_char ' '
  |> List.filter (fun word -> word <> "")

let parse_orientation = function
  | "-" -> Some Types.Horizontal
  | "/" -> Some Slash
  | "|" -> Some Vertical
  | "\\" -> Some Backslash
  | _ -> None

let parse_coordinate word =
  if
    word <> ""
    && String.for_all (function '0' .. '9' -> true | _ -> false) word
  then int_of_string_opt word
  else None

let ( let* ) = Result.bind

let parse_position row col =
  match (parse_coordinate row, parse_coordinate col) with
  | Some row, Some col -> Ok { row; col }
  | _ -> Error Invalid_command

let parse_command line =
  match words line with
  | [ "help" ] -> Ok Help
  | [ "quit" ] -> Ok Quit
  | [ "rotate"; row; col ] ->
      let* pos = parse_position row col in
      Ok (Move (Rotate pos))
  | [ "remove"; row; col ] ->
      let* pos = parse_position row col in
      Ok (Move (Remove pos))
  | [ "place"; row; col; kind; symbol ] -> (
      let* pos = parse_position row col in
      match (kind, parse_orientation symbol) with
      | "mirror", Some orientation ->
          Ok (Move (Place (pos, Mirror orientation)))
      | "splitter", Some orientation ->
          Ok (Move (Place (pos, Splitter orientation)))
      | _ -> Error Invalid_command)
  | _ -> Error Invalid_command

(* A level stocks every player piece in its horizontal orientation. *)
let inventory_piece = function
  | Mirror _ -> Mirror Horizontal
  | Splitter _ -> Splitter Horizontal
  | piece -> piece

let take_piece wanted inventory =
  let rec take before = function
    | [] -> None
    | piece :: rest when piece = wanted -> Some (List.rev_append before rest)
    | piece :: rest -> take (piece :: before) rest
  in
  take [] inventory

let board_result result =
  Result.map_error (fun error -> Board_error error) result

let apply game = function
  | Place (pos, piece) ->
      let* board = board_result (Board.place game.board pos piece) in
      let* pieces_left =
        Option.to_result ~none:(Piece_unavailable piece)
          (take_piece (inventory_piece piece) game.pieces_left)
      in
      Ok { board; pieces_left; move_count = game.move_count + 1 }
  | Rotate pos ->
      let* board = board_result (Board.rotate game.board pos) in
      Ok { game with board; move_count = game.move_count + 1 }
  | Remove pos -> (
      let* cell = board_result (Board.get game.board pos) in
      match cell with
      | Board.Placed piece ->
          let* board = board_result (Board.remove game.board pos) in
          let pieces_left = inventory_piece piece :: game.pieces_left in
          Ok { board; pieces_left; move_count = game.move_count + 1 }
      | Board.Empty | Board.Fixed _ ->
          Error (Board_error (Not_player_piece pos)))
