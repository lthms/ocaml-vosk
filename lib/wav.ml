let riff_id = Cstruct.of_string "RIFF"
let wav_format = Cstruct.of_string "WAVE"

let assert_is_wav r =
  let buffer = Cstruct.create 12 in
  Eio.Flow.read_exact r buffer;
  assert (
    Cstruct.equal riff_id (Cstruct.sub buffer 0 4)
    && Cstruct.equal wav_format (Cstruct.sub buffer 8 4))

type subchunk = Cstruct.t

let find_subchunk r name =
  let rec aux () =
    let buffer = Cstruct.create 8 in
    Eio.Flow.read_exact r buffer;
    let current_name = Cstruct.to_string ~off:0 ~len:4 buffer in
    let size = Cstruct.LE.get_uint32 buffer 4 in
    if current_name = name then (
      let subchunk = Cstruct.create (Int32.to_int size) in
      Eio.Flow.read_exact r subchunk;
      subchunk)
    else
      let size = Optint.Int63.of_int32 size in
      let to_skip =
        if Optint.Int63.(Infix.(size land one) = one) then
          Optint.Int63.succ size
        else size
      in
      let _ = Eio.File.seek r to_skip `Cur in
      aux ()
  in
  ignore (Eio.File.seek r (Optint.Int63.of_int 12) `Set);
  aux ()

module Fmt_subchunk : sig
  val audio_format : subchunk -> int
  val num_channels : subchunk -> int
  val sample_rate : subchunk -> int32
  val bits_per_sample : subchunk -> int
end = struct
  let audio_format t = Cstruct.LE.get_uint16 t 0
  let num_channels t = Cstruct.LE.get_uint16 t 2
  let sample_rate t = Cstruct.LE.get_uint32 t 4
  let bits_per_sample t = Cstruct.LE.get_uint16 t 14
end

let from_path path =
  Eio.Path.with_open_in path @@ fun r ->
  assert_is_wav r;
  let fmt = find_subchunk r "fmt " in
  (* PCM *)
  assert (Fmt_subchunk.audio_format fmt = 1);
  (* Mono *)
  assert (Fmt_subchunk.num_channels fmt = 1);
  (* 16-bit *)
  assert (Fmt_subchunk.bits_per_sample fmt = 16);
  let rate = Int32.to_float (Fmt_subchunk.sample_rate fmt) in
  let data = find_subchunk r "data" in
  (rate, data)
