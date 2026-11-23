open Lumen

let help =
  {|Commands use zero-based row and column numbers.
  place ROW COL PIECE ORIENTATION
  rotate ROW COL
  remove ROW COL
  help
  quit
Pieces: mirror, splitter. Orientations: - / | \|}

let rec play ~color game =
  print_string (Render.render ~color game);
  if Game.is_won game then print_endline "You solved the level!"
  else (
    if Game.pieces_left game = [] && Board.placed (Game.board game) <> [] then
      print_endline "No pieces left. Remove one to try again.";
    print_string "lumen> ";
    flush stdout;
    match input_line stdin with
    | exception End_of_file -> print_newline ()
    | line -> (
        match Game.parse_command line with
        | Ok Game.Quit -> ()
        | Ok Game.Help ->
            print_endline help;
            play ~color game
        | Ok (Game.Move move) -> (
            match Game.apply game move with
            | Ok next -> play ~color next
            | Error error ->
                print_endline (Game.string_of_move_error error);
                play ~color game)
        | Error error ->
            print_endline (Game.string_of_parse_error error);
            play ~color game))

let () =
  match Array.to_list Sys.argv with
  | [ _; path ] -> (
      match Level.load path with
      | Ok level ->
          let color =
            Option.value (Sys.getenv_opt "NO_COLOR") ~default:"" = ""
          in
          print_endline (Level.name level);
          play ~color (Game.start level)
      | Error error ->
          prerr_endline (Level.string_of_error error);
          exit 1)
  | _ ->
      prerr_endline "Usage: main LEVEL_FILE";
      exit 2
