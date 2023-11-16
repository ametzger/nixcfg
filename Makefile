# HACK(asm,2023-11-08): use `scutil` here to avoid having to deal with dynamic local hostnames
# (e.g. those set by the AWS reverse IP thing)
HOSTNAME = $(shell scutil --get LocalHostName)

ifndef HOSTNAME
 $(error Hostname unknown)
endif

RED    := $(shell tput -Txterm setaf 1)
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
CYAN   := $(shell tput -Txterm setaf 6)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

## Meta:
.DEFAULT_GOAL: help
.PHONY: help
help: ## Show this help.
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Variables:'
	@echo '  ${YELLOW}HOSTNAME:             ${RED}${HOSTNAME}${RESET}'

## nix-darwin:
.PHONY: darwin
darwin: ## run a darwin-rebuild switch for the current host
	@echo "Switching ${HOSTNAME}"
	nix build .#darwinConfigurations.${HOSTNAME}.system

	./result/sw/bin/darwin-rebuild switch --flake .#${HOSTNAME}

.PHONY: darwin-debug
darwin-debug: ## run a darwin-rebuild switch for the current host with debugging enabled
	@echo "Debug switching ${HOSTNAME}"
	nix build .#darwinConfigurations.${HOSTNAME}.system --show-trace --verbose

	./result/sw/bin/darwin-rebuild switch --flake .#${HOSTNAME} --show-trace --verbose

## home-manager:
.PHONY: home
home: ## run a home-manager switch for the current host
	@echo "Home-manager switching ${HOSTNAME}"
	nix build .#homeConfigurations.${HOSTNAME}.activationPackage

	./result/activate

.PHONY: home-debug
home-debug: ## run a home-manager switch for the current host
	@echo "Home-manager debug switching ${HOSTNAME}"
	nix build .#homeConfigurations.${HOSTNAME}.activationPackage --show-trace --verbose

	./result/activate

## Nix maintenance:
.PHONY: update
update: ## update the flake.lock
	nix flake update

.PHONY: history
history: ## show the history of the current profile
	nix profile history --profile /nix/var/nix/profiles/system

.PHONY: gc
gc: ## clean up nix store
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d
	sudo nix store gc --debug

.PHONY: fmt
fmt: ## format files
	nix fmt

.PHONY: clean
clean: ## clean up build artifacts
	rm -rf result
