# HACK(asm,2023-11-08): use `scutil` here to avoid having to deal with dynamic local hostnames
# (e.g. those set by the AWS reverse IP thing)
HOSTNAME := `scutil --get LocalHostName`

# list available tasks
help:
    @just --list
    @echo "Variables:"
    @echo "  HOSTNAME: ${HOSTNAME}"

# run a darwin-rebuild switch for the current host
darwin:
	@echo "Switching ${HOSTNAME}"
	nix build .#darwinConfigurations.${HOSTNAME}.system

	./result/sw/bin/darwin-rebuild switch --flake .#${HOSTNAME}

# run a darwin-rebuild switch for the current host with debugging enabled
darwin-debug:
	@echo "Debug switching ${HOSTNAME}"
	nix build .#darwinConfigurations.${HOSTNAME}.system --show-trace --verbose

	./result/sw/bin/darwin-rebuild switch --flake .#${HOSTNAME} --show-trace --verbose

# show the history of the current profile
darwin-history:
	nix profile history --profile /nix/var/nix/profiles/system

# run a home-manager switch for the current host
home:
	@echo "Home-manager switching ${HOSTNAME}"
	nix build .#homeConfigurations.${HOSTNAME}.activationPackage

	./result/activate

# run a home-manager switch for the current host
home-debug:
	@echo "Home-manager debug switching ${HOSTNAME}"
	nix build .#homeConfigurations.${HOSTNAME}.activationPackage --show-trace --verbose

	./result/activate

# show the history of the current profile
home-history:
	home-manager generations

# update the flake.lock
update:
	nix flake update

# clean up nix store
gc:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d
	sudo nix store gc --debug

# format files
fmt:
	nix fmt

# clean up build artifacts
clean:
	rm -rf result
