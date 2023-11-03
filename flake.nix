{
  description = "asm nix configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager, ... }:
  {
    darwinConfigurations."asm-mbp-16" = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin";

      # expose flake's inputs as param
      specialArgs = { inherit inputs; };

      modules = [
        ./modules/nix-core.nix
        ./modules/nix-darwin.nix

        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = inputs;

          # home-manager.users.asm = import ./home;
        }

      ];
    };
  };
}
