{ pkgs
, ...
}: {
  home.file.bin = {
    source = ./scripts;
    recursive = true;
  };

  home.file.".asdfrc".source = ./etc/asdfrc;
  home.file.".config/alacritty/alacritty.toml".source = pkgs.replaceVars ./etc/alacritty.toml {
    zsh = "${pkgs.zsh}";
  };
  home.file.".config/black".source = ./etc/black;
  home.file.".config/direnv/direnv.toml".source = ./etc/direnv.toml;
  home.file.".config/flake8".source = ./etc/flake8;
  home.file.".config/ghostty/config".source = ./etc/ghostty;
  home.file.".config/kitty/kitty.conf".source = ./etc/kitty.conf;
  home.file.".default-python-packages".source = ./etc/default-python-packages;
  home.file.".direnvrc".source = ./etc/direnvrc;
  home.file.".editorconfig".source = ./etc/editorconfig;
  home.file.".gemrc".source = ./etc/gemrc;
  home.file.".ipython/profile_default/ipython_config.py".source = ./etc/ipython_config.py;
  home.file.".irbrc".source = ./etc/irbrc;
  home.file.".psqlrc".source = ./etc/psqlrc;
  home.file.".pylintrc".source = ./etc/pylintrc;
  home.file.".ripgreprc".source = ./etc/ripgreprc;
  home.file.".spacemacs".source = ./etc/spacemacs;
  home.file.".config/mise/config.toml".source = ./etc/mise-config.toml;
  home.file."Library/Application Support/qmk/qmk.ini".source = ./etc/qmk.ini;
}
