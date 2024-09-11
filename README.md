# nixcfg

`home-manager` and NixOS configs for my machines.

## Bootstrapping
From a fresh macOS install:

1. Configure SSH keys with GitHub access
2. Run detsys installer:
   ```
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
3. Clone repo: `nix run nixpkgs#git -- clone git@github.com:ametzger/nixcfg.git`
4. Set macOS hostname:
   ```
     export NEW_HOSTNAME='<hostname>'
     sudo scutil --set HostName "$NEW_HOSTNAME"
     sudo scutil --set LocalHostName "$NEW_HOSTNAME"
     sudo scutil --set ComputerName "$NEW_HOSTNAME"
   ```
5. Reboot the machine
6. Add line to `flake.nix` for the new hostname, so `homeConfigurations."$NEW_HOSTNAME"` exists
7. Setup home-manager and activate the profile: `nix run nixpkgs#just -- home`
