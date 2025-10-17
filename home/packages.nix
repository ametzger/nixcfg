{ pkgs, ... }:
let
  # TODO(asm,2025-01-28): remove this once https://github.com/NixOS/nixpkgs/pull/375601 is merged
  displayplacer = import ./displayplacer.nix {
    inherit (pkgs) lib stdenv fetchFromGitHub makeWrapper apple-sdk;
  };
in
{
  imports = [
    ./emacs
    ./docker.nix
    ./fish.nix
    ./git.nix
    ./nvim.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    awscli2
    black
    cascadia-code
    claude-code
    coreutils
    curl
    delta
    detect-secrets
    dogdns
    drill
    duckdb
    elixir
    elixir-ls
    eza
    fantasque-sans-mono
    fd
    figlet
    functiontrace-server
    gnupg
    gnused
    httpie
    hyperfine
    ibm-plex
    infracost
    input-fonts
    iterm2
    jetbrains-mono
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
    # postgresql
    pyright
    (python311.withPackages (ps: with ps; [
      ipython
      mypy
      pipx
      # ruff-lsp
    ]))
    qmk
    rabbitmq-server
    reattach-to-user-namespace
    rectangle
    redis
    ripgrep
    ruby
    # ruff
    shellcheck
    socat
    sops
    ssm-session-manager-plugin
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
  ] ++ (lib.optionals (pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64) [
    displayplacer
    pkgs.tart
  ]);

  # home-manager derived configurations
  programs.bash = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden --no-heading --height 40%";
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.go = {
    enable = true;
    env = {
      GOPATH = "proj/go";
      GOBIN = "proj/go/bin";
    };
  };

  programs.kakoune.enable = true;

  programs.zellij.enable = true;

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
}
