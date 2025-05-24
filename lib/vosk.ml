type model = Bindings.vosk_model Ctypes_static.ptr
type recognizer = Bindings.vosk_recognizer Ctypes_static.ptr

module Wav = Wav

let set_log_level = function
  | `Verbose -> Bindings.vosk_set_log_level 1
  | `Default -> Bindings.vosk_set_log_level 0
  | `Disabled -> Bindings.vosk_set_log_level (-1)

let load_model ~sw path =
  match Eio.Path.kind ~follow:true path with
  | `Not_found -> failwith "Missing file"
  | `Directory -> (
      match Eio.Path.native path with
      | Some path_str ->
          let m = Bindings.vosk_model_new path_str in
          if Ctypes.is_null m then failwith "vosk_model_new failed";
          Eio.Switch.on_release sw (fun () -> Bindings.vosk_model_free m);
          m
      | None -> failwith "Cannot get a regular string from path")
  | _ -> failwith "Not a directory"

let new_recognizer ~sw model rate =
  let ptr = Bindings.vosk_recognizer_new model rate in
  if Ctypes.is_null ptr then failwith "vosk_recognizer_new failed";
  Eio.Switch.on_release sw (fun () -> Bindings.vosk_recognizer_free ptr);
  ptr

let with_recognizer model rate k =
  Eio.Switch.run @@ fun sw -> k (new_recognizer ~sw model rate)
