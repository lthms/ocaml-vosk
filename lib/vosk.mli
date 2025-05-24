val set_log_level : [< `Default | `Disabled | `Verbose ] -> unit

type model

val read_model :
  sw:Eio.Switch.t ->
  _ Eio.Path.t ->
  Bindings.vosk_model Ctypes.structure Ctypes_static.ptr
(** [read_model ~sw path] reads a Vosk model from the specified [path]. The [sw]
    switch is used for resource management. *)
