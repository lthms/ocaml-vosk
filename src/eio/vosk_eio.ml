type model = Vosk_foreign.vosk_model Ctypes_static.ptr
type recognizer = Vosk_foreign.vosk_recognizer Ctypes_static.ptr
type error = Vosk_exception | Invalid_ffi_result

module Wav = Wav

let set_log_level = function
  | `Verbose -> Vosk_foreign.vosk_set_log_level 1
  | `Default -> Vosk_foreign.vosk_set_log_level 0
  | `Disabled -> Vosk_foreign.vosk_set_log_level (-1)

let run_protect ?pool k =
  Eio.Cancel.protect @@ fun () ->
  match pool with
  | Some pool -> Eio.Executor_pool.submit_exn pool ~weight:1.0 k
  | None -> k ()

let load_model ?pool ~sw path =
  match Eio.Path.kind ~follow:true path with
  | `Not_found -> failwith "Missing file"
  | `Directory -> (
      match Eio.Path.native path with
      | Some path_str ->
          let m =
            run_protect ?pool (fun () -> Vosk_foreign.vosk_model_new path_str)
          in
          if Ctypes.is_null m then failwith "vosk_model_new failed";
          Eio.Switch.on_release sw (fun () -> Vosk_foreign.vosk_model_free m);
          m
      | None -> failwith "Cannot get a regular string from path")
  | _ -> failwith "Not a directory"

let new_recognizer ?pool ~sw model rate =
  let ptr =
    run_protect ?pool @@ fun () -> Vosk_foreign.vosk_recognizer_new model rate
  in
  if Ctypes.is_null ptr then failwith "vosk_recognizer_new failed";
  Eio.Switch.on_release sw (fun () -> Vosk_foreign.vosk_recognizer_free ptr);
  ptr

let accept_waveform ?pool recognizer buffer =
  let ptr = Ctypes.bigarray_start Ctypes.array1 (Cstruct.to_bigarray buffer) in
  let len = buffer.Cstruct.len in
  match
    run_protect ?pool @@ fun () ->
    Vosk_foreign.vosk_recognizer_accept_waveform recognizer ptr len
  with
  | 1 -> Ok true
  | 0 -> Ok false
  | -1 -> Error Vosk_exception
  | _otherwise -> Error Invalid_ffi_result

let from_json m str =
  let open Yojson.Basic.Util in
  Yojson.Basic.from_string str |> member m |> to_string

let result ?pool r =
  run_protect ?pool @@ fun () ->
  Vosk_foreign.vosk_recognizer_result r |> from_json "text"

let partial_result ?pool r =
  run_protect ?pool @@ fun () ->
  Vosk_foreign.vosk_recognizer_partial_result r |> from_json "partial"

let final_result ?pool r =
  run_protect ?pool @@ fun () ->
  Vosk_foreign.vosk_recognizer_final_result r |> from_json "text"

let with_recognizer model rate k =
  Eio.Switch.run @@ fun sw -> k (new_recognizer ~sw model rate)

let from_wav_file ?buffer_size ?pool ~sw m path =
  let rate, data = Wav.from_path ~sw path in
  let r = new_recognizer ?pool ~sw m rate in
  let buffer_size =
    match buffer_size with
    | Some s -> s
    | None -> (* Chunks of 20ms by default. *) Float.to_int (rate *. 0.04)
  in
  let buffer = Cstruct.create buffer_size in
  let was_silence = ref true in
  Seq.append
    (Seq.concat_map
       (fun next ->
         let buffer = next buffer in
         match accept_waveform ?pool r buffer with
         | Ok accept_res ->
             if accept_res && not !was_silence then (
               was_silence := accept_res;
               List.to_seq [ result ?pool r ])
             else (
               was_silence := accept_res;
               Seq.empty)
         | Error _err -> failwith "something went wrong")
       data)
    (fun () -> Seq.Cons (final_result r, Seq.empty))
  |> Seq.filter (( <> ) "")
