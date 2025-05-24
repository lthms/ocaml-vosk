type vosk_model

val vosk_model_new : string -> vosk_model Ctypes_static.ptr
val vosk_model_free : vosk_model Ctypes_static.ptr -> unit

type vosk_recognizer

val vosk_recognizer_new :
  vosk_model Ctypes_static.ptr -> float -> vosk_recognizer Ctypes_static.ptr

val vosk_recognizer_free : vosk_recognizer Ctypes_static.ptr -> unit
val vosk_set_log_level : int -> unit
