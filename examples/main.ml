let () =
  Vosk.set_log_level `Disabled;
  Eio_main.run @@ fun env ->
  let model_path = Eio.Path.(env#fs / Sys.argv.(1)) in
  let wav_path = Eio.Path.(env#fs / Sys.argv.(2)) in
  Eio.Switch.run ~name:"main" @@ fun sw ->
  let pool = Eio.Executor_pool.create ~sw ~domain_count:2 env#domain_mgr in
  let rate, data = Vosk.Wav.from_path ~sw wav_path in
  Eio.traceln "rate is %f" rate;
  let m = Vosk.load_model ~sw model_path in
  Eio.Fiber.any
    [
      (fun () ->
        Vosk.with_recognizer m rate @@ fun r ->
        let buffer = Cstruct.create 4096 in
        let _ =
          Seq.fold_left
            (fun was_silence next ->
              let buffer = next buffer in
              match Vosk.accept_waveform ~pool r buffer with
              | Ok accept_res ->
                  if accept_res && not was_silence then (
                    Eio.traceln "%s" (Vosk.result r);
                    true)
                  else accept_res
              | Error _err -> failwith "something went wrong")
            true data
        in
        Eio.traceln "%s" (Vosk.partial_result r));
      (fun () ->
        Eio_unix.sleep 2.0;
        Eio.traceln "good bye");
    ]
