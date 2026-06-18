{ pkgs, ... }:
{
  imports = [
    ../../users/asm
  ];

  local.claude.extraSettings.extraKnownMarketplaces.jellyfish-marketplace = {
    source = {
      source = "git";
      url = "git@github.com:Jellyfish-AI/jf-claude-plugins.git";
    };
  };

  home.packages = with pkgs; [
    infracost
    rabbitmq-server
    ssm-session-manager-plugin
  ];

  home.file.".tmuxinator.yml".source = ./tmuxinator.yml;
}
