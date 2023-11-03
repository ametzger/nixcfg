{ lib, ... }: {
  # baseline nix/flake config
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;

  # garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;
}
