(lang dune 3.19)

(generate_opam_files true)

(name vosk)

(package
 (name vosk-foreign)
 (version "0.1.0")
 (synopsis "OCaml bindings for Vosk")
 (description "A short description of the OCaml Vosk package.")
 (maintainers "Thomas Letan <lthms@soap.coffee>")
 (homepage "https://github.com/your-org/ocaml-vosk")
 (documentation "https://github.com/your-org/ocaml-vosk#readme")
 (depends dune ctypes ctypes-foreign))

(package
 (name vosk-eio)
 (version "0.1.0")
 (synopsis "OCaml bindings for Vosk")
 (description "A short description of the OCaml Vosk package.")
 (maintainers "Thomas Letan <lthms@soap.coffee>")
 (homepage "https://github.com/your-org/ocaml-vosk")
 (documentation "https://github.com/your-org/ocaml-vosk#readme")
 (depends dune vosk-foreign eio))

(package
 (allow_empty)
 (name vosk-dev)
 (synopsis
  "Virtual package gathering developers dependencies for hacking the OCaml Vosk project")
 (depends
  dune-release
  ocaml-lsp-server
  eio_main ; necessary for running the examples
  odoc
  (ocamlformat
   (= 0.27.0))))
