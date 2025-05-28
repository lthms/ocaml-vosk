open Ctypes
open Foreign

type vosk_model_t
type vosk_model = vosk_model_t structure

let vosk_model : vosk_model typ = structure "VoskModel"

let vosk_model_new =
  foreign "vosk_model_new" (string @-> returning (ptr vosk_model))

let vosk_model_free =
  foreign "vosk_model_free" (ptr vosk_model @-> returning void)

type vosk_recognizer_t
type vosk_recognizer = vosk_recognizer_t structure

let vosk_recognizer : vosk_recognizer typ = structure "VoskRecognizer"

let vosk_recognizer_new =
  foreign "vosk_recognizer_new"
    (ptr vosk_model @-> float @-> returning (ptr vosk_recognizer))

let vosk_recognizer_free =
  foreign "vosk_recognizer_free" (ptr vosk_recognizer @-> returning void)

let vosk_recognizer_accept_waveform =
  foreign "vosk_recognizer_accept_waveform"
    (ptr vosk_recognizer @-> ptr char @-> int @-> returning int)

let vosk_recognizer_result =
  foreign "vosk_recognizer_result" (ptr vosk_recognizer @-> returning string)

let vosk_recognizer_partial_result =
  foreign "vosk_recognizer_partial_result"
    (ptr vosk_recognizer @-> returning string)

let vosk_recognizer_final_result =
  foreign "vosk_recognizer_final_result"
    (ptr vosk_recognizer @-> returning string)

let vosk_set_log_level = foreign "vosk_set_log_level" (int @-> returning void)
