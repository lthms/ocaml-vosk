type error = Vosk_exception | Invalid_ffi_result

val set_log_level : [< `Default | `Disabled | `Verbose ] -> unit

type model

val load_model :
  ?pool:Eio.Executor_pool.t -> sw:Eio.Switch.t -> _ Eio.Path.t -> model
(** [load_model ?pool ~sw path] reads a Vosk model from the specified [path].
    The [sw] switch is used for resource management. If [pool] is submitted, the
    allocation of the module is performed in a dedicated job (to avoid blocking
    the main domain) *)

type recognizer

val new_recognizer :
  ?pool:Eio.Executor_pool.t -> sw:Eio.Switch.t -> model -> float -> recognizer

val with_recognizer : model -> float -> (recognizer -> 'a) -> 'a

val accept_waveform :
  ?pool:Eio.Executor_pool.t -> recognizer -> Cstruct.t -> (bool, error) result

val result : ?pool:Eio.Executor_pool.t -> recognizer -> string
val partial_result : ?pool:Eio.Executor_pool.t -> recognizer -> string
val final_result : ?pool:Eio.Executor_pool.t -> recognizer -> string

module Wav : sig
  val from_path :
    sw:Eio.Std.Switch.t ->
    _ Eio.Path.t ->
    float * (Cstruct.t -> Cstruct.t) Seq.t
end
