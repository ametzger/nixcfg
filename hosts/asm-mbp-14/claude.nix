{ pkgs, ... }:
let
  settings = {
    enabledPlugins = {
      "pyright-lsp@claude-plugins-official" = true;
    };

    skipDangerousModePermissionPrompt = true;

    extraKnownMarketplaces = {
      jellyfish-marketplace = {
        source = {
          source = "git";
          url = "git@github.com:Jellyfish-AI/jf-claude-plugins.git";
        };
      };
    };
  };

  settingsFile = (pkgs.formats.json { }).generate "claude-settings.json" settings;
in
{
  home.file.".claude/settings.json".source = settingsFile;
  home.file.".claude/CLAUDE.md".source = ./claude-global.md;
}
