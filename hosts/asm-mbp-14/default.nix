{ pkgs, ... }:
{
  imports = [
    ../../users/asm
    ./claude.nix
  ];

  home.packages = with pkgs; [
    infracost
    rabbitmq-server
    ssm-session-manager-plugin
  ];

  home.file.".tmuxinator.yml".source = ./tmuxinator.yml;
}
