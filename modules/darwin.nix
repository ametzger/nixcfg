{ pkgs, lib, inputs, ... }: {
  # environment.systemPackages =
  #   [
  #     pkgs.vim
  #   ];

  # this sets up /etc/zshrc with nix loaded
  programs.zsh.enable = true;

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  system.stateVersion = 4;
}
