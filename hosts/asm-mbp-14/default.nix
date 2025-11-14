{ pkgs, ... }:
{
  imports = [
    ../../users/asm
  ];

  home.packages = with pkgs; [
    infracost
    rabbitmq-server
    ssm-session-manager-plugin
  ];

  home.file.".tmuxinator.yml".source = ./tmuxinator.yml;
}
