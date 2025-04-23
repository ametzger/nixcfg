{ config, ... }:
let
  flakePath = "${config.home.homeDirectory}/proj/nixcfg";
in
{
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
