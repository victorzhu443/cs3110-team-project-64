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
type parse_error = Invalid_command | Parser_not_implemented

(** Why a move could not be applied. *)
type move_error =
  | Piece_unavailable of Types.piece
  | Board_error of Board.error
  | Move_not_implemented

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
    [remove ROW COL], [help], and [quit]. Coordinates are zero-based, row first.
    [PIECE] is [mirror] or [splitter]. The orientation is one of [-], [/], [|],
    or the backslash character.

    Returns [Invalid_command] for malformed input. The ALX-1 stub returns
    [Parser_not_implemented]. *)

val apply : t -> move -> (t, move_error) result
(** [apply game move] returns the game after [move], with one move added to the
    count. Placement uses one piece of the requested kind regardless of its
    orientation. Removal returns one piece of that kind.

    Returns [Piece_unavailable] when the requested kind is out of stock or
    [Board_error] when the board rejects the move. The ALX-1 stub returns
    [Move_not_implemented]. *)
