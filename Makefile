.PHONY: build
build: vosk-foreign.opam vosk-eio.opam
	dune build -p vosk-eio

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

.PHONY: build-deps
build-deps: vosk-foreign.opam vosk-eio.opam
	opam pin vosk-foreign . --no-action -y
	opam install vosk-foreign --deps-only -y
	opam pin vosk-eio . --no-action -y
	opam install vosk-eio --deps-only -y

.PHONY: build-dev-deps
build-dev-deps: vosk-dev.opam opam-setup-local-switch
	opam pin vosk-dev . -y
	opam install vosk-dev --deps-only -y
