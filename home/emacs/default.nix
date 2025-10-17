{ pkgs, nur, ... }:
let
  activeTheme = "doom-nord";
  # customEmacsIcon = ./Emacs.icns;
in
{
  imports = [
    nur.repos.rycee.hmModules.emacs-init
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;

    # TODO(asm,2025-10-17): This will override the emacs.app icon on macOS, but it makes nix build
    # emacs from scratch which takes forever.
    # package = pkgs.emacs.overrideAttrs (oldAttrs: {
    #   postInstall = (oldAttrs.postInstall or "") + ''
    #     # Replace the default Emacs icon with custom icon on macOS
    #     if [ -d "$out/Applications/Emacs.app/Contents/Resources" ]; then
    #       cp ${customEmacsIcon} "$out/Applications/Emacs.app/Contents/Resources/Emacs.icns"
    #     fi
    #   '';
    # });
  };

  home.file = {
    ".emacs.d/snippets".source = ./snippets;
  };

  programs.emacs.init = {
    enable = true;
    packageQuickstart = false;
    recommendedGcSettings = true;
    usePackageVerbose = false;
    startupTimer = true;

    earlyInit = ''
      ;; Disable some GUI distractions
      (when (fboundp 'tool-bar-mode)
        (tool-bar-mode -1))
      (blink-cursor-mode -1)
      (when (fboundp 'scroll-bar-mode)
        (scroll-bar-mode -1))
    '';

    prelude = ''
      ;; Set up fonts early
      (let* ((font-candidates '("Go Mono"
                                "Operator Mono"
                                "SF Mono"
                                "IBM Plex Mono Medium"
                                "Cascadia Code"))
             (font-name (seq-find #'x-list-fonts font-candidates nil))
             (font-size (if (eq system-type 'darwin) 18 13)))
        (when font-name
          (set-frame-font (format "%s %d" font-name font-size) t t)))

      ;; User info
      (setq user-full-name "Alex Metzger"
            user-mail-address "asm@asm.io"
            user-login-name "asm")

      ;; Disable startup message
      (setq inhibit-startup-screen t
            initial-scratch-message "Hello.\n\n"
            initial-major-mode 'text-mode)

      ;; Basic Emacs settings
      (setq line-spacing 0
            gc-cons-threshold 100000000
            large-file-warning-threshold 50000000
            read-process-output-max (* 1024 1024)
            save-interprogram-paste-before-kill t
            help-window-select t
            confirm-kill-emacs 'y-or-n-p
            ring-bell-function 'ignore
            scroll-margin 3
            scroll-conservatively 100000
            scroll-preserve-screen-position 1
            auto-window-vscroll nil
            frame-resize-pixelwise t
            show-trailing-whitespace t
            frame-title-format nil
            frame-inhibit-implied-resize t)

      (setq custom-file (locate-user-emacs-file "custom.el"))
      (if (file-exists-p custom-file)
        (load custom-file))

      ;; Accept 'y' and 'n' rather than 'yes' and 'no'
      (fset 'yes-or-no-p 'y-or-n-p)

      ;; Enable useful commands
      (put 'narrow-to-region 'disabled nil)
      (put 'downcase-region 'disabled nil)
      (put 'upcase-region 'disabled nil)

      ;; Indentation
      (setq-default indent-tabs-mode nil
                    tab-width 4
                    sh-basic-offset 2
                    fill-column 100)

      ;; Newline settings
      (setq require-final-newline t
            sentence-end-double-space nil)

      ;; UTF-8 encoding
      (set-charset-priority 'unicode)
      (set-terminal-coding-system 'utf-8)
      (set-keyboard-coding-system 'utf-8)
      (set-selection-coding-system 'utf-8)
      (prefer-coding-system 'utf-8)
      (setq default-process-coding-system '(utf-8-unix . utf-8-unix)
            locale-coding-system 'utf-8)

      ;; Backup files
      (setq backup-directory-alist `((".*" . ,temporary-file-directory))
            auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
            backup-by-copying t)

      ;; Line and column numbers
      (line-number-mode t)
      (column-number-mode t)
      (size-indication-mode t)

      ;; Delete selection mode
      (delete-selection-mode t)

      ;; Global auto-revert
      (global-auto-revert-mode t)

      ;; Indentation on RET
      (global-set-key (kbd "RET") #'newline-and-indent)

      ;; Smart tab behavior
      (setq tab-always-indent 'complete)

      ;; macOS specific settings
      (when (eq system-type 'darwin)
        (setq delete-by-moving-to-trash t
              trash-directory "~/.Trash")
        (put 'ns-print-buffer 'disabled t)
        (put 'suspend-frame 'disabled t)
        (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
        (add-to-list 'default-frame-alist '(ns-appearance . dark))
        (setq-default ns-use-srgb-colorspace t
                      ns-use-proxy-icon nil)
        (global-set-key (kbd "s-n") #'make-frame-command))

      ;; Disable version control
      (remove-hook 'find-file-hook 'vc-find-file-hook)
      (setq vc-handled-backends ())

      ;; Disable semantic mode
      (semantic-mode -1)

      ;; imenu settings
      (setq imenu-auto-rescan t
            imenu-auto-rescan-maxout (* 1024 1024)
            imenu--rescan-item '("" . -99))
      (add-hook 'imenu-after-jump-hook
                (lambda () (recenter scroll-margin)))

      ;; Savefile directory
      (defconst asm/savefile-dir
        (expand-file-name "savefile" user-emacs-directory))
      (unless (file-exists-p asm/savefile-dir)
        (make-directory asm/savefile-dir))

      ;; Custom keybindings
      (global-set-key [remap eval-expression] 'pp-eval-expression)
      (global-set-key (kbd "C-x C-b") #'ibuffer)
      (global-set-key (kbd "C-c k")
                      (lambda ()
                        (interactive)
                        (kill-this-buffer)))
      (global-set-key (kbd "C-M-.") #'xref-find-definitions-other-window)
      (global-set-key (kbd "C-x \\") #'align-regexp)
      (global-set-key (kbd "M-/") #'hippie-expand)

      ;; Window management functions
      (defun asm/window-max ()
        (interactive)
        (toggle-frame-maximized))

      (defun asm/split-window-vertically ()
        (interactive)
        (split-window-vertically)
        (balance-windows)
        (other-window 1))

      (defun asm/split-window-horizontally ()
        (interactive)
        (split-window-horizontally)
        (balance-windows)
        (other-window 1))

      (defun asm/delete-windows-and-rebalance ()
        (interactive)
        (unless (one-window-p)
          (delete-window)
          (balance-windows)))

      (global-set-key (kbd "C-x 2") #'asm/split-window-vertically)
      (global-set-key (kbd "C-x 3") #'asm/split-window-horizontally)
      (global-set-key (kbd "C-x 0") #'asm/delete-windows-and-rebalance)

      (defun asm/toggle-window-split ()
        (interactive)
        (if (= (count-windows) 2)
            (let* ((this-win-buffer (window-buffer))
                   (next-win-buffer (window-buffer (next-window)))
                   (this-win-edges (window-edges (selected-window)))
                   (next-win-edges (window-edges (next-window)))
                   (this-win-2nd (not (and (<= (car this-win-edges)
                                               (car next-win-edges))
                                           (<= (cadr this-win-edges)
                                               (cadr next-win-edges)))))
                   (splitter
                    (if (= (car this-win-edges)
                           (car (window-edges (next-window))))
                        'split-window-horizontally
                      'split-window-vertically)))
              (delete-other-windows)
              (let ((first-win (selected-window)))
                (funcall splitter)
                (if this-win-2nd (other-window 1))
                (set-window-buffer (selected-window) this-win-buffer)
                (set-window-buffer (next-window) next-win-buffer)
                (select-window first-win)
                (if this-win-2nd (other-window 1))))))

      (global-set-key (kbd "C-c |") #'asm/toggle-window-split)

      (defun asm/select-current-line ()
        "Select the current line."
        (interactive)
        (end-of-line)
        (set-mark (line-beginning-position))
        (forward-line))

      (global-set-key (kbd "C-S-SPC") #'asm/select-current-line)

      (defun asm/switch-to-previous-buffer ()
        "Switch to previously open buffer."
        (interactive)
        (switch-to-buffer (other-buffer (current-buffer) 1)))

      (global-set-key (kbd "C-c b") #'asm/switch-to-previous-buffer)

      (defun asm/occur-dwim ()
        (interactive)
        (push (if (region-active-p)
                  (buffer-substring-no-properties
                   (region-beginning)
                   (region-end))
                (thing-at-point 'symbol))
              regexp-history)
        (call-interactively 'occur))

      (global-set-key (kbd "M-s o") #'asm/occur-dwim)

      (defun asm/comment-sanely ()
        (interactive)
        (if (region-active-p)
            (comment-dwim nil)
          (let (($lbp (line-beginning-position))
                ($lep (line-end-position)))
            (if (eq $lbp $lep)
                (comment-dwim nil)
              (if (eq (point) $lep)
                  (comment-dwim nil)
                (progn
                  (comment-or-uncomment-region $lbp $lep)
                  (forward-line)))))))

      (global-set-key (kbd "M-;") #'asm/comment-sanely)

      ;; Hippie expand configuration
      (setq hippie-expand-try-functions-list
            '(try-expand-dabbrev
              try-expand-dabbrev-all-buffers
              try-expand-dabbrev-from-kill
              try-complete-file-name-partially
              try-complete-file-name
              try-expand-all-abbrevs
              try-expand-list
              try-expand-line
              try-complete-lisp-symbol-partially
              try-complete-lisp-symbol))

      ;; Menu bar configuration
      (defun asm/menubar-config (&optional frame)
        (interactive)
        (set-frame-parameter frame 'menu-bar-lines
          (if (and (display-graphic-p frame)
                (memq window-system '(mac ns)))
            1 0)))
      (add-hook 'after-make-frame-functions 'asm/menubar-config)

      (defun display-startup-echo-area-message ()
        (message "Howdy!"))

      ;; Add initialization time to scratch buffer
      (add-hook 'after-init-hook
                (lambda ()
                  (let ((welcome-message (format "Welcome to Emacs %s (started %s)\ninitialization took: %s\n\n"
                                    emacs-version
                                    (current-time-string)
                                    (emacs-init-time))))
                  (with-current-buffer "*scratch*"
                    (goto-char (point-max))
                    (insert welcome-message))
                  (setq initial-scratch-message welcome-message))))

      ;; Maximize window on startup
      (add-hook 'after-init-hook #'asm/window-max)

      ;; Font customization
      (custom-set-faces
       '(font-lock-comment-face ((t (:foreground "#6d7a96" :slant italic))))
       '(font-lock-doc-face ((t (:foreground "#6d7a96" :slant italic))))
       '(font-lock-keyword-face ((t (:foreground "#81A1C1" :slant italic)))))
    '';

    usePackage = {
      # Built-in packages
      server = {
        enable = true;
        defer = 2;
        config = ''
          (unless (server-running-p)
            (server-start))
        '';
      };

      paren = {
        enable = true;
        config = "(show-paren-mode +1)";
      };

      hl-line = {
        enable = true;
        config = "(global-hl-line-mode +1)";
      };

      abbrev = {
        enable = true;
        diminish = [ "abbrev-mode" ];
        config = ''
          (setq save-abbrevs 'silently)
          (setq-default abbrev-mode t)
        '';
      };

      uniquify = {
        enable = true;
        config = ''
          (setq uniquify-buffer-name-style 'forward
                uniquify-separator "/"
                uniquify-after-kill-buffer-p t
                uniquify-ignore-buffers-re "^\\*")
        '';
      };

      savehist = {
        enable = true;
        config = ''
          (setq savehist-additional-variables
                '(search-ring regexp-search-ring)
                savehist-autosave-interval 60
                savehist-file (expand-file-name "savehist" asm/savefile-dir))
          (savehist-mode +1)
        '';
      };

      recentf = {
        enable = true;
        config = ''
          (setq recentf-save-file (expand-file-name "recentf" asm/savefile-dir)
                recentf-max-saved-items 500
                recentf-max-menu-items 15
                recentf-auto-cleanup 'never)
          (recentf-mode +1)
        '';
      };

      windmove = {
        enable = true;
        config = "(windmove-default-keybindings)";
      };

      winner = {
        enable = true;
        config = "(winner-mode)";
      };

      dired = {
        enable = true;
        bindLocal.dired-mode-map = {
          "RET" = "dired-find-alternate-file";
          "^" = "(lambda () (interactive) (find-alternate-file \"..\"))";
        };
        hook = [ "(dired-mode . auto-revert-mode)" ];
        config = ''
          (require 'ls-lisp)
          (setq ls-lisp-dirs-first t
                ls-lisp-use-insert-directory-program nil)
          (put 'dired-find-alternate-file 'disabled nil)
          (setq dired-recursive-deletes 'always
                dired-recursive-copies 'always
                dired-dwim-target t)
        '';
      };

      dired-x = {
        enable = true;
        after = [ "dired" ];
        hook = [ "(dired-mode . dired-omit-mode)" ];
        config = ''
          (setq dired-omit-verbose nil
                dired-omit-files
                "^\\.?#\\|^.DS_STORE$\\|^.projectile$\\|^.git$\\|^.CFUserTextEncoding$\\|^.Trash$\\|^__pycache__$")
        '';
      };

      lisp-mode = {
        enable = true;
        hook = [
          "(emacs-lisp-mode . eldoc-mode)"
          "(lisp-interaction-mode . eldoc-mode)"
          "(eval-expression-minibuffer-setup . eldoc-mode)"
        ];
        bindLocal.emacs-lisp-mode-map = {
          "C-c C-c" = "eval-defun";
          "C-c C-b" = "eval-buffer";
        };
      };

      ielm = {
        enable = true;
        hook = [ "(ielm-mode . eldoc-mode)" ];
      };

      ibuffer = {
        enable = true;
        config = "(setq ibuffer-default-sorting-mode 'major-mode)";
      };

      re-builder = {
        enable = true;
        config = "(setq reb-re-syntax 'string)";
      };

      # Theme and appearance
      doom-themes = {
        enable = true;
        init = ''
          (setq doom-themes-enable-bold t
                doom-themes-enable-italic t
                doom-nord-brighter-comments nil
                doom-nord-region-highlight 'frost
                doom-nord-padded-modeline t)
        '';
        config = ''
          (load-theme '${activeTheme} t)
        '';
      };

      all-the-icons = {
        enable = true;
        extraConfig = ":if (display-graphic-p)";
      };

      all-the-icons-dired = {
        enable = true;
        after = [ "all-the-icons" ];
        hook = [ "(dired-mode . all-the-icons-dired-mode)" ];
      };

      nerd-icons = {
        enable = true;
      };

      doom-modeline = {
        enable = true;
        after = [ "nerd-icons" ];
        init = ''
          (setq doom-modeline-python-executable (expand-file-name "~/.local/share/mise/shims/python")
                doom-modeline-lsp nil
                doom-modeline-mu4e nil
                doom-modeline-irc nil
                doom-modeline-env-version nil)
        '';
        hook = [ "(after-init . doom-modeline-mode)" ];
      };

      # Org mode
      org = {
        enable = true;
        bind = {
          "C-c c" = "org-capture";
          "C-c a" = "org-agenda";
        };
        bindLocal.org-mode-map = {
          "C-a" = "crux-move-beginning-of-line";
        };
        hook = [
          ''
            (org-mode . (lambda ()
                          (auto-fill-mode t)
                          (visual-line-mode t)))
          ''
        ];
        config = ''
          (org-babel-do-load-languages
           'org-babel-load-languages
           '((python . t)
             (emacs-lisp . t)))
          (setq org-directory "~/org"
                org-default-notes-file (concat org-directory "/inbox.org")
                org-agenda-files (mapcar
                                  (lambda (path)
                                    (concat org-directory "/" path))
                                  '("inbox.org"))
                org-capture-templates '(("i" "Inbox" entry (file "inbox.org")
                                         "* %?\n/Entered on/ %U"
                                         :prepend t)
                                        ("t" "Todo" entry (file "inbox.org")
                                         "* TODO %?"
                                         :prepend t))
                org-use-speed-commands t
                org-return-follows-link t
                org-confirm-babel-evaluate nil)
          (add-hook 'org-shiftup-final-hook 'windmove-up)
          (add-hook 'org-shiftleft-final-hook 'windmove-left)
          (add-hook 'org-shiftdown-final-hook 'windmove-down)
          (add-hook 'org-shiftright-final-hook 'windmove-right)
          (require 'org-tempo)
        '';
      };

      org-bullets = {
        enable = true;
        after = [ "org" ];
        hook = [ "(org-mode . org-bullets-mode)" ];
      };

      # Usability enhancements
      helpful = {
        enable = true;
        command = [ "helpful-callable" "helpful-variable" "helpful-at-point" "helpful-command" "helpful-key" ];
        bind = {
          "C-c C-d" = "helpful-at-point";
        };
        config = ''
          (global-set-key [remap describe-function] #'counsel-describe-function)
          (global-set-key [remap describe-command] #'helpful-command)
          (global-set-key [remap describe-variable] #'counsel-describe-variable)
          (global-set-key [remap describe-key] #'helpful-key)
        '';
      };

      s = {
        enable = true;
      };

      avy = {
        enable = true;
        bind = {
          "s-." = "avy-goto-word-or-subword-1";
          "s-," = "avy-goto-char-timer";
          "C-'" = "avy-goto-char-2";
          "M-g f" = "avy-goto-line";
          "M-g w" = "avy-goto-word-1";
        };
        config = "(setq avy-background t)";
      };

      # Git integration
      magit = {
        enable = true;
        bind = { "C-x g" = "magit-status"; };
        config = ''
          (add-hook 'after-save-hook #'magit-after-save-refresh-status)
          (setq magit-repository-directories '(("~/proj/" . 2))
                magit-restore-window-configuration t
                magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1
                magit-bury-buffer-function #'magit-restore-window-configuration)
        '';
      };

      git-timemachine = {
        enable = true;
        bind = { "s-g" = "git-timemachine"; };
      };

      git-link = {
        enable = true;
        defer = true;
        bind = { "C-c g" = "git-link"; };
        config = "(setq git-link-use-commit t)";
      };

      # Project management
      mise = {
        enable = true;
        hook = [ "(after-init . global-mise-mode)" ];
      };

      direnv = {
        enable = true;
        config = ''
          (setq direnv-always-show-summary nil)
          (direnv-mode)
        '';
      };

      ripgrep = {
        enable = true;
        extraConfig = ":if (executable-find \"rg\")";
      };

      deadgrep = {
        enable = true;
        after = [ "ripgrep" "projectile" ];
        config = ''
          (defun asm/deadgrep-project-root ()
            (if (projectile-project-p)
                (projectile-project-root)
              default-directory))
          (setq deadgrep-project-root-function #'asm/deadgrep-project-root)
        '';
      };

      wgrep = {
        enable = true;
      };

      dumb-jump = {
        enable = true;
        config = ''
          (setq dumb-jump-default-project "~/proj"
                dumb-jump-selector 'ivy
                dumb-jump-force-searcher 'rg)
          (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
        '';
      };

      projectile = {
        enable = true;
        diminish = [ "projectile-mode" ];
        demand = true;
        bindLocal = {
          projectile-mode-map = {
            "C-c p" = "projectile-command-map";
          };
          projectile-command-map = {
            "F" = "projectile-find-file-other-window";
          };
        };
        config = ''
          (setq projectile-completion-system 'ivy
                projectile-enable-caching t)
          (projectile-mode +1)
        '';
      };

      # Editing enhancements
      expand-region = {
        enable = true;
        bind = { "C-=" = "er/expand-region"; };
      };

      browse-kill-ring = {
        enable = true;
        bind = { "C-M-y" = "browse-kill-ring"; };
      };

      multiple-cursors = {
        enable = true;
        bind = {
          "C-;" = "mc/mark-all-like-this-dwim";
          "C->" = "mc/mark-next-like-this";
          "C-<" = "mc/mark-previous-like-this";
          "C-S-<mouse-1>" = "mc/add-cursor-on-click";
        };
        config = "(define-key mc/keymap (kbd \"<return>\") nil)";
      };

      iedit = {
        enable = true;
        bind = { "C-c ;" = "iedit-mode"; };
      };

      anzu = {
        enable = true;
        bind = {
          "M-%" = "anzu-query-replace";
          "C-M-%" = "anzu-query-replace-regexp";
        };
        config = "(global-anzu-mode)";
      };

      easy-kill = {
        enable = true;
        config = "(global-set-key [remap kill-ring-save] #'easy-kill)";
      };

      exec-path-from-shell = {
        enable = true;
        init = "(setq exec-path-from-shell-check-startup-files nil)";
        config = ''
          (when (memq window-system '(mac ns))
            (exec-path-from-shell-initialize))
        '';
      };

      move-text = {
        enable = true;
        config = ''
          (global-set-key [(meta shift up)] #'move-text-up)
          (global-set-key [(meta shift down)] #'move-text-down)
        '';
      };

      zop-to-char = {
        enable = true;
        bind = {
          "M-z" = "zop-up-to-char";
          "s-z" = "(lambda () (interactive) (zop-up-to-char -1))";
        };
      };

      hl-todo = {
        enable = true;
        config = ''
          (setq hl-todo-highlight-punctuation ":")
          (global-hl-todo-mode)
        '';
      };

      # Completion
      company = {
        enable = true;
        diminish = [ "company-mode" ];
        config = ''
          (setq company-idle-delay 0.2
                company-show-numbers t
                company-tooltip-limit 10
                company-minimum-prefix-length 2
                company-tooltip-align-annotations t
                company-global-modes '(not org-mode
                                           text-mode
                                           fundamental-mode
                                           ein:notebook-mode))
          (global-company-mode t)
        '';
      };

      hydra = {
        enable = true;
      };

      yasnippet = {
        enable = true;
        diminish = [ "yas-minor-mode" ];
        after = [ "hydra" ];
        config = ''
                    (setq yas-prompt-functions '(yas-ido-prompt
                                                 yas-completing-prompt))
                    (yas-reload-all)
                    (yas-global-mode)
                    (defun asm/yas-comment-start ()
                      "A properly spaced comment for yasnippet snips"
                      (require 's)
                      (s-trim comment-start))
                    (defhydra hydra-yas (:color blue :hint nil)
                      "
          [yasnippet]        _i_nsert        _n_ew        _v_isit snippet file        _r_eload all        e_x_pand        _?_ list snippets        "
                      ("i" yas-insert-snippet)
                      ("n" yas-new-snippet)
                      ("v" yas-visit-snippet-file)
                      ("r" yas-reload-all)
                      ("x" yas-expand)
                      ("?" yas-describe-tables)
                      ("q" nil "cancel" :color blue))
                    (global-set-key (kbd "C-c y") #'hydra-yas/body)
                    (advice-add 'company-complete-common :before
                                (lambda () (setq my-company-point (point))))
                    (advice-add 'company-complete-common :after
                                (lambda ()
                                  (when (equal my-company-point (point))
                                    (yas-expand))))
        '';
      };

      yasnippet-snippets = {
        enable = true;
        after = [ "yasnippet" ];
      };

      crux = {
        enable = true;
        demand = true;
        bind = {
          "C-c d" = "crux-duplicate-current-line-or-region";
          "M-o" = "crux-smart-open-line";
          "C-c n" = "crux-cleanup-buffer-or-region";
          "C-c f" = "crux-recentf-find-file";
          "C-M-z" = "crux-indent-defun";
          "C-c e" = "crux-eval-and-replace";
          "C-c w" = "crux-swap-windows";
          "C-c D" = "crux-delete-file-and-buffer";
          "C-c r" = "crux-rename-buffer-and-file";
          "C-c TAB" = "crux-indent-rigidly-and-copy-to-clipboard";
          "C-c I" = "crux-find-user-init-file";
          "s-r" = "crux-recentf-find-file";
          "s-j" = "crux-top-join-line";
          "C-^" = "crux-top-join-line";
          "s-k" = "crux-kill-whole-line";
          "C-<backspace>" = "crux-kill-line-backwards";
          "s-o" = "crux-smart-open-line-above";
        };
        config = ''
          (global-set-key [remap move-beginning-of-line] #'crux-move-beginning-of-line)
          (global-set-key [(shift return)] #'crux-smart-open-line)
          (global-set-key [(control shift return)] #'crux-smart-open-line-above)
          (global-set-key [remap kill-whole-line] #'crux-kill-whole-line)
        '';
      };

      which-key = {
        enable = true;
        diminish = [ "which-key-mode" ];
        config = ''
          (setq which-key-idle-delay 0.4
                which-key-sort-order #'which-key-prefix-then-key-order)
          (which-key-mode +1)
        '';
      };

      discover-my-major = {
        enable = true;
        bind = {
          "C-h M-m" = "discover-my-major";
          "C-h M-M" = "discover-my-mode";
        };
      };

      undo-tree = {
        enable = true;
        diminish = [ "undo-tree-mode" ];
        config = ''
          (setq undo-tree-history-directory-alist
                `((".*" . ,temporary-file-directory))
                undo-tree-auto-save-history t)
          (global-set-key (kbd "C-/") #'undo-tree-undo)
          (global-set-key (kbd "C-?") #'undo-tree-redo)
          (global-set-key (kbd "C-c u") #'undo-tree-visualize)
          (global-undo-tree-mode)
        '';
      };

      # Ivy/Counsel/Swiper
      orderless = {
        enable = true;
        init = ''
          (setq completion-styles '(orderless)
                read-file-name-completion-ignore-case t)
        '';
      };

      prescient = {
        enable = true;
        after = [ "ivy" ];
        config = ''
          (ivy-prescient-mode)
        '';
      };

      ivy-prescient = {
        enable = true;
        after = [ "prescient" "ivy" ];
        config = "(ivy-prescient-mode)";
      };

      ivy = {
        enable = true;
        diminish = [ "ivy-mode" ];
        demand = true;
        bind = { "C-c C-r" = "ivy-resume"; };
        config = ''
          (defun asm/ivy-sort-by-length (_name candidates)
            (cl-sort (copy-sequence candidates)
                     (lambda (f1 f2)
                       (< (length f1) (length f2)))))
          (setq ivy-count-format ""
                ivy-use-virtual-buffers t
                enable-recursive-minibuffers t
                ivy-initial-inputs-alist nil
                ivy-re-builders-alist '((t . ivy--regex-ignore-order))
                ivy-sort-matches-functions-alist '((t)
                                                   (counsel-find-file . asm/ivy-sort-by-length)
                                                   (projectile-completing-read . asm/ivy-sort-by-length))
                ivy-on-del-error-function #'ignore
                ivy-use-selectable-prompt t
                ivy-format-function 'ivy-format-function-arrow)
          (set-face-attribute 'ivy-current-match nil :foreground "#242832")
          (ivy-mode 1)
        '';
      };

      swiper = {
        enable = true;
        bind = {
          "C-s" = "swiper";
          "C-r" = "swiper";
          "C-S-s" = "isearch-forward";
          "C-S-r" = "isearch-backwards";
        };
      };

      counsel = {
        enable = true;
        demand = true;
        bind = {
          "M-x" = "counsel-M-x";
          "C-x C-f" = "counsel-find-file";
          "C-c i" = "counsel-imenu";
        };
        bindLocal = {
          minibuffer-local-map = {
            "C-r" = "counsel-minibuffer-history";
          };
          counsel-find-file-map = {
            "C-l" = "ivy-backward-delete-char";
          };
        };
        config = ''
          (defun asm/contextual-switch-buffer ()
            "Switch to projectile buffers if in a counsel project,
            otherwise do a normal `counsel-switch-buffer'."
            (interactive)
            (if (projectile-project-p)
                (counsel-projectile-switch-to-buffer)
              (counsel-switch-buffer)))
          (global-set-key (kbd "C-x b") #'asm/contextual-switch-buffer)
        '';
      };

      counsel-projectile = {
        enable = true;
        demand = true;
        after = [ "counsel" "projectile" ];
      };

      # Window management
      ace-window = {
        enable = true;
        config = ''
          (global-set-key (kbd "s-w") #'ace-window)
          (global-set-key [remap other-window] #'ace-window)
        '';
      };

      neotree = {
        enable = true;
        defer = true;
        bind = { "C-c t" = "neotree-toggle"; };
        config = ''
          (setq neo-smart-open t
                neo-dont-be-alone t)
          (add-hook 'neotree-mode-hook
                    (lambda ()
                      (setq-local mode-line-format nil)
                      (local-set-key (kbd "C-s") #'isearch-forward)
                      (local-set-key (kbd "C-r") #'isearch-backward)))
        '';
      };

      perspective = {
        enable = true;
        init = "(setq persp-suppress-no-prefix-key-warning t)";
        config = "(persp-mode)";
      };

      persp-projectile = {
        enable = true;
        after = [ "perspective" "projectile" ];
        demand = true;
        bind = { "C-c x" = "hydra-persp/body"; };
        config = ''
          (defhydra hydra-persp (:columns 4 :color blue)
            "Perspective"
            ("a" persp-add-buffer "Add Buffer")
            ("i" persp-import "Import")
            ("c" persp-kill "Close")
            ("n" persp-next "Next")
            ("p" persp-prev "Prev")
            ("k" persp-remove-buffer "Kill Buffer")
            ("r" persp-rename "Rename")
            ("A" persp-set-buffer "Set Buffer")
            ("s" persp-switch "Switch")
            ("C-x" persp-switch-last "Switch Last")
            ("b" persp-switch-to-buffer "Switch to Buffer")
            ("P" projectile-persp-switch-project "Switch Project")
            ("q" nil "Quit"))
        '';
      };

      zygospore = {
        enable = true;
        bind = { "C-x 1" = "zygospore-toggle-delete-other-windows"; };
      };

      volatile-highlights = {
        enable = true;
        diminish = [ "volatile-highlights-mode" ];
        config = ''
          (volatile-highlights-mode +1)
          (defadvice kill-region (before smart-cut activate compile)
            (interactive
             (if mark-active (list (region-beginning) (region-end))
               (list (line-beginning-position)
                     (line-beginning-position 2)))))
        '';
      };

      rainbow-delimiters = {
        enable = true;
      };

      whitespace = {
        enable = true;
        diminish = [ "whitespace-mode" ];
        hook = [
          "(prog-mode . whitespace-mode)"
          "(text-mode . whitespace-mode)"
          "(before-save . whitespace-cleanup)"
        ];
        config = ''
          (setq whitespace-line-column 100
                whitespace-style '(face tabs empty trailing))
        '';
      };

      smartparens = {
        enable = true;
        demand = true;
        diminish = [ "smartparens-mode" ];
        init = "(setq sp-highlight-pair-overlay nil)";
        bind = {
          "C-M-f" = "sp-forward-sexp";
          "C-M-b" = "sp-backward-sexp";
          "C-M-d" = "sp-down-sexp";
          "C-M-a" = "sp-backward-down-sexp";
          "C-S-d" = "sp-beginning-of-sexp";
          "C-S-a" = "sp-end-of-sexp";
          "C-M-e" = "sp-up-sexp";
          "C-M-u" = "sp-backward-up-sexp";
          "C-M-n" = "sp-next-sexp";
          "C-M-p" = "sp-previous-sexp";
          "C-M-k" = "sp-kill-sexp";
          "C-M-w" = "sp-copy-sexp";
          "M-s" = "sp-splice-sexp";
          "M-r" = "sp-splice-sexp-killing-around";
          "C-)" = "sp-forward-slurp-sexp";
          "C-}" = "sp-forward-barf-sexp";
          "C-(" = "sp-backward-slurp-sexp";
          "C-{" = "sp-backward-barf-sexp";
          "M-S" = "sp-split-sexp";
          "M-J" = "sp-join-sexp";
          "C-M-t" = "sp-transpose-sexp";
        };
        config = ''
          (require 'smartparens-config)
          (sp-local-pair 'emacs-lisp-mode "`" nil :when '(sp-in-string-p))
          (sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)
          (sp-pair "'" nil :unless '(sp-point-after-word-p))
          (smartparens-global-mode t)
        '';
      };

      # LSP
      lsp-mode = {
        enable = true;
        command = [ "lsp" "lsp-deferred" ];
        init = ''
          (setq lsp-keymap-prefix "C-c l"
                lsp-ruff-lsp-ruff-path (expand-file-name "~/.nix-profile/bin/ruff-lsp")
                lsp-ruff-ruff-args '("--preview")
                lsp-terraform-server (expand-file-name "~/.nix-profile/bin/terraform-lsp")
                lsp-disabled-clients '(tfls semgrep-ls)
                lsp-nix-nil-server-path (expand-file-name "~/.nix-profile/bin/nil")
                lsp-terraform-ls-prefill-required-fields t)
        '';
        bindLocal.lsp-mode-map = {
          "C-S-SPC" = "nil";
        };
        hook = [
          "(lsp-mode . lsp-enable-which-key-integration)"
          "(typescript-mode . lsp-deferred)"
          "(js-mode . lsp-deferred)"
          "(terraform-mode . lsp-deferred)"
          "(nix-mode . lsp-deferred)"
          "(rust-mode . lsp-deferred)"
        ];
        config = ''
          (setq lsp-rust-analyzer-cargo-watch-command "clippy"
                lsp-eldoc-render-all t
                lsp-idle-delay 0.6)
          ;; HACK(asm,2025-10-17): Without these eager loads, `lsp-mode` seems to bug out when starting up.
          (require 'lsp-lens)
          (require 'lsp-modeline)
          (require 'lsp-headerline)
        '';
      };

      lsp-pyright = {
        enable = true;
        after = [ "lsp-mode" ];
        hook = [
          ''(python-mode . (lambda ()
                                    (require 'lsp-pyright)
                                    (lsp-deferred)))''
        ];
      };

      lsp-ivy = {
        enable = true;
        after = [ "lsp-mode" ];
        command = [ "lsp-ivy-workspace-symbol" ];
      };

      lsp-ui = {
        enable = true;
        after = [ "lsp-mode" ];
        command = [ "lsp-ui-mode" ];
        config = ''
          (setq lsp-ui-peek-always-show t
                lsp-ui-sideline-show-hover t
                lsp-ui-doc-enable nil)
        '';
      };

      # Language modes
      ruby-mode = {
        enable = true;
        hook = [ "(ruby-mode . subword-mode)" ];
        config = "(setq ruby-insert-encoding-magic-comment nil)";
      };

      markdown-mode = {
        enable = true;
        mode = [
          ''("\\.md\\'" . gfm-mode)''
          ''("\\.markdown\\'" . gfm-mode)''
        ];
        config = ''
          (setq markdown-fontify-code-blocks-natively t
                markdown-disable-tooltip-prompt t)
        '';
      };

      python = {
        enable = true;
        mode = [ ''("\\.py\\'" . python-mode)'' ];
        hook = [
          "(python-mode . asm/python-mode-hook)"
        ];
        bindLocal.python-mode-map = {
          "C-c C-j" = "nil";
        };
        config = ''
          (setq-default python-fill-docstring-style 'django)
          (defun asm/python-mode-hook ()
            ;; use flat imenu
            (when (fboundp #'python-imenu-create-flat-index)
              (setq-local imenu-create-index-function
                          #'python-imenu-create-flat-index))
            (subword-mode +1)
            (setq indent-tabs-mode nil))
        '';
      };

      blacken = {
        enable = true;
        hook = [ "(python-mode . blacken-mode)" ];
        bindLocal.python-mode-map = {
          "C-c C-b" = "blacken-buffer";
        };
        config = "(setq blacken-executable \"~/.local/bin/black\")";
      };

      py-isort = {
        enable = true;
        config = ''
          (setq py-isort-options '("-l 100" "--multi-line=3" "--trailing-comma"))
          (defun asm/toggle-isort ()
            "Toggle isort before-save-hook."
            (interactive)
            (if (member 'py-isort-before-save before-save-hook)
                (progn
                  (remove-hook 'before-save-hook 'py-isort-before-save)
                  (message "isort disabled"))
              (progn
                (add-hook 'before-save-hook 'py-isort-before-save)
                (message "isort enabled"))))
        '';
      };

      # HACK(asm,2025-10-17): Pinning this specific version of polymode for ein compatibility. Newer
      # versions remove the `pm--visible-buffer-name` function which breaks ein internals.
      polymode = {
        enable = true;
        package = epkgs: epkgs.trivialBuild {
          pname = "polymode";
          version = "4b7c240";
          src = pkgs.fetchFromGitHub {
            owner = "polymode";
            repo = "polymode";
            rev = "4b7c240421302b099a9a5c81e738fde5fdbddef5";
            sha256 = "sha256-0a2K9N1qotjXIef7cPzCdbxSsLomTvVZdp5hIK3v8Q8=";
          };
          packageRequires = [ epkgs.emacs ];
        };
      };

      ein = {
        enable = true;
        after = [ "polymode" ];
        command = [ "ein:login" ];
        init = ''
          (setq ein:complete-on-dot -1
                ein:completion-backend 'ein:use-none-backend
                ein:query-timeout 1000
                ein:worksheet-enable-undo 'full
                ein:notebook-modes '(ein:notebook-python-mode ein:notebook-plain-mode)
                ein:urls '("http://localhost:8888"))
        '';
        config = ''
          ;; HACK(asm,2025-10-17): For some reason `use-package` doesn't seem to eagerly autoload
          (require 'ein-autoloads)

          (cond
           ((eq system-type 'darwin)
            (setq-default ein:console-args
                          '("--gui=osx" "--matplotlib=osx" "--colors=Linux")))
           ((eq system-type 'gnu/linux)
            (setq-default ein:console-args
                          '("--gui=gtk3" "--matplotlib=gtk3" "--colors=Linux"))))
          (setq-default request--curl-cookie-jar (concat user-emacs-directory
                                                         "request/curl-cookie-jar"))
          (add-hook 'ein:notebook-mode-hook
                    (lambda ()
                      (visual-line-mode +1)
                      (whitespace-mode -1)
                      (company-mode nil)
                      (undo-tree-mode t)
                      (bind-key "C-/" 'undo-tree-undo)
                      (bind-key "C-a" 'crux-move-beginning-of-line)))
        '';
      };

      dockerfile-mode.enable = true;

      elixir-mode = {
        enable = true;
      };

      reformatter = {
        enable = true;
        config = ''
          (reformatter-define +elixir-format
            :program "mix"
            :args '("format" "-"))
          (defun +set-default-directory-to-mix-project-root (original-fun &rest args)
            (if-let* ((mix-project-root (and buffer-file-name
                                             (locate-dominating-file buffer-file-name
                                                                     ".formatter.exs"))))
                (let ((default-directory mix-project-root))
                  (apply original-fun args))
              (apply original-fun args)))
          (advice-add '+elixir-format-region :around #'+set-default-directory-to-mix-project-root)
          (add-hook 'elixir-mode-hook #'+elixir-format-on-save-mode)
        '';
      };

      go-mode = {
        enable = true;
        defer = true;
        hook = [ "(go-mode . electric-pair-mode)" ];
        config = ''
          (defun asm/go-mode-hook ()
            (add-hook 'before-save-hook 'gofmt-before-save)
            (add-to-list 'exec-path "~/proj/go/bin")
            (if (not (string-match "go" compile-command))
                (set (make-local-variable 'compile-command)
                     "go build -v && go vet"))
            (local-set-key (kbd "C-c C-c") 'compile)
            (setenv "GOPATH" (expand-file-name "~/proj/go")))
          (add-hook 'go-mode-hook 'asm/go-mode-hook)
        '';
      };

      rust-mode = {
        enable = true;
        defer = true;
        mode = [ ''"\\.rs$"'' ];
        hook = [ "(rust-mode . electric-pair-mode)" ];
        config = "(setq rust-format-on-save t)";
      };

      json-mode = {
        enable = true;
        defer = true;
        mode = [ ''"\\.json$"'' ];
        bindLocal.json-mode-map = {
          "C-c C-b" = "json-pretty-print-buffer";
          "C-c C-j" = "counsel-jq";
        };
        init = "(setq js-indent-level 2)";
      };

      yaml-mode = {
        enable = true;
        defer = true;
        mode = [
          ''("\\.yaml$" . yaml-mode)''
          ''("\\.yml$" . yaml-mode)''
        ];
      };

      toml-mode = {
        enable = true;
        defer = true;
        mode = [
          ''("\\.toml$" . toml-mode)''
          ''("Pipfile$" . toml-mode)''
        ];
      };

      sdlang-mode = {
        enable = true;
        defer = true;
        mode = [
          ''("\\.kdl$" . sdlang-mode)''
          ''("\\.sdl$" . sdlang-mode)''
        ];
      };

      nix-mode = {
        enable = true;
        defer = true;
        mode = [ ''"\\.nix\\'"'' ];
        hook = [ "(nix-mode . subword-mode)" ];
      };

      nixpkgs-fmt = {
        enable = true;
        defer = true;
        hook = [ "(nix-mode . nixpkgs-fmt-on-save-mode)" ];
        bindLocal.nix-mode-map = {
          "C-c C-f" = "nixpkgs-fmt";
        };
        config = "(setq nixpkgs-fmt-command (expand-file-name \"~/.nix-profile/bin/nixpkgs-fmt\"))";
      };

      web-mode = {
        enable = true;
        defer = true;
        mode = [ ''"\\.html$"'' ];
        hook = [ "(web-mode . (lambda () (web-mode-set-engine \"django\")))" ];
        config = ''
          (setq web-mode-markup-indent-offset 2
                web-mode-code-indent-offset 2
                web-mode-css-indent-offset 2
                web-mode-sql-indent-offset 2
                web-mode-enable-auto-indentation nil)
        '';
      };

      js2-mode = {
        enable = true;
        defer = true;
        mode = [ ''"\\.js$"'' ];
        config = ''
          (setq js2-basic-indent 2
                js2-basic-offset 2
                js2-auto-indent-p t
                js2-cleanup-whitespace t
                js2-enter-indents-newline t
                js2-indent-on-enter-key t
                js2-global-externs (list "window" "setTimeout" "clearTimeout" "setInterval"
                                         "clearInterval" "location" "console" "JSON"
                                         "jQuery" "$"))
        '';
      };

      typescript-mode = {
        enable = true;
        mode = [
          ''("\\.ts\\'" . typescript-mode)''
          ''("\\.tsx\\'" . typescript-mode)''
        ];
        config = "(setq typescript-indent-level 2)";
      };

      terraform-mode = {
        enable = true;
        mode = [ ''"\\.tf$"'' ];
        hook = [
          ''
            (terraform-mode . (lambda ()
                                (subword-mode +1)
                                (terraform-format-on-save-mode t)
                                (set (make-local-variable 'company-backends)
                                     '(company-terraform))))
          ''
        ];
      };

      just-mode = {
        enable = true;
      };

      jinja2-mode = {
        enable = true;
        mode = [
          ''(".*\\.jinja" . jinja2-mode)''
          ''(".*\\.jinja2" . jinja2-mode)''
        ];
      };

      clojure-mode = {
        enable = true;
      };

      cider = {
        enable = true;
      };

      vterm = {
        enable = true;
        command = [ "vterm" ];
        config = ''
          (setq vterm-kill-buffer-on-exit t
                vterm-max-scrollback 10000)
        '';
      };

      chatgpt-shell = {
        enable = true;
        config = ''
          (setq chatgpt-shell-openai-key
                (lambda ()
                  (auth-source-pick-first-password :machine "api.openai.com")))
        '';
      };
    };

    postlude = ''
      ;; Custom utility functions
      (defun asm/open-init-file ()
        (interactive)
        (find-file (expand-file-name "~/proj/emacs.d/init.el")))

      (defun asm/empty-buffer ()
        (interactive)
        (command-execute 'asm/split-window-horizontally)
        (let ((buf (generate-new-buffer "untitled")))
          (switch-to-buffer buf)
          (funcall initial-major-mode)
          (setq buffer-offer-save nil)
          buf))

      (defun asm/org-open-file ()
        (interactive)
        (let ((file-to-open
               (read-file-name
                "Open org file: "
                (expand-file-name "~/org/"))))
          (find-file file-to-open)))

      (defun asm/yank-filename ()
        (interactive)
        (let ((filename (if (equal major-mode 'dired-mode)
                             default-directory
                           (replace-regexp-in-string ".*/proj/" "" (buffer-file-name)))))
          (when filename
            (with-temp-buffer
              (insert filename)
              (clipboard-kill-region (point-min) (point-max)))
            (message filename))))

      (defun asm/toggle-maximize-buffer ()
        "Maximize buffer"
        (interactive)
        (if (= 1 (length (window-list)))
            (jump-to-register '_)
          (progn
            (window-configuration-to-register '_)
            (delete-other-windows))))

      (defun asm/point-in-string-p (pt)
        "Returns t if PT is in a string"
        (eq 'string (syntax-ppss-context (syntax-ppss pt))))

      (defun asm/beginning-of-string ()
        "Moves to the beginning of a syntactic string"
        (interactive)
        (unless (asm/point-in-string-p (point))
          (error "You must be in a string for this command to work"))
        (while (asm/point-in-string-p (point))
          (forward-char -1))
        (point))

      (defun asm/swap-quotes ()
        "Swaps the quote symbols around a string"
        (interactive)
        (save-excursion
          (let ((bos (save-excursion
                       (asm/beginning-of-string)))
                (eos (save-excursion
                       (asm/beginning-of-string)
                       (forward-sexp)
                       (point)))
                (replacement-char ?\'))
            (goto-char bos)
            (when (eq (following-char) ?\')
                (setq replacement-char ?\"))
            (delete-char 1)
            (insert replacement-char)
            (goto-char eos)
            (delete-char -1)
            (insert replacement-char))))

      ;; Main hydra menu
      (global-set-key
       (kbd "C-z")
       (defhydra ctrl-z-hydra (:color blue :columns 4)
         "Shorties"
         ("a"   chatgpt-shell-prompt-compose     "chatgpt-shell region")
         ("b"   asm/empty-buffer                 "empty buffer")
         ("e"   flycheck-list-errors             "list errors")
         ("f"   asm/yank-filename                "yank filename")
         ("i"   asm/open-init-file               "open init")
         ("l"   counsel-bookmark                 "bookmarks")
         ("n"   ein:login                        "EIN")
         ("o"   asm/org-open-file                "find org file")
         ("p"   projectile-persp-switch-project  "open project")
         ("r"   anzu-replace-at-cursor-thing     "replace at point")
         ("s"   counsel-rg                       "ripgrep")
         ("w"   ace-window                       "ace window")
         ("C-s" deadgrep                         "deadgrep")
         ("q"   asm/swap-quotes                  "toggle quotes around string")
         ("z"   asm/toggle-maximize-buffer       "zoom")))
    '';
  };
}
