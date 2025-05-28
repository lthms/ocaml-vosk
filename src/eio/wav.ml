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
    if current_name = name then Int32.to_int size
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

let read_subchunk r name =
  let size = find_subchunk r name in
  let buffer = Cstruct.create size in
  Eio.Flow.read_exact r buffer;
  buffer

type subchunk_resource =
  | Subchunk_resource : {
      resource : [> Eio.Flow.source_ty ] Eio.Resource.t;
      mutable remaining_bytes : int;
    }
      -> subchunk_resource

let to_seq (Subchunk_resource r) =
  Seq.of_dispenser (fun () ->
      if r.remaining_bytes > 0 then
        Some
          (fun buffer ->
            let buffer =
              Cstruct.sub buffer 0
                (min r.remaining_bytes (Cstruct.length buffer))
            in
            Eio.Flow.read_exact r.resource buffer;
            r.remaining_bytes <- r.remaining_bytes - Cstruct.length buffer;
            buffer)
      else None)

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

let from_path ~sw path =
  let r = Eio.Path.open_in ~sw path in
  assert_is_wav r;
  let fmt = read_subchunk r "fmt " in
  (* PCM *)
  assert (Fmt_subchunk.audio_format fmt = 1);
  (* Mono *)
  assert (Fmt_subchunk.num_channels fmt = 1);
  (* 16-bit *)
  assert (Fmt_subchunk.bits_per_sample fmt = 16);
  let rate = Int32.to_float (Fmt_subchunk.sample_rate fmt) in
  let data_len = find_subchunk r "data" in
  (rate, to_seq (Subchunk_resource { resource = r; remaining_bytes = data_len }))
