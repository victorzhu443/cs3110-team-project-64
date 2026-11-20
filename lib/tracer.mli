(** Following beams of light across a board.

    Every source emits a beam. A beam travels cell by cell in a straight line
    until something changes it: a wall stops it, a target absorbs it, a mirror
    turns it, a splitter turns it {i and} lets it carry on, and the edge of the
    board ends it. A target is lit when a beam of exactly its color reaches it.

    {1 Why this takes a lookup function rather than a board}

    The shared contract (plan section 5.3) says [Tracer] publishes [trace] from
    a board to a result. [Board] is stubbed on [main] — [Board.empty] raises —
    so a tracer written against it would compile and be impossible to test.

    So the tracing is published here as {!trace_grid}, which asks for the size
    of the grid and a function saying what sits on each cell. When AKS-3 lands,
    [trace] joins this interface as a wrapper:

    {[
    val trace : Board.t -> result
    (* = trace_grid ~rows:(Board.rows b) ~cols:(Board.cols b)
             ~cell_at:(fun p -> match Board.get b p with
                                | Ok (Board.Fixed pc | Board.Placed pc) -> Some pc
                                | _ -> None) *)
    ]}

    Keeping the split afterwards costs nothing and means the beam rules can be
    tested against a grid written out as text, which is what
    [test/test_tracer.ml] does.

    {1 The beam rules}

    A direction is reflected by mirroring it in the line the piece lies along:

    - [Horizontal] ([-]) swaps north and south: [N] and [S] exchange, [NE] and
      [SE] exchange, [NW] and [SW] exchange.
    - [Vertical] ([|]) swaps east and west: [E] and [W] exchange, [NE] and [NW]
      exchange, [SE] and [SW] exchange.
    - [Slash] ([/]) exchanges [N] with [E], [S] with [W], and [SE] with [NW].
    - [Backslash] ([\ ]) exchanges [N] with [W], [S] with [E], and [NE] with
      [SW].

    A beam travelling {i along} the line a mirror lies on — [E] or [W] into a
    [Horizontal] mirror, [NE] or [SW] into a [Slash] — is reflected onto itself,
    so it carries straight on. This answers the question section 5.4 left open
    about a beam meeting a mirror edge-on: it passes through. It is PROPOSED,
    not ratified; the alternative is to absorb such a beam, which would make the
    rule "a mirror sometimes blocks" and is harder to explain to a player.

    A splitter sends the beam both ways: the reflected direction and the
    original one. A beam arriving edge-on would give the same direction twice,
    so only one beam continues.

    Colors are carried unchanged. Prisms, filters and combiners, which change
    them, are MS3.

    A beam that returns to a cell it has already visited
    {i travelling in the same direction} is in a loop and is stopped there.
    Reaching the same cell in a different direction is ordinary and keeps going.
*)

type segment = {
  at : Types.pos;  (** The cell the beam is passing through. *)
  dir : Types.dir;  (** The direction it is travelling in as it leaves. *)
  color : Types.color;  (** Its color. *)
}
(** One cell of one beam's path. *)

type ending = {
  last : Types.pos;  (** The last cell the beam occupied. *)
  heading : Types.dir;  (** The direction it was travelling in. *)
  beam_color : Types.color;  (** Its color when it stopped. *)
  reason : stop;  (** Why it stopped there. *)
}
(** Where and why a beam stopped. The generator (SOH-3) builds levels by putting
    targets where beams end, so it reads these. *)

(** Why a beam stopped. *)
and stop =
  | Left_board  (** It ran off the edge. *)
  | Hit_wall  (** A wall absorbed it. *)
  | Hit_target  (** A target absorbed it, whether or not the color matched. *)
  | Looped  (** It re-entered a cell travelling the same way as before. *)

type result = {
  segments : segment list;
      (** Every cell every beam passed through, in the order they were traced. A
          cell appears once per beam that crosses it, so a cell two beams cross
          appears twice. *)
  endings : ending list;  (** Where each beam stopped. *)
  targets : (Types.pos * Types.color option) list;
      (** Every target on the grid in reading order, each with the color that
          reached it, or [None] if no beam did. A target reached by more than
          one beam reports the first that arrived. *)
  all_lit : bool;
      (** Whether every target was reached by a beam of exactly its own color. A
          grid with no targets is [true]: nothing is unlit. *)
}
(** What a trace found. *)

val reflect : Types.orientation -> Types.dir -> Types.dir
(** [reflect o d] is [d] mirrored in the line [o] lies along, as described
    above. A direction along that line is its own reflection. *)

val trace_grid :
  rows:int -> cols:int -> cell_at:(Types.pos -> Types.piece option) -> result
(** [trace_grid ~rows ~cols ~cell_at] follows every beam on a [rows] by [cols]
    grid, where [cell_at p] is the piece on cell [p], or [None] if it is empty.

    Sources are found by asking [cell_at] about every cell in reading order, and
    their beams are traced in that order. [cell_at] is called many times for the
    same cell and must answer the same way each time.

    A beam starts {i on} its source's cell travelling in the source's direction,
    and the source itself does not reflect or absorb it.

    @raise Invalid_argument if [rows] or [cols] is less than one. *)
