{ config, lib, pkgs, ... }:
let
  cfg = config.local.claude;

  baseSettings = {
    enabledPlugins = {
      "pyright-lsp@claude-plugins-official" = true;
    };
    skipDangerousModePermissionPrompt = true;
  };

  settings = lib.recursiveUpdate baseSettings cfg.extraSettings;
  settingsFile = (pkgs.formats.json { }).generate "claude-settings.json" settings;
in
{
  options.local.claude = {
    enable = lib.mkEnableOption "Claude Code configuration";

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Host-specific settings merged over the shared baseline.";
    };

    globalInstructions = lib.mkOption {
      type = lib.types.path;
      default = ./claude-global.md;
      description = "Source file for the global ~/.claude/CLAUDE.md.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".claude/settings.json".source = settingsFile;
    home.file.".claude/CLAUDE.md".source = cfg.globalInstructions;
  };
}
