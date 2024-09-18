{
  description = "asm nix configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mise-flake = {
      url = "github:jdx/mise";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , flake-utils
    , home-manager
    , mise-flake
    , nur
    , ...
    }:
    let
      supportedSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsConfig = {
        allowUnfree = true;
        input-fonts.acceptLicense = true;
      };

      legacyPackages = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ mise-flake.overlay ];
          config = nixpkgsConfig;
        }
      );

      # nurModules = forAllSystems (
      #   system:
      #   import nur {
      #     nurpkgs = legacyPackages."${system}";
      #     pkgs = legacyPackages."${system}";
      #   }
      # );

      homeManagerConfigs = forAllSystems (
        system: {
          pkgs = legacyPackages."${system}";
          modules = [
            ./home
          ];
        }
      );
    in
    {
      formatter.aarch64-darwin = nixpkgs.legacyPackages."aarch64-darwin".nixpkgs-fmt;
      formatter.x86_64-darwin = nixpkgs.legacyPackages."x86_64-darwin".nixpkgs-fmt;

      homeConfigurations."asm-mbp-16" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."x86_64-darwin";
      homeConfigurations."asm-mbp-14" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."aarch64-darwin";
      homeConfigurations."asm-mba-13" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."aarch64-darwin";
    };
}
