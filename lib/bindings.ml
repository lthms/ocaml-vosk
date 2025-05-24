open Ctypes
open Foreign

type vosk_model

let vosk_model : vosk_model structure typ = structure "VoskModel"

let vosk_model_new =
  foreign "vosk_model_new" (string @-> returning (ptr vosk_model))

let vosk_model_free =
  foreign "vosk_model_free" (ptr vosk_model @-> returning void)

let vosk_set_log_level = foreign "vosk_set_log_level" (int @-> returning void)
