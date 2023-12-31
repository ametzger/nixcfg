{ pkgs, ... }: {
  imports = [
    # ./emacs # wip
    ./docker.nix
    ./fish.nix
    ./git.nix
    ./nvim.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    awscli
    black
    cascadia-code
    coreutils
    curl
    dogdns
    detect-secrets
    elixir
    elixir-ls
    eza
    fd
    figlet
    fantasque-sans-mono
    functiontrace-server
    gnupg
    gnused
    httpie
    hyperfine
    ibm-plex
    infracost
    iterm2
    input-fonts
    jetbrains-mono
    jq
    just
    # magic-wormhole
    mtr
    nil
    nixpkgs-fmt
    nmap
    nodejs
    nodePackages.pyright
    openblas
    openssl
    pgbouncer
    postgresql
    (python310.withPackages (ps: with ps; [
      ipython
      mypy
      pipx
      # ruff-lsp
    ]))
    rabbitmq-server
    reattach-to-user-namespace
    rectangle
    redis
    ripgrep
    mise
    ruby
    # ruff
    shellcheck
    socat
    sops
    tflint
    terraform-ls
    terraform-lsp
    tokei
    tree
    trufflehog
    wget
    wrk
    xmlsec
    zlib
    zsh
  ];

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

  # programs.exa = {
  #   enable = true;
  #   enableAliases = true;
  # };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden --no-heading --height 40%";
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.go = {
    enable = true;
    goPath = "proj/go";
    goBin = "proj/go/bin";
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
