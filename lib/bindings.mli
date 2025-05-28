type vosk_model

val vosk_model_new : string -> vosk_model Ctypes_static.ptr
val vosk_model_free : vosk_model Ctypes_static.ptr -> unit

type vosk_recognizer

val vosk_recognizer_new :
  vosk_model Ctypes_static.ptr -> float -> vosk_recognizer Ctypes_static.ptr

val vosk_recognizer_accept_waveform :
  vosk_recognizer Ctypes_static.ptr -> char Ctypes_static.ptr -> int -> int

val vosk_recognizer_result : vosk_recognizer Ctypes_static.ptr -> string
val vosk_recognizer_partial_result : vosk_recognizer Ctypes_static.ptr -> string
val vosk_recognizer_final_result : vosk_recognizer Ctypes_static.ptr -> string
val vosk_recognizer_free : vosk_recognizer Ctypes_static.ptr -> unit
val vosk_set_log_level : int -> unit
