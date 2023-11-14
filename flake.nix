{
  description = "asm nix configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rtx-flake = {
      url = "github:jdxcode/rtx";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    devenv = {
      url = "github:cachix/devenv/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, nix-darwin, home-manager, rtx-flake, devenv, nur, ... }:
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
      #     ++ [ rtx-flake.overlay ];

      legacyPackages = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ rtx-flake.overlay ];
          config = {
            allowUnfree = true;
          };
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
      darwinConfigurations."asm-mbp-16" = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";

        # expose flake's inputs as param
        specialArgs = { inherit inputs; };

        modules = [
          ./modules/nix-core.nix
          ./modules/darwin.nix
          ./modules/system.nix
          # ./modules/homebrew.nix # wip - currently kills non-managed brew packages, so not using for now

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;

            home-manager.users.asm = import ./home;
          }
        ];
      };

      homeConfigurations."asm-mbp-14" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."aarch64-darwin";
    };
}
