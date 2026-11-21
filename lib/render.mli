(** Pure terminal rendering for Lumen. *)

val render : Game.t -> string
(** [render game] formats the board, beams, lit targets, inventory, and move
    count as terminal text. The ALX-1 stub returns an empty string. *)
