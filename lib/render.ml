open Types

module Cells = Map.Make (struct
  type t = pos

  let compare = compare
end)

type beam = { glyph : string; color : color }

let beam_glyph = function
  | E | W -> "┄"
  | NE | SW -> "⋰"
  | N | S -> "┆"
  | NW | SE -> "⋱"

let mix a b = { r = a.r || b.r; g = a.g || b.g; b = a.b || b.b }

let beam_cells (segments : Tracer.segment list) =
  List.fold_left
    (fun cells segment ->
      let glyph = beam_glyph segment.Tracer.dir in
      let color = segment.Tracer.color in
      Cells.update segment.Tracer.at
        (function
          | None -> Some { glyph; color }
          | Some beam ->
              let glyph = if beam.glyph = glyph then glyph else "+" in
              Some { glyph; color = mix beam.color color })
        cells)
    Cells.empty segments

let splitter_glyph = function
  | Horizontal -> "═"
  | Slash -> "╱"
  | Vertical -> "║"
  | Backslash -> "╲"

let colorize enabled ~dim color glyph =
  if not enabled then glyph
  else
    let channel bit on = if on then bit else 0 in
    let foreground =
      30 + channel 1 color.r + channel 2 color.g + channel 4 color.b
    in
    (* Keep black light visible on terminals with a dark background. *)
    let codes = if foreground = 30 then "30;47" else string_of_int foreground in
    Printf.sprintf "\027[%s%sm%s\027[0m" (if dim then "2;" else "") codes glyph

let piece_glyph color targets pos = function
  | Wall -> "#"
  | Source (_, emitted) -> colorize color ~dim:false emitted "@"
  | Target required ->
      let lit = Cells.find_opt pos targets = Some (Some required) in
      colorize color ~dim:(not lit) required (if lit then "*" else "o")
  | Mirror orientation -> string_of_orientation orientation
  | Splitter orientation -> splitter_glyph orientation

let inventory = function
  | [] -> "none"
  | pieces ->
      let name = function
        | Mirror _ -> "mirror"
        | Splitter _ -> "splitter"
        | piece -> string_of_piece piece
      in
      String.concat ", " (List.map name pieces)

let render ?(color = true) game =
  let board = Game.board game in
  let trace = Tracer.trace board in
  let beams = beam_cells trace.segments in
  let targets =
    List.fold_left
      (fun cells (pos, light) -> Cells.add pos light cells)
      Cells.empty trace.targets
  in
  let cell pos =
    match Board.get board pos with
    | Ok (Board.Fixed piece | Board.Placed piece) ->
        piece_glyph color targets pos piece
    | Ok Board.Empty | Error _ -> (
        match Cells.find_opt pos beams with
        | None -> "."
        | Some beam -> colorize color ~dim:false beam.color beam.glyph)
  in
  let output = Buffer.create 128 in
  for row = 0 to Board.rows board - 1 do
    for col = 0 to Board.cols board - 1 do
      Buffer.add_string output (cell { row; col })
    done;
    Buffer.add_char output '\n'
  done;
  Printf.bprintf output "Pieces left: %s\nMoves: %d\n"
    (inventory (Game.pieces_left game))
    (Game.move_count game);
  Buffer.contents output
