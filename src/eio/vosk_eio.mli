type error = Vosk_exception | Invalid_ffi_result

val set_log_level : [< `Default | `Disabled | `Verbose ] -> unit

type model

val load_model :
  ?pool:Eio.Executor_pool.t -> sw:Eio.Switch.t -> _ Eio.Path.t -> model
(** [load_model ?pool ~sw path] reads a Vosk model from the specified [path].
    The [sw] switch is used for resource management. If [pool] is submitted, the
    allocation of the module is performed in a dedicated job (to avoid blocking
    the main domain) *)

val from_wav_file :
  ?buffer_size:int ->
  ?pool:Eio.Executor_pool.t ->
  sw:Eio.Switch.t ->
  model ->
  _ Eio.Path.t ->
  string Seq.t
(** [from_wav_file ?pool ~sw model path] reads the contents of [path] as a WAV
    file (more precisely, a PCB 16-bit mono audio file), and feeds the contents
    to a recognizer initialized from [model]. If [pool] is passed, the calls to
    the Vosk API are performed in one of the executors of the pool to avoid
    blocking the main domain. *)

type recognizer

val new_recognizer :
  ?pool:Eio.Executor_pool.t -> sw:Eio.Switch.t -> model -> float -> recognizer

val with_recognizer : model -> float -> (recognizer -> 'a) -> 'a

val accept_waveform :
  ?pool:Eio.Executor_pool.t -> recognizer -> Cstruct.t -> (bool, error) result

val result : ?pool:Eio.Executor_pool.t -> recognizer -> string
val partial_result : ?pool:Eio.Executor_pool.t -> recognizer -> string
val final_result : ?pool:Eio.Executor_pool.t -> recognizer -> string
