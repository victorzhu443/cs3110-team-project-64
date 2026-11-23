(* Print the generated levels the benchmark used, for the record. *)
open Lumen

let () =
  List.iter
    (fun (s, seeds) ->
      List.iter
        (fun seed ->
          match Generator.construct ~seed ~rows:s ~cols:s with
          | Ok c ->
              Printf.printf
                "## %dx%d seed %d (%d pieces)\n\
                 ```\n\
                 %s\n\
                 ```\n\
                 built-from solution: %s\n\n"
                s s seed (List.length c.solution) (String.trim c.text)
                (String.concat ", "
                   (List.map
                      (fun ((p : Types.pos), pc) ->
                        Printf.sprintf "%s at (%d,%d)"
                          (Types.string_of_piece pc) p.row p.col)
                      c.solution))
          | Error e ->
              Printf.printf "seed %d: %s\n" seed (Generator.string_of_error e))
        seeds)
    [ (6, [ 1; 2; 3; 5 ]); (8, [ 4; 5; 1; 2 ]) ]
