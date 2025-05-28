val from_path :
  sw:Eio.Std.Switch.t -> _ Eio.Path.t -> float * (Cstruct.t -> Cstruct.t) Seq.t
