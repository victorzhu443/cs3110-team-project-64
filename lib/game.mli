(** Game state and typed commands for the Lumen terminal game. *)

type t
(** A game in progress, with its current board, remaining pieces, and move
    count. *)

(** A command that edits the board. Positions are zero-based. *)
type move =
  | Place of Types.pos * Types.piece
      (** Place a mirror or splitter in the given orientation. *)
  | Rotate of Types.pos  (** Rotate a placed piece 45 degrees clockwise. *)
  | Remove of Types.pos  (** Return a placed piece to the inventory. *)

(** A command read from the terminal. The executable handles help and quit. *)
type command = Move of move | Help | Quit

(** Why a line could not be parsed. *)
type parse_error = Invalid_command

(** Why a move could not be applied. *)
type move_error =
  | Piece_unavailable of Types.piece
  | Board_error of Board.error

val string_of_parse_error : parse_error -> string
(** [string_of_parse_error error] is the player-facing message for [error]. *)

val string_of_move_error : move_error -> string
(** [string_of_move_error error] is the player-facing message for [error]. Board
    errors use {!Board.string_of_error}. *)

val start : Level.t -> t
(** [start level] starts a game on [level]'s board with its full inventory and
    zero moves. *)

val board : t -> Board.t
(** [board game] is the game's current board. *)

val pieces_left : t -> Types.piece list
(** [pieces_left game] lists the game's available pieces. They can be placed in
    any orientation. *)

val move_count : t -> int
(** [move_count game] counts successful placements, rotations and removals. *)

val is_won : t -> bool
(** [is_won game] holds when the tracer reports that every target is lit. *)

val parse_command : string -> (command, parse_error) result
(** [parse_command line] reads one whitespace-separated command from [line]. The
    commands are [place ROW COL PIECE ORIENTATION], [rotate ROW COL],
    [remove ROW COL], [help], and [quit]. Coordinates are nonnegative decimal
    integers, zero-based and row first. [PIECE] is [mirror] or [splitter]. The
    orientation is one of [-], [/], [|], or the backslash character.

    Returns [Invalid_command] for malformed input. *)

val apply : t -> move -> (t, move_error) result
(** [apply game move] returns the game after [move], with one move added to the
    count. Placement uses one piece of the requested kind regardless of its
    orientation. Removal returns one piece of that kind in its inventory
    orientation.

    Returns [Piece_unavailable] when the requested kind is out of stock or
    [Board_error] when the board rejects the move. Board validation comes first.
    If a move fails, [game] is unchanged. *)
