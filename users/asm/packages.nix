{ pkgs, ... }:
let
  # TODO(asm,2025-01-28): remove this once https://github.com/NixOS/nixpkgs/pull/375601 is merged
  displayplacer = import ./displayplacer.nix {
    inherit (pkgs) lib stdenv fetchFromGitHub makeWrapper apple-sdk;
  };
in
{
  imports = [
    ./docker.nix
    ./emacs
    ./fish.nix
    ./fonts.nix
    ./git.nix
    ./nvim.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    awscli2
    black
    # claude-code
    coreutils
    curl
    delta
    # detect-secrets
    drill
    duckdb
    elixir
    elixir-ls
    eza
    fd
    figlet
    functiontrace-server
    gnupg
    gnused
    httpie
    hyperfine
    jq
    just
    mise
    mtr
    nil
    nixpkgs-fmt
    nmap
    nodejs
    openblas
    openssl
    pgbouncer
    pyright
    (python314.withPackages (ps: with ps; [
      ipython
      mypy
      pipx
      # ruff-lsp
    ]))
    reattach-to-user-namespace
    redis
    ripgrep
    ruby
    # ruff
    shellcheck
    socat
    sops
    terraform-ls
    terraform-lsp
    tflint
    tokei
    tree
    tree-sitter
    wget
    wrk
    xmlsec
    zlib
    zsh
  ] ++ (lib.optionals (pkgs.stdenv.isDarwin) [
    iterm2
  ]) ++ (lib.optionals (pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64) [
    displayplacer
    rectangle
    pkgs.tart
  ]);

  programs = {
    bash = {
      enable = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "Nord";
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      defaultCommand = "rg --files --hidden --no-heading --height 40%";
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    go = {
      enable = true;
      env = {
        GOPATH = "proj/go";
        GOBIN = "proj/go/bin";
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Alex Metzger";
          email = "asm@asm.io";
        };

        "default-command" = "log";
      };
    };

    kakoune.enable = true;

    television.enable = true;

    topgrade.enable = true;

    zellij.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };
}
