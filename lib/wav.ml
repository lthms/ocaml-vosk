let riff_id = Cstruct.of_string "RIFF"
let wav_format = Cstruct.of_string "WAVE"

let assert_is_wav r =
  let buffer = Cstruct.create 12 in
  Eio.Flow.read_exact r buffer;
  assert (
    Cstruct.equal riff_id (Cstruct.sub buffer 0 4)
    && Cstruct.equal wav_format (Cstruct.sub buffer 8 4))

let rec find_start_of_fmt r =
  let buffer = Cstruct.create 8 in
  Eio.Flow.read_exact r buffer;
  let name = Cstruct.to_string ~off:0 ~len:4 buffer in
  let size = Cstruct.LE.get_uint32 buffer 4 in
  if name = "fmt " then ()
  else
    let size = Optint.Int63.of_int32 size in
    let to_skip =
      if Optint.Int63.(Infix.(size land one) = one) then Optint.Int63.succ size
      else size
    in
    let _ = Eio.File.seek r to_skip `Cur in
    find_start_of_fmt r

let rate_from_path path =
  Eio.Path.with_open_in path @@ fun r ->
  assert_is_wav r;
  find_start_of_fmt r;
  let buffer = Cstruct.create 4 in
  let _ = Eio.File.seek r (Optint.Int63.of_int 4) `Cur in
  Eio.Flow.read_exact r buffer;
  Cstruct.LE.get_uint32 buffer 0 |> Int32.to_float
