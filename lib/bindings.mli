type vosk_model

val vosk_set_log_level : int -> unit
val vosk_model_new : string -> vosk_model Ctypes.structure Ctypes_static.ptr
val vosk_model_free : vosk_model Ctypes.structure Ctypes_static.ptr -> unit
