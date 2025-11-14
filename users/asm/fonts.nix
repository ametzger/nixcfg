{ pkgs, ... }: {
  home.packages = with pkgs; [
    cascadia-code
    fantasque-sans-mono
    ibm-plex
    input-fonts
    jetbrains-mono
  ];
}
