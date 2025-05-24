let () =
  Vosk.set_log_level `Disabled;
  Eio_main.run @@ fun env ->
  let path = Eio.Path.(env#fs / Sys.argv.(1)) in
  Eio.Switch.run ~name:"main" @@ fun sw ->
  let m = Vosk.read_model ~sw path in
  ignore m
