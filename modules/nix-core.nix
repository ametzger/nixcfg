{lib, ...}: {
  # baseline nix/flake config
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;

  # garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 1w";
  };

  # TODO(asm,2023-11-03): this seems to be causing issues like `error: cannot link
  # '/nix/store/.tmp-link' to '/nix/store/.links/...': File exists`
  # nix.settings.auto-optimise-store = true;
}
