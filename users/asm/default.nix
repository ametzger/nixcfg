{ lib, ... }:
let
  username = "asm";
in
{
  home = {
    username = "${username}";
    homeDirectory = lib.mkForce "/Users/${username}";
    stateVersion = "23.05";
  };

  programs.home-manager.enable = true;

  local.claude.enable = true;

  # TODO(asm,2023-03-24): this is really slow, so disable for now
  manual.manpages.enable = false;
  programs.man.enable = false;

  imports = [
    ../../modules/claude
    ./files.nix
    ./environment.nix
    ./nix.nix
    ./packages.nix
  ];
}
