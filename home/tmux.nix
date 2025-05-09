{ pkgs
, ...
}: {
  programs.tmux = {
    enable = true;

    prefix = "C-b";
    keyMode = "emacs";
    baseIndex = 1;

    shell = "${pkgs.zsh}/bin/zsh";

    # NOTE(asm,2024-11-13): for some reason, this seems to be forcing my shell to be `/bin/sh`, I
    # think there's something busted with `reattach-to-user-namespace`. Almost all of the sensible
    # stuff is already in my config, so just disable it.
    sensibleOnTop = false;

    plugins = with pkgs.tmuxPlugins;
      [
        better-mouse-mode
        copycat
        pain-control
        prefix-highlight
        yank
      ];

    tmuxinator = {
      enable = true;
    };

    extraConfig = ''
      # General config
      setw -g monitor-activity off # this is annoying for stuff like runserver
      set -g renumber-windows on

      # Renumber sessions
      set-hook -g session-created "run ~/bin/renumber-sessions.sh"
      set-hook -g session-closed  "run ~/bin/renumber-sessions.sh"

      # Window titles
      set-option -g status-interval 5
      set-option -g automatic-rename on
      set-option -g automatic-rename-format '#(basename "#{pane_current_path}")'
      # set-option -g set-titles on

      setw -g mouse on
      bind -n WheelUpPane   select-pane -t= \; copy-mode -e \; send-keys -M
      bind -n WheelDownPane select-pane -t= \;                 send-keys -M

      # Default split binds make no sense
      bind |  split-window -h -c "#{pane_current_path}"
      bind \\ split-window -h -c "#{pane_current_path}"
      bind -  split-window -v -c "#{pane_current_path}"

      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Emacs-ier movement
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'S-Left' if-shell "$is_vim" 'send-keys S-Left'  'select-pane -L'
      bind-key -n 'S-Right' if-shell "$is_vim" 'send-keys S-Right'  'select-pane -R'
      bind-key -n 'S-Up' if-shell "$is_vim" 'send-keys S-Up'  'select-pane -U'
      bind-key -n 'S-Down' if-shell "$is_vim" 'send-keys S-Down'  'select-pane -D'
      # bind -n S-Left  select-pane -L
      # bind -n S-Right select-pane -R
      # bind -n S-Up    select-pane -U
      # bind -n S-Down  select-pane -D

      # Move panes with C-S-left/right
      bind -n C-S-Left swap-pane -U
      bind -n C-S-Right swap-pane -D

      # Move windows with <prefix>+< / <prefix>+>
      # bind-key "<" swap-window -t -1
      # bind-key ">" swap-window -t +1

      # Emacs-ier copy/paste
      bind-key -T copy-mode M-w send-keys -X copy-pipe-and-cancel "reattach-to-user-namespace pbcopy"
      bind-key -T copy-mode C-g send-keys -X cancel

      # True color
      set-option -ga terminal-overrides ",xterm-256color:Tc"

      # catppuccin theme

      # # --> Catppuccin (Latte)
      # thm_bg="#dce0e8"
      # thm_fg="#4c4f69"
      # thm_cyan="#179299"
      # thm_black="#e6e9ef"
      # thm_gray="#bcc0cc"
      # thm_magenta="#ea76cb"
      # thm_pink="#8839ef"
      # thm_red="#d20f39"
      # thm_green="#40a02b"
      # thm_yellow="#df8e1d"
      # thm_blue="#1e66f5"
      # thm_orange="#fe640b"
      # thm_black4="#acb0be"

      # --> Catppuccin
      thm_bg="#1e1e28"
      thm_fg="#dadae8"
      thm_cyan="#c2e7f0"
      thm_black="#15121c"
      thm_gray="#332e41"
      thm_magenta="#c6aae8"
      thm_pink="#e5b4e2"
      thm_red="#e38c8f"
      thm_green="#b1e3ad"
      thm_yellow="#ebddaa"
      thm_blue="#a4b9ef"
      thm_orange="#f9c096"
      thm_black4="#575268"

      # status
      set -g status-position bottom
      set -g status "on"
      set -g status-bg "''${thm_bg}"
      set -g status-justify "left"
      set -g status-left-length "100"
      set -g status-right-length "100"

      # messages
      set -g message-style fg="''${thm_cyan}",bg="''${thm_gray}",align="centre"
      set -g message-command-style fg="''${thm_cyan}",bg="''${thm_gray}",align="centre"

      # panes
      set -g pane-border-style fg="''${thm_gray}"
      set -g pane-active-border-style fg="''${thm_blue}"

      # windows
      setw -g window-status-activity-style fg="''${thm_fg}",bg="''${thm_bg}",none
      setw -g window-status-separator ""
      setw -g window-status-style fg="''${thm_fg}",bg="''${thm_bg}",none

      set -g status-left ""
      set -g status-right "#[bg=$thm_gray]#{?client_prefix,#[bg=$thm_red],#[bg=$thm_green]}#[fg=$thm_bg] #S #[fg=$thm_fg,bg=$thm_gray]"

      # current_dir
      setw -g window-status-format "#[fg=$thm_bg,bg=$thm_blue] #I #[fg=$thm_fg,bg=$thm_gray] #{b:window_name} #F "
      setw -g window-status-current-format "#[fg=$thm_bg,bg=$thm_orange] #I #[fg=$thm_fg,bg=$thm_bg] #{b:window_name} #F "

      # parent_dir/current_dir
      # setw -g window-status-format "#[fg=colour232,bg=colour111] #I #[fg=colour222,bg=colour235] #(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev) "
      # setw -g window-status-current-format "#[fg=colour232,bg=colour208] #I #[fg=colour255,bg=colour237] #(echo '#{pane_current_path}' | rev | cut -d'/' -f-2 | rev) "

      # --------=== Modes
      setw -g clock-mode-colour "''${thm_blue}"
      setw -g mode-style "fg=''${thm_pink} bg=''${thm_black4} bold"
    '';
  };

  home.file.".tmuxinator.yml".source = ./etc/tmuxinator.yml;
}
