(** Searching for a way to light every target.

    The solver's job is to decide where the player's pieces go. Given the cells
    a piece may occupy and the pieces available, it looks for an assignment that
    solves the level, and reports one if it finds it.

    {1 How the pieces fit}

    The shared contract (plan section 5.3) says [Solver] publishes "[solve] from
    a board and the pieces available to an optional list of placements". That is
    {!solve}: it puts the pieces on the board with {!apply} and asks
    {!Tracer.trace} whether every target is lit.

    The search underneath is published on its own as {!search}. It takes the two
    things it needs from [Board] and [Tracer] as arguments, the cells it may use
    and a predicate saying whether a set of placements solves the level, and
    knows nothing about boards or light. That split is kept because the search
    can then be tested without a board or a tracer, as the first half of
    [test/test_solver.ml] does; the second half tests {!solve} on real levels.

    {1 What the search guarantees}

    - Every piece given is placed, each in a cell of its own.
    - Only cells from [slots] are used.
    - A piece that can be rotated is tried in each of its orientations.
    - The search is exhaustive {i over the cells it is offered}: with the
      default [?candidates], [None] means no assignment of those pieces to those
      cells satisfies [solved]. With a [?candidates] that drops cells, [None]
      means only that no assignment among the cells it offered does. *)

type placement = {
  piece : Types.piece;  (** The piece, in the orientation it is placed in. *)
  at : Types.pos;  (** Where it goes. *)
}
(** One piece, placed on one cell. *)

val rotations : Types.piece -> Types.piece list
(** [rotations p] is every form the player can rotate [p] into, [p] included and
    first.

    A mirror or a splitter has four, one per {!Types.orientation}. Every other
    piece has one: a source, a wall and a target are part of the level, not
    pieces the player turns.

    The order is {!Board.rotate}'s cycle — [Horizontal], [Backslash],
    [Vertical], [Slash] — begun at the piece's own orientation, so trying the
    forms in order is the same as pressing rotate repeatedly, and a search over
    them is deterministic. *)

val search :
  ?candidates:(placement list -> Types.pos list -> Types.pos list) ->
  slots:Types.pos list ->
  pieces:Types.piece list ->
  solved:(placement list -> bool) ->
  unit ->
  placement list option
(** [search ~slots ~pieces ~solved ()] is [Some ps] where [ps] places every
    piece of [pieces] on a distinct cell of [slots] and [solved ps] holds, or
    [None] if no such placement exists.

    The placements come back in the order the pieces were given, so the [n]th
    placement is where the [n]th piece went.

    [solved] is applied to complete placements only — every piece is down before
    it is asked. It must be a pure function of its argument: the search calls it
    many times and assumes the same answer each time.

    [?candidates] is the pruning hook.
    [candidates placed_so_far remaining_slots] is the cells worth trying next,
    and it must return a subset of [remaining_slots]; returning fewer is what
    makes the search fast, and returning cells outside that list is a
    programming error that is silently ignored. The default tries every
    remaining cell, which is correct but slow. Once [Tracer] exists this is
    where "only the cells a beam actually passes through" goes, which is the
    pruning the MS1 proposal promised.

    Placing [k] pieces among [n] cells is {m O(n^k)} in the worst case, times
    the cost of [solved]. Pieces are placed in the order given and are not
    compared, so [k] identical pieces are tried in all [k!] orders and the same
    arrangement is handed to [solved] that many times. Two mirrors therefore
    cost twice what they need to, three cost six times. Harmless for MS2, but
    the counts in [docs/investigations/solver-timing.md] carry that factor, and
    skipping repeats is the cheapest speed-up available after pruning. See
    [docs/investigations/solver-timing.md] (VIC-6) for what that means in
    practice on 6x6 and 8x8 boards.

    @raise Invalid_argument if [slots] holds a repeated position. *)

val apply : Board.t -> placement list -> (Board.t, Board.error) result
(** [apply b ps] is [b] with every placement of [ps] made, in order, with
    {!Board.place}. [b] itself is unchanged. Errors are {!Board.place}'s, for
    the first placement that fails: [Out_of_bounds]; [Occupied] if the cell
    holds a piece or an earlier placement already took it; [Not_placeable] if
    the piece is not a mirror or a splitter. *)

val solve : Board.t -> Types.piece list -> placement list option
(** [solve b pieces] is [Some ps] where [apply b ps] succeeds and every target
    of the resulting board is lit, as {!Tracer.trace} reports it, or [None] if
    no way of placing [pieces] on the empty cells of [b] does that.

    It is {!search} over [Board.empty_cells b] with the default [?candidates],
    so it is exhaustive, deterministic, and returns the placements in the order
    of [pieces], each in the orientation it must be placed in. A board whose
    targets are all lit before anything is placed is solved by [pieces = []],
    giving [Some []]. A piece that {!Board.place} refuses (a source, a wall or a
    target) can never be placed, so the answer is then [None].

    Cost is {!search}'s: the tutorial level, with 36 empty cells and a splitter
    and a mirror to place, is at most 36 × 35 × 16 traces, about 20 000. *)
