{ config, ... }:
let
  flakePath = "${config.home.homeDirectory}/proj/nixcfg";
in
{
  # Written directly (rather than via home-manager's `nix.settings`) to avoid
  # pulling a second nixpkgs `nix` package alongside the Determinate install.
  # `asm` is a trusted user (see /etc/nix/nix.conf), so these user-level
  # substituters are honoured by the daemon. nix-community serves prebuilt
  # community artifacts (incl. emacs-overlay builds) that cache.nixos.org lacks.
  home.file.".config/nix/nix.conf" = {
    force = true;
    text = ''
      substituters = https://cache.nixos.org https://nix-community.cachix.org https://claude-code.cachix.org
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=
    '';
  };

  home.file.".config/nix/registry.json".text = builtins.toJSON {
    version = 2;
    flakes = [
      {
        from = {
          type = "indirect";
          id = "nixpkgs";
        };
        to = {
          type = "path";
          path = flakePath;
        };
      }
    ];
  };
}
