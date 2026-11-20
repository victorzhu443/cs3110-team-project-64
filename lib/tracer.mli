(** Following beams of light across a board.

    Every source emits a beam. A beam travels cell by cell in a straight line
    until something changes it: a wall stops it, a mirror turns it, a splitter
    turns it {i and} lets it carry on, and the edge of the board ends it. A
    target does not stop a beam; the beam passes through and keeps going.

    {1 How to call it}

    {!trace} traces a {!Board.t}. It is a wrapper around {!trace_grid}, which
    asks only for the size of the grid and a function saying what sits on each
    cell. The rules below can therefore be tested against a grid written out as
    text, without a working board, which is what [test/test_tracer.ml] does.

    {1 The beam rules}

    These are decisions D21 and D22 in [docs/DECISIONS.md].

    A beam's path starts on its source's own cell, travelling in the source's
    direction. A source never acts on a beam: a beam that enters any source's
    cell, its own included, passes straight through.

    A direction is reflected by mirroring it in the line the piece lies along:

    - [Horizontal] ([-]) swaps north and south: [N] and [S] exchange, [NE] and
      [SE] exchange, [NW] and [SW] exchange.
    - [Vertical] ([|]) swaps east and west: [E] and [W] exchange, [NE] and [NW]
      exchange, [SE] and [SW] exchange.
    - [Slash] ([/]) exchanges [N] with [E], [S] with [W], and [SE] with [NW].
    - [Backslash] ([\ ]) exchanges [N] with [W], [S] with [E], and [NE] with
      [SW].

    Mirrors reflect from both faces. A beam that hits a mirror square-on (at
    right angles to its line) is sent straight back. A beam travelling {i along}
    the line a mirror lies on — [E] or [W] into a [Horizontal] mirror, [NE] or
    [SW] into a [Slash] — meets it edge-on and stops in the mirror's cell.

    A splitter sends one beam straight on and a second beam the way a mirror of
    the same orientation would. Both keep the incoming color. Edge-on, the
    second beam would stop at once, so only the straight beam leaves; square-on,
    one beam goes straight on and one goes back.

    Beams that cross each other do not interact. Colors are carried unchanged;
    prisms, filters and combiners, which change them, are MS3.

    The color reaching a target is the mix of every beam that passes through it:
    each of red, green and blue is on if it is on in any of those beams. A
    target is lit when that mix equals its own color exactly, so a red and a
    green beam together light a yellow target, but a stray green beam through a
    red target leaves it dark.

    A beam about to enter a cell it has already entered
    {i travelling in the same direction} is in a loop and stops in the cell it
    is in. Reaching the same cell in a different direction is ordinary and keeps
    going. *)

type segment = {
  at : Types.pos;  (** The cell the beam is passing through. *)
  entered : Types.dir;
      (** The direction it was travelling in as it came into the cell. On the
          source's own cell this is the source's direction. *)
  dir : Types.dir;
      (** The direction it leaves the cell in. Different from [entered] where a
          mirror or splitter turned it. In the cell where a beam stops, it is
          the direction the beam was travelling in. *)
  color : Types.color;  (** Its color. *)
}
(** One cell of one beam's path. *)

type ending = {
  last : Types.pos;  (** The last cell of the beam's path. *)
  heading : Types.dir;  (** The direction it was travelling in there. *)
  beam_color : Types.color;  (** Its color when it stopped. *)
  reason : stop;  (** Why it stopped there. *)
}
(** Where and why a beam stopped. Each branch a splitter makes has its own
    ending. *)

(** Why a beam stopped. *)
and stop =
  | Left_board  (** The next cell would be off the board. *)
  | Hit_wall  (** It entered a wall's cell. *)
  | Hit_mirror_edge  (** It met a mirror edge-on, in that mirror's cell. *)
  | Looped
      (** The next cell is one it already entered travelling the same way. *)

type result = {
  segments : segment list;
      (** Every cell every beam passed through, in the order they were traced. A
          cell appears once per beam that crosses it, so a cell two beams cross
          appears twice. *)
  endings : ending list;  (** Where each beam stopped. *)
  targets : (Types.pos * Types.color option) list;
      (** Every target on the grid in reading order, each with the mix of the
          colors that reached it, or [None] if no beam did. *)
  all_lit : bool;
      (** Whether every target is lit, as described above. A grid with no
          targets is [true]: nothing is unlit. *)
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

    @raise Invalid_argument if [rows] or [cols] is less than one. *)

val trace : Board.t -> result
(** [trace b] is {!trace_grid} on [b]: its size, with each cell's fixed or
    placed piece. *)
