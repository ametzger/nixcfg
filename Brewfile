# -*- mode: ruby -*-
# vi: set ft=ruby

hostname = `scutil --get LocalHostName`.strip

tap "homebrew/bundle"

brew "mas"

tap "d12frosted/emacs-plus"
brew "d12frosted/emacs-plus/emacs-plus@30", args: ["with-modern-alecive-flatwoken-icon"]

cask "1password"
cask "1password-cli"
cask "alacritty"
cask "alfred"
cask "appcleaner"
cask "claude"
cask "datagrip"
cask "fantastical"
cask "firefox"
cask "ghostty"
cask "google-chrome"
cask "omnifocus"
cask "pycharm"
cask "rectangle"
cask "slack"
cask "spotify"

mas "1Password for Safari", id: 1569813296

if hostname == "asm-mbp-14"
  cask "linear"
  cask "zoom"
end

if hostname == "asm-mba-13"
  cask "brave-browser"
  cask "docker-desktop"
  cask "dropbox"

  mas "Day One", id: 1055511498
  mas "Drafts", id: 1435957248
  mas "Pixelmator Pro", id: 1289583905
  mas "Things", id: 904280696
end
