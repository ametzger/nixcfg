{ pkgs, lib, config, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";

    envExtra = ''
      # pyenv
      if [[ -d ~/.pyenv ]]; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
      fi

      # rbenv
      if [[ -d ~/.rbenv ]]; then
        export RBENV_ROOT="$HOME/.rbenv"
        export PATH="$RBENV_ROOT/bin:$PATH"
      fi

      # nvm
      if [[ -d ~/.nvm ]]; then
        export NVM_DIR="$HOME/.nvm"
      fi

      # golang
      if [[ -d ~/proj/go ]]; then
        export GOPATH="$HOME/proj/go"
        export PATH="$GOPATH/bin:$PATH"
      fi

      if [[ -d ~/.tfenv ]]; then
        export PATH="$HOME/.tfenv/bin:$PATH"
      fi

      if [[ -d ~/.node-versions ]]; then
        export NODE_VERSIONS="$HOME/.node-versions"
      fi

      # workaround for https://discourse.brew.sh/t/why-does-tmuxinator-sets-gem-home/7296/5
      unset -v GEM_HOME

      [[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

      [[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ '
      [[ ! $TERM == "dumb" ]] && TERM=xterm-256color
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore
        ''
          # Handle dumb terms
          [[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return
          fpath+=($HOME/.zfunc)
        '')
      (lib.mkOrder
        1000
        ''
          ## awscli completion
          source '${pkgs.awscli}/share/zsh/site-functions/aws_zsh_completer.sh'

          ## prompt
          # VCS integration setup
          autoload -Uz vcs_info
          precmd_vcs_info() { vcs_info }
          precmd_functions+=( precmd_vcs_info )
          setopt prompt_subst
          zstyle ':vcs_info:git:*' formats '%b'

          # Enable colors in prompt
          autoload -U colors && colors
          zmodload zsh/datetime

          export VIRTUAL_ENV_DISABLE_PROMPT=1
          # Based on https://github.com/sindresorhus/pure but with less
          # functionality
          # TODO: Pure has a nice timer function that fires if a command runs
          # for more than 5 seconds, adding the timestamp seems to be a workable
          # solution but might be nice to add that back in
          if [[ -n ''${SSH_CONNECTION-}''${SSH_CLIENT-}''${SSH_TTY-} ]]; then
            export PS1='
          %{$fg[red]%}%m%{$reset_color%} %{$fg[blue]%}%~%{$reset_color%} %F{242%}%{$vcs_info_msg_0_%}%f%u
          %{%(?.$fg[magenta].$fg[red])%}❯%{$reset_color%} '
          elif [[ "$HOSTNAME" == 'toolbox' ]]; then
            export PS1='
          %{$fg[blue]%}%~%{$reset_color%} (toolbox) %F{242%}%{$vcs_info_msg_0_%}%f%u
          %{%(?.$fg[magenta].$fg[red])%}❯%{$reset_color%} '
          else
            export PS1='
          %{$fg[blue]%}%~%{$reset_color%} %F{242%}%{$vcs_info_msg_0_%}%f%u
          %{%(?.$fg[magenta].$fg[red])%}❯%{$reset_color%} '
          fi

          autoload -z edit-command-line
          zle -N edit-command-line
          bindkey "^X^E" edit-command-line

          # do not highlight pasted text
          zle_highlight+=(paste:none)

          ## mise
          eval "$(${pkgs.mise}/bin/mise activate zsh)"
        '')
    ];

    profileExtra = ''
      export PATH="${lib.concatStringsSep ":" config.home.sessionPath}:$PATH''${PATH:+:}"
    '';
  };
}
