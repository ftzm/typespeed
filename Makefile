include $(shell nix-shell ../../service_utils/shell.nix --run "")

.DEFAULT_GOAL := make

NAME := typespeed
DOCKER_REPO := ftzm
DOCKER_NAME := $(NAME)

make: clean elm-make nix-docker-build

clean:
	rm -r -f out

elm-make:
	mkdir out
	@nix-shell elm.nix --command 'elm make src/App.elm --output=out/main.js'
