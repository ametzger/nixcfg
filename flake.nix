{
  description = "asm nix configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs
    , home-manager
    , nix-index-database
    , claude-code
    , ...
    }:
    let
      supportedSystems = [ "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsConfig = {
        allowUnfree = true;
        input-fonts.acceptLicense = true;
      };

      pkgs = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
          overlays = [ claude-code.overlays.default ];
        }
      );

      homeManagerConfigs = forAllSystems (
        system: {
          pkgs = pkgs."${system}";
          modules = [
            ./home

            # needed for comma to work
            nix-index-database.hmModules.nix-index
            { programs.nix-index-database.comma.enable = true; }

          ];
        }
      );
    in
    {
      formatter = forAllSystems (system: pkgs."${system}".nixpkgs-fmt);

      homeConfigurations."asm-mbp-14" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."aarch64-darwin";
      homeConfigurations."asm-mba-13" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."aarch64-darwin";

      packages = pkgs;
    };
}
