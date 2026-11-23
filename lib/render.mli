(** Pure terminal rendering for Lumen. *)

val render : ?color:bool -> Game.t -> string
(** [render game] formats the board, beams, lit targets, inventory, and move
    count as terminal text ending in a newline. The board uses one character per
    cell. A piece takes precedence over the beam, and [+] marks an empty cell
    crossed by beams on different axes. ANSI color is on by default. Pass
    [~color:false] to omit the escape sequences. *)
