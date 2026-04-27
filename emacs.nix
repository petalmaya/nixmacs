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
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;

    extraPackages = epkgs: with epkgs; [
      # Evil mode (Vim bindings)
      evil
      evil-collection
      
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
      
      # Key discovery (like Spacemacs)
      which-key
      general
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
      treemacs-evil
      treemacs-projectile
      treemacs-magit
      lsp-treemacs

      # Visualizers & Fun
      fireplace

      # Terminal
      vterm
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
              centaur-tabs-show-navigation-buttons t)
        (centaur-tabs-headline-match)
        :bind
        ("C-<prior>" . centaur-tabs-backward)
        ("C-<next>" . centaur-tabs-forward))

      ;; Dashboard
      (use-package dashboard
        :demand t
        :config
        (dashboard-setup-startup-hook)
        (setq dashboard-center-content t)
        (setq dashboard-banner-logo-title " Helllooooo Alice!")
        (setq dashboard-startup-banner "/home/alice/nixmacs/assets/logo.png")
        (setq dashboard-items '((recents  . 5)
                                (projects . 5)))
        ;; Ensure dashboard is the initial buffer
        (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*"))))

      ;; --- Evil Mode Unholy ---
      (use-package evil
        :demand t
        :init
        (setq evil-want-integration t)
        (setq evil-want-keybinding nil)
        (setq evil-want-C-u-scroll t)
        (setq evil-want-C-i-jump t)
        :config
        (evil-mode 1))

      (use-package evil-collection
        :after evil
        :config
        (evil-collection-init))

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

      (use-package treemacs-evil
        :after (treemacs evil))

      (use-package treemacs-projectile
        :after (treemacs projectile))

      (use-package treemacs-magit
        :after (treemacs magit))

      (use-package lsp-treemacs
        :after (treemacs lsp-mode))

      ;; --- Keybindings (General.el) ---
      (require 'general)
      (general-evil-setup t)
      
      (general-create-definer my-leader-def
        :states '(normal visual insert emacs)
        :keymaps 'override
        :prefix "SPC"
        :global-prefix "C-SPC")

      ;; "SPC" bindings
      (my-leader-def
        "SPC" '(counsel-M-x :which-key "M-x")
        
        ;; Files
        "f"   '(:ignore t :which-key "files")
        "ff"  '(counsel-find-file :which-key "find file")
        "fs"  '(save-buffer :which-key "save file")
        "fr"  '(counsel-recentf :which-key "recent files")
        
        ;; Buffers
        "b"   '(:ignore t :which-key "buffers")
        "bb"  '(ivy-switch-buffer :which-key "switch buffer")
        "bn"  '(centaur-tabs-forward :which-key "next tab")
        "bp"  '(centaur-tabs-backward :which-key "prev tab")
        "bd"  '(kill-current-buffer :which-key "kill buffer")
        
        ;; Windows
        "w"   '(:ignore t :which-key "windows")
        "wl"  '(evil-window-right :which-key "right")
        "wh"  '(evil-window-left :which-key "left")
        "wj"  '(evil-window-down :which-key "down")
        "wk"  '(evil-window-up :which-key "up")
        "wv"  '(evil-window-vsplit :which-key "vsplit")
        "ws"  '(evil-window-split :which-key "split")
        "wd"  '(evil-window-delete :which-key "delete")
        
        ;; Projects
        "p"   '(:ignore t :which-key "projects")
        "pf"  '(projectile-find-file :which-key "find file in project")
        "pp"  '(projectile-switch-project :which-key "switch project")
        
        ;; Git
        "g"   '(:ignore t :which-key "git")
        "gs"  '(magit-status :which-key "magit status")

        ;; Trees / Explorer
        "e"   '(:ignore t :which-key "explorer")
        "ee"  '(treemacs :which-key "toggle treemacs")
        "ef"  '(treemacs-find-file :which-key "find current file")
        "ep"  '(treemacs-projectile :which-key "projectile tree")
        "es"  '(lsp-treemacs-symbols :which-key "lsp symbols")
        "ei"  '(lsp-treemacs-implementations :which-key "lsp implementations")
        "er"  '(lsp-treemacs-references :which-key "lsp references")

        ;; Terminal
        "t"   '(:ignore t :which-key "terminal")
        "tt"  '(vterm :which-key "vterm")
      )

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

      ;; SPC m v to watch video
      (my-leader-def
        "m"  '(:ignore t :which-key "media")
        "mv" '(nixmacs-watch-video :which-key "watch video (mpv)"))

      ;; --- Visualizers & Fun ---
      (use-package fireplace
        :commands fireplace)

      ;; --- Keybindings for visualizers ---
      (my-leader-def
        "a"   '(:ignore t :which-key "apps/fun")
        "af"  '(fireplace :which-key "cozy fireplace"))

      ;; --- Vterm ---
      (use-package vterm
        :commands vterm
        :config
        (setq vterm-max-scrollback 5000))
    '';
  };
}
