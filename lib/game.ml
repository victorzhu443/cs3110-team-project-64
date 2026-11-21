type t = Level.t

type move =
  | Place of Types.pos * Types.piece
  | Rotate of Types.pos
  | Remove of Types.pos

type command = Move of move | Help | Quit
type parse_error = Invalid_command | Parser_not_implemented

type move_error =
  | Piece_unavailable of Types.piece
  | Board_error of Board.error
  | Move_not_implemented

let start level = level
let board = Level.board
let pieces_left = Level.pieces
let move_count _ = 0
let is_won game = (Tracer.trace (board game)).all_lit
let parse_command _ = Error Parser_not_implemented
let apply _ _ = Error Move_not_implemented
