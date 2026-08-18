{
  description = "asm nix configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Pinned to avoid emacs rebuild cost - `just update-emacs` to bump
    emacs-nixpkgs.url = "github:NixOS/nixpkgs/3e41b24abd260e8f71dbe2f5737d24122f972158";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # claude-code = {
    #   url = "github:sadjow/claude-code-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs
    , emacs-nixpkgs
    , home-manager
    , nix-index-database
      # , claude-code
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
          # overlays = [ claude-code.overlays.default ];
        }
      );

      # pinned nixpkgs to avoid emacs rebuild on `just update`
      emacsPkgs = forAllSystems (
        system:
        import emacs-nixpkgs {
          inherit system;
          config = nixpkgsConfig;
        }
      );

      mkHomeConfiguration = hostname: system:
        let
          nurPkgs = import nur {
            nurpkgs = pkgs."${system}";
            pkgs = pkgs."${system}";
          };
        in
        {
          pkgs = pkgs."${system}";
          modules = [
            ./hosts/${hostname}

            # needed for comma to work
            nix-index-database.homeModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
          extraSpecialArgs = {
            nur = nurPkgs;
            emacsPkgs = emacsPkgs."${system}";
          };
        };
    in
    {
      formatter = forAllSystems (system: pkgs."${system}".nixpkgs-fmt);

      homeConfigurations = {
        "asm-mbp-14" = home-manager.lib.homeManagerConfiguration (mkHomeConfiguration "asm-mbp-14" "aarch64-darwin");
        "asm-mba-13" = home-manager.lib.homeManagerConfiguration (mkHomeConfiguration "asm-mba-13" "aarch64-darwin");
      };

      devShells = forAllSystems (
        system:
        let
          pkgsForSystem = pkgs."${system}";
        in
        {
          default = pkgsForSystem.mkShell {
            packages = with pkgsForSystem; [
              git
              just
              nil
              nixpkgs-fmt
            ];
          };
        }
      );
    };
}
