{ emacs-overlay }:

{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    emacs-overlay.overlay
  ];

  home.packages = with pkgs; [
    clang-tools # C/C++ LSP (clangd)
    pyright     # Python LSP
    typescript-language-server # JS/TS LSP
    nixd        # Nix LSP
    mpv         # Media player backend for EMMS
    ffmpeg      # Metadata tools
    cava        # Audio visualizer backend
    sqlite      # Required by org-roam
    graphviz    # Optional: for org-roam graph visualizations
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;

    extraPackages = epkgs: with epkgs; [
      # Modal editing
      xah-fly-keys
      
      # UI & Theming
      doom-themes
      doom-modeline
      all-the-icons # Note: run 'M-x all-the-icons-install-fonts' once in Emacs
      centaur-tabs
      dashboard
      
      # Completion & Navigation (Ivy stack)
      ivy
      counsel
      swiper
      ivy-posframe
      
      # Key discovery
      which-key
      use-package # Added for lazy loading
      
      # Project management & Git
      projectile
      magit
      
      # Syntax, LSP, and Language Support
      flycheck
      lsp-mode
      lsp-ui
      company
      treesit-grammars.with-all-grammars
      haskell-mode
      lsp-haskell
      nix-mode
      js2-mode
      typescript-mode

      # Matrix client
      ement

      # Multimedia
      emms

      # Tree Explorer
      treemacs
      treemacs-projectile
      treemacs-magit
      lsp-treemacs

      # Visualizers & Fun
      fireplace

      # Terminal
      vterm

      # Org-roam (knowledge graph / Zettelkasten)
      org-roam
      org-roam-ui
      websocket   # org-roam-ui dependency
    ];

    extraConfig = ''
      ;; --- Config ---

      ;; Startup Performance
      (setq gc-cons-threshold (* 50 1024 1024)) ; 50mb during startup
      (add-hook 'emacs-startup-hook
                (lambda ()
                  (setq gc-cons-threshold (* 2 1024 1024)) ; 2mb after startup
                  (message "Emacs loaded in %s" (emacs-init-time))))

      ;; --- Theme & UI early load ---
      (load-theme 'doom-peacock t)

      ;; --- Basic UI ---
      (setq inhibit-startup-message t)
      (scroll-bar-mode -1)        ; Disable visible scrollbar
      (tool-bar-mode -1)          ; Disable the toolbar
      (tooltip-mode -1)           ; Disable tooltips
      (set-fringe-mode 10)        ; Give some breathing room
      (menu-bar-mode -1)          ; Disable the menu bar

      ;; Transparency
      (set-frame-parameter nil 'alpha-background 90)
      (add-to-list 'default-frame-alist '(alpha-background . 90))

      ;; Line numbers
      (setq display-line-numbers-type 'relative)
      (global-display-line-numbers-mode t)


      ;; Modeline
      (doom-modeline-mode 1)
      (setq doom-modeline-height 35)

      ;; --- Centaur Tabs ---
      (use-package centaur-tabs
        :demand t
        :config
        (centaur-tabs-mode 1)
        (setq centaur-tabs-style "bar"
              centaur-tabs-height 32
              centaur-tabs-set-icons t
              centaur-tabs-set-bar 'left
              centaur-tabs-set-modified-marker t
              centaur-tabs-show-navigation-buttons t
              centaur-tabs-gray-out-icons 'buffer
              centaur-tabs-cycle-scope 'tabs) ; cycle within current group only
        (centaur-tabs-headline-match)
        (centaur-tabs-group-by-projectile-project) ; group tabs by project
        :bind
        ;; Classic Ctrl+PageUp/Down
        ("C-<prior>" . centaur-tabs-backward)
        ("C-<next>"  . centaur-tabs-forward))


      ;; Dashboard
      (use-package dashboard
        :demand t
        :init
        ;; Must be in :init so the hook is registered before Emacs
        ;; processes the startup buffer (too late if done in :config).
        (dashboard-setup-startup-hook)
        :config
        (setq dashboard-center-content t)
        (setq dashboard-banner-logo-title " Helllooooo Alice!")
        (setq dashboard-startup-banner "/home/alice/nixmacs/assets/logo.png")
        (setq dashboard-set-heading-icons t)
        (setq dashboard-set-file-icons t)
        (setq dashboard-items '((recents  . 5)
                                (projects . 5)))
        ;; Jump to a fully-rendered dashboard as the initial buffer.
        (setq initial-buffer-choice
              (lambda ()
                (get-buffer-create "*dashboard*"))))

      ;; --- Xah Fly Keys (Modal editing) ---
      (use-package xah-fly-keys
        :demand t
        :config
        (xah-fly-keys-set-layout "qwerty")
        (xah-fly-keys 1)
        ;; Use Escape to enter command mode
        (define-key xah-fly-key-map (kbd "<escape>") 'xah-fly-command-mode-activate))


      ;; --- Magit ---
      (use-package magit
        :commands magit-status
        :bind ("C-x g" . magit-status))

      ;; --- Which-Key ---
      (use-package which-key
        :demand t
        :init (which-key-mode)
        :config
        (setq which-key-idle-delay 0.3))

      ;; --- Ivy & Counsel (Navigation & Search) ---
      (use-package ivy
        :diminish
        :bind (("C-s" . swiper)
               :map ivy-minibuffer-map
               ("C-l" . ivy-done)
               ("C-j" . ivy-next-line)
               ("C-k" . ivy-previous-line)
               :map ivy-switch-buffer-map
               ("C-k" . ivy-previous-line)
               ("C-l" . ivy-done)
               ("C-d" . ivy-switch-buffer-kill)
               :map ivy-reverse-i-search-map
               ("C-k" . ivy-previous-line)
               ("C-d" . ivy-reverse-i-search-kill))
        :config
        (ivy-mode 1))

      (use-package counsel
        :bind (("M-x" . counsel-M-x)
               ("C-x C-f" . counsel-find-file)
               :map minibuffer-local-map
               ("C-r" . 'counsel-minibuffer-history))
        :config
        (setq ivy-initial-inputs-alist nil) ; No initial ^ in counsel
        (counsel-mode 1))

      (use-package swiper)

      ;; --- Ivy-Posframe (Centered Whoom) ---
      (use-package ivy-posframe
        :after ivy
        :config
        (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
        (ivy-posframe-mode 1))

      ;; --- Projectile ---
      (use-package projectile
        :diminish projectile-mode
        :config (projectile-mode)
        :bind-keymap
        ("C-c p" . projectile-command-map)
        :init
        (when (file-directory-p "~/projects")
          (setq projectile-project-search-path '("~/projects")))
        (setq projectile-switch-project-action #'projectile-dired))

      ;; --- Treemacs ---
      (use-package treemacs
        :defer t
        :init
        (with-eval-after-load 'winum
          (define-key winum-keymap (kbd "M-0") 'treemacs-select-window))
        :config
        (setq treemacs-no-png-images t) ;; use all-the-icons
        (treemacs-follow-mode t)
        (treemacs-filewatch-mode t)
        (treemacs-fringe-indicator-mode 'always)
        (setq treemacs-width 35)
        (setq treemacs-is-never-other-window t)
        (setq treemacs-silent-refresh t)
        (setq treemacs-silent-filewatch t)
        (when treemacs-python-executable
          (treemacs-git-commit-diff-mode t)))

      (use-package treemacs-projectile
        :after (treemacs projectile))

      (use-package treemacs-magit
        :after (treemacs magit))

      (use-package lsp-treemacs
        :after (treemacs lsp-mode))

      ;; --- Org-Roam ---
      (use-package org-roam
        :demand t
        :init
        (setq org-roam-v2-ack t) ; suppress v2 migration warning
        :custom
        (org-roam-directory (file-truename "~/org/roam"))
        (org-roam-completion-everywhere t) ; complete node links anywhere in org files
        (org-roam-dailies-directory "daily/") ; subdir inside org-roam-directory
        (org-roam-capture-templates
         '(;; Default note
           ("d" "default" plain
            "%?"
            :target (file+head "%<%Y%m%d%H%M%S>-''${slug}.org"
                               "#+title: ''${title}\n#+date: %U\n#+filetags: \n\n")
            :unnarrowed t)
           ;; Fleeting / quick thought
           ("f" "fleeting" plain
            "* %?\n\n%i"
            :target (file+head "fleeting/%<%Y%m%d%H%M%S>-''${slug}.org"
                               "#+title: ''${title}\n#+date: %U\n#+filetags: :fleeting:\n\n")
            :unnarrowed t)
           ;; Literature note (for reading notes)
           ("l" "literature" plain
            "* Source\n- Author: %^{Author}\n- URL: %^{URL}\n\n* Notes\n%?\n\n* Summary\n"
            :target (file+head "literature/%<%Y%m%d%H%M%S>-''${slug}.org"
                               "#+title: ''${title}\n#+date: %U\n#+filetags: :literature:\n\n")
            :unnarrowed t)
           ;; Permanent / evergreen note
           ("p" "permanent" plain
            "%?"
            :target (file+head "permanent/%<%Y%m%d%H%M%S>-''${slug}.org"
                               "#+title: ''${title}\n#+date: %U\n#+filetags: :permanent:\n\n")
            :unnarrowed t)))
        (org-roam-dailies-capture-templates
         '(("d" "default" entry
            "* %<%H:%M> %?"
            :target (file+head "%<%Y-%m-%d>.org"
                               "#+title: %<%Y-%m-%d>\n#+filetags: :daily:\n\n"))))
        :config
        ;; Create the roam directory if it doesn't exist yet
        (make-directory org-roam-directory t)
        (org-roam-db-autosync-mode))

      ;; --- Org-Roam UI (Interactive graph in browser) ---
      (use-package org-roam-ui
        :after org-roam
        :config
        (setq org-roam-ui-sync-theme t       ; sync Emacs theme to the graph UI
              org-roam-ui-follow t            ; graph follows current node
              org-roam-ui-update-on-save t    ; refresh graph on save
              org-roam-ui-open-on-start nil)) ; don't auto-open browser on startup

      ;; --- Keybindings (Xah Fly Keys command mode) ---
      ;; Press Escape to enter command mode, then use SPC as leader.

      (with-eval-after-load 'xah-fly-keys
        (define-key xah-fly-command-map (kbd "SPC SPC") 'counsel-M-x)

        ;; Files
        (define-key xah-fly-command-map (kbd "SPC f f") 'counsel-find-file)
        (define-key xah-fly-command-map (kbd "SPC f s") 'save-buffer)
        (define-key xah-fly-command-map (kbd "SPC f r") 'counsel-recentf)

        ;; Buffers / Tabs
        (define-key xah-fly-command-map (kbd "SPC b b") 'ivy-switch-buffer)
        (define-key xah-fly-command-map (kbd "SPC b n") 'centaur-tabs-forward)
        (define-key xah-fly-command-map (kbd "SPC b p") 'centaur-tabs-backward)
        (define-key xah-fly-command-map (kbd "SPC b d") 'kill-current-buffer)
        (define-key xah-fly-command-map (kbd "SPC b N") 'centaur-tabs-forward-group)
        (define-key xah-fly-command-map (kbd "SPC b P") 'centaur-tabs-backward-group)
        (define-key xah-fly-command-map (kbd "SPC b >") 'centaur-tabs-move-current-tab-to-right)
        (define-key xah-fly-command-map (kbd "SPC b <") 'centaur-tabs-move-current-tab-to-left)
        (define-key xah-fly-command-map (kbd "SPC b g") 'centaur-tabs-switch-group)

        ;; Windows
        (define-key xah-fly-command-map (kbd "SPC w l") 'windmove-right)
        (define-key xah-fly-command-map (kbd "SPC w h") 'windmove-left)
        (define-key xah-fly-command-map (kbd "SPC w j") 'windmove-down)
        (define-key xah-fly-command-map (kbd "SPC w k") 'windmove-up)
        (define-key xah-fly-command-map (kbd "SPC w v") 'split-window-right)
        (define-key xah-fly-command-map (kbd "SPC w s") 'split-window-below)
        (define-key xah-fly-command-map (kbd "SPC w d") 'delete-window)

        ;; Projects
        (define-key xah-fly-command-map (kbd "SPC p f") 'projectile-find-file)
        (define-key xah-fly-command-map (kbd "SPC p p") 'projectile-switch-project)

        ;; Git
        (define-key xah-fly-command-map (kbd "SPC g s") 'magit-status)

        ;; Explorer
        (define-key xah-fly-command-map (kbd "SPC e e") 'treemacs)
        (define-key xah-fly-command-map (kbd "SPC e f") 'treemacs-find-file)
        (define-key xah-fly-command-map (kbd "SPC e p") 'treemacs-projectile)
        (define-key xah-fly-command-map (kbd "SPC e s") 'lsp-treemacs-symbols)
        (define-key xah-fly-command-map (kbd "SPC e i") 'lsp-treemacs-implementations)
        (define-key xah-fly-command-map (kbd "SPC e r") 'lsp-treemacs-references)

        ;; Terminal
        (define-key xah-fly-command-map (kbd "SPC t t") 'vterm)

        ;; Notes (Org-Roam)
        (define-key xah-fly-command-map (kbd "SPC n f") 'org-roam-node-find)
        (define-key xah-fly-command-map (kbd "SPC n i") 'org-roam-node-insert)
        (define-key xah-fly-command-map (kbd "SPC n c") 'org-roam-capture)
        (define-key xah-fly-command-map (kbd "SPC n b") 'org-roam-buffer-toggle)
        (define-key xah-fly-command-map (kbd "SPC n U") 'org-roam-ui-open)
        (define-key xah-fly-command-map (kbd "SPC n d t") 'org-roam-dailies-goto-today)
        (define-key xah-fly-command-map (kbd "SPC n d y") 'org-roam-dailies-goto-yesterday)
        (define-key xah-fly-command-map (kbd "SPC n d d") 'org-roam-dailies-goto-date)
        (define-key xah-fly-command-map (kbd "SPC n d c") 'org-roam-dailies-capture-today)
        (define-key xah-fly-command-map (kbd "SPC n s") 'org-roam-db-sync)

        ;; Media
        (define-key xah-fly-command-map (kbd "SPC m v") 'nixmacs-watch-video)

        ;; Apps / Fun
        (define-key xah-fly-command-map (kbd "SPC a f") 'fireplace)

        ;; Which-key hints
        (which-key-add-key-based-replacements
          "SPC f" "files"
          "SPC b" "buffers/tabs"
          "SPC w" "windows"
          "SPC p" "projects"
          "SPC g" "git"
          "SPC e" "explorer"
          "SPC t" "terminal"
          "SPC n" "notes"
          "SPC n d" "dailies"
          "SPC m" "media"
          "SPC a" "apps/fun"))

      ;; --- LSP Mode ---
      (use-package lsp-mode
        :commands (lsp lsp-deferred)
        :init
        (setq lsp-keymap-prefix "C-c l")
        :config
        (lsp-enable-which-key-integration t))

      (use-package lsp-ui
        :commands lsp-ui-mode)

      (use-package company
        :config
        (setq company-idle-delay 0.0)
        (setq company-minimum-prefix-length 1)
        (global-company-mode t))

      ;; --- Language Support ---
      (use-package haskell-mode
        :mode "\\.hs\\'"
        :hook (haskell-mode . lsp-deferred))

      (use-package lsp-haskell
        :after (lsp-mode haskell-mode))

      (use-package nix-mode
        :mode "\\.nix\\'"
        :hook (nix-mode . lsp-deferred))

      (use-package js2-mode
        :mode "\\.js\\'"
        :hook (js2-mode . lsp-deferred))

      (use-package typescript-mode
        :mode "\\.ts\\'"
        :hook (typescript-mode . lsp-deferred))

      (add-hook 'c-mode-hook 'lsp-deferred)
      (add-hook 'c++-mode-hook 'lsp-deferred)
      (add-hook 'python-mode-hook 'lsp-deferred)

      ;; --- Ement.el (Matrix Client) ---
      (use-package ement
        :commands ement-connect)

      ;; --- EMMS (Emacs Multimedia System) ---
      (use-package emms
        :commands (emms emms-play-file)
        :config
        (require 'emms-setup)
        (emms-all)
        (setq emms-player-list '(emms-player-mpv))
        (setq emms-info-functions '(emms-info-native)))

      ;; --- Media helpers (External Window) ---
      (defun nixmacs-watch-video (file)
        "Watch a video file in mpv (external window)."
        (interactive "fVideo file: ")
        (start-process "mpv" nil "mpv" file))


      ;; --- Visualizers & Fun ---
      (use-package fireplace
        :commands fireplace)


      ;; --- Vterm ---
      (use-package vterm
        :commands vterm
        :config
        (setq vterm-max-scrollback 5000))
    '';
  };
}
