{ pkgs
, lib
, config
, ...
}:
let
  concatSessionList = builtins.concatStringsSep ":";
in
{
  home.sessionPath =
    [
      "${config.home.homeDirectory}/.cargo/bin"
      "${config.home.homeDirectory}/.local/bin"
      "${config.home.homeDirectory}/.nix-profile/bin"
      "/usr/local/bin"
      "/usr/local/sbin"
      "/nix/var/nix/profiles/default/bin"
      "/usr/bin"
      "/usr/sbin"
      "/bin"
      "/sbin"
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      "/run/current-system/sw/bin"
      "/opt/homebrew/bin"
    ];

  home.sessionVariables = {
    AWS_PAGER = "";
    AWS_DEFAULT_REGION = "us-east-1";
    CLICOLOR = "true";
    DIRENV_LOG_FORMAT = "";
    DOCKER_BUILDKIT = "1";
    DOCKER_SCAN_SUGGEST = "false";
    DOTNET_CLI_TELEMETRY_OPTOUT = "true";
    EDITOR = "nvim";
    HOMEBREW_NO_ENV_HINTS = "1";
    LANG = "en_US.UTF-8";
    LESS = "-R";
    LSCOLORS = "exfxcxdxbxegedabagacad";
    NIX_PATH = concatSessionList [
      "${config.home.homeDirectory}/.nix-defexpr/channels"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    PYTHONIOENCODING = "UTF-8";
    SSH_KEY_PATH = "$HOME/.ssh/rsa_id";
    SHELL = "${pkgs.zsh}/bin/zsh";
    VIRTUAL_ENV_DISABLE_PROMPT = "1";
    VISUAL = "nvim";
    MISE_MISSING_RUNTIME_BEHAVIOR = "ignore";
  };

  home.shellAliases = {
    cat = "bat";
    tf = "terraform";
    bu = "brew update && brew upgrade";
    ls = "eza";
    exa = "eza";
    m = "p python manage.py";
    nix-cleanup = "nix-collect-garbage --delete-old";
    p = "pdm run";
    psg = "ps auxwww | rg";
    scratch = "nvim ~/scratch.txt";
    sp = "EDITOR=emacs m shell_plus";
    t = "p pytest --reuse-db --ds=jellyfish.settings.test";
    vim = "nvim";
  };
}
