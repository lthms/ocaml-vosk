let () =
  Vosk_eio.set_log_level `Disabled;
  Eio_main.run @@ fun env ->
  let model_path = Eio.Path.(env#fs / Sys.argv.(1)) in
  let wav_path = Eio.Path.(env#fs / Sys.argv.(2)) in
  Eio.Switch.run ~name:"main" @@ fun sw ->
  let pool = Eio.Executor_pool.create ~sw ~domain_count:2 env#domain_mgr in
  let m = Vosk_eio.load_model ~sw model_path in
  Seq.iter
    (fun text -> Format.printf "%s\n%!" text)
    (Vosk_eio.from_wav_file ~pool ~sw m wav_path)
