(lang dune 3.14)

(generate_opam_files true)

(name vosk)

(package
 (name vosk-foreign)
 (version "0.3.50~wip")
 (synopsis "Low-level bindings that calls the Vosk Toolkit")
 (description "Vosk is a speech recognition toolkit, with more than 20 languages supported.")
 (maintainers "Thomas Letan <lthms@soap.coffee>")
 (homepage "https://github.com/lthms/ocaml-vosk")
 (documentation "https://github.com/lthms/ocaml-vosk#readme")
 (depends dune ctypes ctypes-foreign))

(package
 (name vosk-eio)
 (version "0.1.0")
 (synopsis "Safe high-level API for the Vosk toolkit, leveraging the EIO runtime")
 (description "Vosk is a speech recognition toolkit, with more than 20 languages supported.")
 (maintainers "Thomas Letan <lthms@soap.coffee>")
 (homepage "https://github.com/lthms/ocaml-vosk")
 (documentation "https://github.com/lthms/ocaml-vosk#readme")
 (depends dune vosk-foreign eio yojson))

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
