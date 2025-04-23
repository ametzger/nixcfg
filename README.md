# nixcfg

`home-manager` and NixOS configs for my machines.

Includes some `brew` accoutrement because I don't really like nix-darwin.

## Bootstrapping
From a fresh macOS install:

1. Configure SSH keys with GitHub access
2. Set macOS hostname:
   ```
     export NEW_HOSTNAME='<hostname>'
     sudo scutil --set HostName "$NEW_HOSTNAME"
     sudo scutil --set LocalHostName "$NEW_HOSTNAME"
     sudo scutil --set ComputerName "$NEW_HOSTNAME"
   ```
3. Reboot the machine
4. Run detsys installer:
```
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
5. Install `brew`: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
6. Clone repo: `mkdir -p ~/proj; nix run nixpkgs#git -- clone git@github.com:ametzger/nixcfg.git ~/proj/nixcfg`
7. Install macos stuff: `brew bundle install`
8. Add line to `flake.nix` for the new hostname, so `homeConfigurations."$NEW_HOSTNAME"` exists
9. Setup home-manager and activate the profile: `nix run nixpkgs#just -- switch`
