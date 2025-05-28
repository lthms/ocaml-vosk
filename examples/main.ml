let () =
  Vosk.set_log_level `Disabled;
  Eio_main.run @@ fun env ->
  let model_path = Eio.Path.(env#fs / Sys.argv.(1)) in
  let wav_path = Eio.Path.(env#fs / Sys.argv.(2)) in
  Eio.Switch.run ~name:"main" @@ fun sw ->
  let rate, data = Vosk.Wav.from_path wav_path in
  Eio.traceln "rate is %f" rate;
  let m = Vosk.load_model ~sw model_path in
  Vosk.with_recognizer m rate @@ fun r ->
  match Vosk.accept_waveform r data with
  | Ok _ -> Format.printf "%s\n%!" (Vosk.final_result r)
  | Error _err -> Eio.traceln "accept_waveform: _"
