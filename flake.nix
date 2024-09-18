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
    devenv = {
      url = "github:cachix/devenv/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , flake-utils
    , home-manager
    , mise-flake
    , devenv
    , nur
    , ...
    }:
    let
      supportedSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # inherit (nixpkgs.lib) optionalAttrs singleton;

      # overlays =
      #   singleton
      #       (
      #         # Sub in x86 version of packages that don't build on Apple Silicon yet
      #         final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
      #           inherit (final.pkgs-x86);
      #         })
      #       )
      #     ++ [ mise-flake.overlay ];

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
            {
              home.packages = [ devenv.packages."${system}".devenv ];
            }
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
