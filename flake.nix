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
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs
    , home-manager
    , nix-index-database
    , claude-code
    , nur
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
        system:
        let
          nurPkgs = import nur {
            nurpkgs = pkgs."${system}";
            pkgs = pkgs."${system}";
          };
        in
        {
          pkgs = pkgs."${system}";
          modules = [
            ./home

            # needed for comma to work
            nix-index-database.homeModules.nix-index
            { programs.nix-index-database.comma.enable = true; }

          ];
          extraSpecialArgs = {
            nur = nurPkgs;
          };
        }
      );
    in
    {
      formatter = forAllSystems (system: pkgs."${system}".nixpkgs-fmt);

      homeConfigurations."asm-mbp-14" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."aarch64-darwin";
      homeConfigurations."asm-mba-13" = home-manager.lib.homeManagerConfiguration homeManagerConfigs."aarch64-darwin";

      packages = pkgs;

      devShells = forAllSystems (
        system:
        let
          pkgsForSystem = pkgs."${system}";
        in
        {
          default = pkgsForSystem.mkShell {
            packages = with pkgsForSystem; [
              nixpkgs-fmt
              nil
              just
            ];

            shellHook = ''
              echo "Nix configuration development shell"
              echo "Available commands:"
              echo "  just build    - Build the configuration"
              echo "  just switch   - Build and activate"
              echo "  just fmt      - Format Nix files"
              echo "  just debug    - Build with debug output"
              echo ""
              echo "Current hostname: $(scutil --get LocalHostName 2>/dev/null || hostname)"
            '';
          };
        }
      );
    };
}
