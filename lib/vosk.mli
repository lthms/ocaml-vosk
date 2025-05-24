val set_log_level : [< `Default | `Disabled | `Verbose ] -> unit

type model

val load_model : sw:Eio.Switch.t -> _ Eio.Path.t -> model
(** [load_model ~sw path] reads a Vosk model from the specified [path]. The [sw]
    switch is used for resource management. *)

type recognizer

val new_recognizer : sw:Eio.Switch.t -> model -> float -> recognizer
val with_recognizer : model -> float -> (recognizer -> 'a) -> 'a

module Wav : sig
  val rate_from_path : _ Eio.Path.t -> float
end
