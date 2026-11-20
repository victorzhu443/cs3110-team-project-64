(** Builds puzzle levels that are solvable by construction.

    The generator works backwards (decision D9). It puts one light source and a
    few walls on an empty grid, places two or three of the player's pieces where
    the beam passes, traces the beams, and puts a target of the beam's color
    where each beam ends. Then it takes the pieces back off and gives them to
    the player. The targets sit exactly where those pieces send the light, so
    putting the pieces back lights every target.

    {1 How a level comes out}

    {!construct} builds the level as a list of pieces and as text in the level
    file format ([docs/LEVEL-FORMAT.md]), and traces it with
    {!Tracer.trace_grid}. Only {!generate} turns it into a {!Level.t}, by
    reading that text with {!Level.of_string}. So [construct] needs only the
    tracer, and a generated level can also be saved as a [.lvl] file.

    All randomness comes from the seed. The same seed and size always give the
    same level on the same OCaml version. Nothing here reads input or prints. *)

(** Why no level was produced. *)
type error =
  | Invalid_size of int * int
      (** [Invalid_size (rows, cols)]: a dimension is below {!min_size} or above
          {!max_size}. *)
  | Gave_up of int
      (** [Gave_up n]: [n] attempts were made and none passed every check. *)
  | Unreadable_text of Level.error
      (** Only from {!generate}: {!Level.of_string} refused the text that
          {!construct} wrote. That is a bug in the generator, not in the caller.
      *)

type construction = {
  rows : int;  (** The number of rows. *)
  cols : int;  (** The number of columns. *)
  fixed : (Types.pos * Types.piece) list;
      (** The level as the player first sees it: the source, the walls and the
          targets, in reading order (top row first, left to right). *)
  solution : (Types.pos * Types.piece) list;
      (** Where the generator put each player piece, in the order it placed
          them. It is one solution, not necessarily the only one. *)
  text : string;
      (** The level in the file format of [docs/LEVEL-FORMAT.md]. Its [pieces:]
          line names the kind of each piece in [solution], in the same order;
          the player chooses the orientations. *)
}
(** A generated level together with the placement it was built from. *)

val min_size : int
(** The smallest allowed number of rows or columns: 4. *)

val max_size : int
(** The largest allowed number of rows or columns: 20. *)

val max_attempts : int
(** How many candidate levels {!construct} tries before giving up. *)

val construct : seed:int -> rows:int -> cols:int -> (construction, error) result
(** [construct ~seed ~rows ~cols] builds a [rows] by [cols] level from [seed],
    together with the placement that solves it.

    Below, "tracing" a list of pieces means
    [Tracer.trace_grid ~rows ~cols ~cell_at], where [cell_at] looks each cell up
    in that list. Every [Ok c] satisfies all of the following:
    - [c.rows = rows] and [c.cols = cols]. Every cell in [c.fixed] and
      [c.solution] is on the grid, and no cell appears twice across the two
      lists.
    - [c.fixed] holds exactly one source, pointing [N], [E], [S] or [W], with a
      color other than black; at least one target; and otherwise only walls.
    - [c.solution] holds two or three pieces. Each is a [Mirror] or a [Splitter]
      in the [Slash] or [Backslash] orientation.
    - Tracing [c.fixed] together with [c.solution] lights every target, and a
      beam passes through every piece of [c.solution].
    - Tracing [c.fixed] alone does not light every target, so the puzzle is not
      already solved.

    Errors: [Invalid_size (rows, cols)] if [rows] or [cols] is outside
    [min_size .. max_size]; [Gave_up max_attempts] if no candidate passed these
    checks. Never [Unreadable_text]. *)

val generate : seed:int -> rows:int -> cols:int -> (Level.t, error) result
(** [generate ~seed ~rows ~cols] is [Level.of_string c.text] for the [c] that
    [construct ~seed ~rows ~cols] gives: the level the game shows the player,
    without the solution. Errors: as for {!construct}, and [Unreadable_text] if
    {!Level.of_string} refuses the text. *)

val string_of_error : error -> string
(** [string_of_error e] is a sentence describing [e], suitable to show a player.
*)
