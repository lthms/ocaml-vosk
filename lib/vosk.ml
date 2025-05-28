type model = Bindings.vosk_model Ctypes_static.ptr
type recognizer = Bindings.vosk_recognizer Ctypes_static.ptr
type error = Vosk_exception | Invalid_ffi_result

module Wav = Wav

let set_log_level = function
  | `Verbose -> Bindings.vosk_set_log_level 1
  | `Default -> Bindings.vosk_set_log_level 0
  | `Disabled -> Bindings.vosk_set_log_level (-1)

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
            run_protect ?pool (fun () -> Bindings.vosk_model_new path_str)
          in
          if Ctypes.is_null m then failwith "vosk_model_new failed";
          Eio.Switch.on_release sw (fun () -> Bindings.vosk_model_free m);
          m
      | None -> failwith "Cannot get a regular string from path")
  | _ -> failwith "Not a directory"

let new_recognizer ?pool ~sw model rate =
  let ptr =
    run_protect ?pool @@ fun () -> Bindings.vosk_recognizer_new model rate
  in
  if Ctypes.is_null ptr then failwith "vosk_recognizer_new failed";
  Eio.Switch.on_release sw (fun () -> Bindings.vosk_recognizer_free ptr);
  ptr

let accept_waveform ?pool recognizer buffer =
  let ptr = Ctypes.bigarray_start Ctypes.array1 (Cstruct.to_bigarray buffer) in
  let len = buffer.Cstruct.len in
  match
    run_protect ?pool @@ fun () ->
    Bindings.vosk_recognizer_accept_waveform recognizer ptr len
  with
  | 1 -> Ok true
  | 0 -> Ok false
  | -1 -> Error Vosk_exception
  | _otherwise -> Error Invalid_ffi_result

let result ?pool r =
  run_protect ?pool @@ fun () -> Bindings.vosk_recognizer_result r

let partial_result ?pool r =
  run_protect ?pool @@ fun () -> Bindings.vosk_recognizer_partial_result r

let final_result ?pool r =
  run_protect ?pool @@ fun () -> Bindings.vosk_recognizer_final_result r

let with_recognizer model rate k =
  Eio.Switch.run @@ fun sw -> k (new_recognizer ~sw model rate)
