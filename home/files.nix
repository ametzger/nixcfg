{ pkgs
, lib
, config
, ...
}: {
  home.file.bin = {
    source = ./scripts;
    recursive = true;
  };

  home.file.".asdfrc".source = ./etc/asdfrc;
  home.file.".config/alacritty/alacritty.yml".source = pkgs.substituteAll {
    name = "alacritty.yml";
    src = ./etc/alacritty.yml;
    zsh = "${pkgs.zsh}";
  };
  home.file.".config/black".source = ./etc/black;
  home.file.".config/flake8".source = ./etc/flake8;
  home.file.".config/kitty/kitty.conf".source = ./etc/kitty.conf;
  home.file.".direnvrc".source = ./etc/direnvrc;
  home.file.".editorconfig".source = ./etc/editorconfig;
  home.file.".gemrc".source = ./etc/gemrc;
  home.file.".irbrc".source = ./etc/irbrc;
  home.file.".psqlrc".source = ./etc/psqlrc;
  home.file.".pylintrc".source = ./etc/pylintrc;
  home.file.".ripgreprc".source = ./etc/ripgreprc;
  home.file.".spacemacs".source = ./etc/spacemacs;
  home.file.".tmuxinator.yml".source = ./etc/tmuxinator.yml;
  home.file.".tool-versions".source = ./etc/tool-versions;
}
