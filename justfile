# HACK(asm,2023-11-08): use `scutil` here to avoid having to deal with dynamic local hostnames
# (e.g. those set by the AWS reverse IP thing)
HOSTNAME := `scutil --get LocalHostName`

# list available tasks
help:
    @just --list
    @echo ""
    @echo "Variables:"
    @echo "  HOSTNAME: ${HOSTNAME}"

# run a home-manager build for the current host
build:
    @echo "Building ${HOSTNAME}"
    nix build .#homeConfigurations.${HOSTNAME}.activationPackage

# activate the current home-manager generation
activate:
    @echo "Home-manager switching ${HOSTNAME}"
    ./result/activate

alias home := switch

# run a home-manager switch for the current host
switch: build activate

# run a home-manager build for the current host with debug tracing
debug:
    @echo "Home-manager debug switching ${HOSTNAME}"
    nix build .#homeConfigurations.${HOSTNAME}.activationPackage --show-trace --verbose

# show the history of the current profile
history:
    home-manager generations

# update flake.lock
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

# enter the development shell
shell:
    nix develop
