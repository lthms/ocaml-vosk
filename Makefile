.PHONY: opam-setup-local-switch
opam-setup-local-switch:
	@echo "Checking for existing local opam switch..."
	@if ! opam switch list --short | grep -q "^$(shell pwd)$$" > /dev/null; then \
		opam update; \
		opam switch create .  --no-install --packages ocaml.5.3.0,dune.3.19.0 --deps-only -y; \
		echo "Local opam switch created successfully."; \
	else \
		echo "Local opam switch already exists at $(shell pwd)."; \
	fi

%.opam: opam-setup-local-switch dune-project
	dune build $@

build-deps: ocaml-vosk.opam
	opam update
	opam pin ocaml-vosk . --no-action -y
	opam install ocaml-vosk --deps-only -y

.PHONY: build-dev-deps
build-dev-deps: ocaml-vosk-dev.opam opam-setup-local-switch
	opam pin ocaml-vosk-dev . -y
	opam install ocaml-vosk-dev --deps-only -y
