type model = Bindings.vosk_model Ctypes.structure Ctypes_static.ptr

let set_log_level = function
  | `Verbose -> Bindings.vosk_set_log_level 1
  | `Default -> Bindings.vosk_set_log_level 0
  | `Disabled -> Bindings.vosk_set_log_level (-1)

let read_model ~sw path =
  match Eio.Path.kind ~follow:true path with
  | `Not_found -> failwith "Missing file"
  | `Directory -> (
      match Eio.Path.native path with
      | Some path_str ->
          let m = Bindings.vosk_model_new path_str in
          Eio.Switch.on_release sw (fun () -> Bindings.vosk_model_free m);
          m
      | None -> failwith "Cannot get a regular string from path")
  | _ -> failwith "Not a directory"
