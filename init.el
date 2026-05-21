;; -*- lexical-binding: t; -*-
;; ======================================
;; init.el — Alice's Emacs Configuration
;; Packages are managed by Nix (emacs.nix).
;; ======================================

;; ---------------------
;; Startup Performance
;; ---------------------
(setq gc-cons-threshold (* 50 1024 1024)) ; 50mb during startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1024 1024)) ; 2mb after startup
            (message "Emacs loaded in %s" (emacs-init-time))))

;; -------------------------------------
;; Theme & UI (early load)
;; -------------------------------------
(load-theme 'doom-laserwave t)

;; -------------------------------------
;; Basic UI
;; -------------------------------------
(setq inhibit-startup-message t)
(scroll-bar-mode -1)   ; Disable visible scrollbar
(tool-bar-mode -1)     ; Disable the toolbar
(tooltip-mode -1)      ; Disable tooltips
(set-fringe-mode 10)   ; Give some breathing room
(menu-bar-mode -1)     ; Disable the menu bar

;; Transparency
(set-frame-parameter nil 'alpha-background 90)
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; Line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

;; -------------------------------------
;; Modeline
;; -------------------------------------
(doom-modeline-mode 1)
(setq doom-modeline-height 35)

;; -------------------------------------
;; All-the-icons
;; Note: run M-x all-the-icons-install-fonts once after first install
;; -------------------------------------
(use-package all-the-icons
  :if (display-graphic-p))

;; -------------------------------------
;; Rainbow Delimiters
;; -------------------------------------
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; -------------------------------------
;; Centaur Tabs
;; ---------------------------------------------------------------------------
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
        centaur-tabs-cycle-scope 'tabs)
  (centaur-tabs-headline-match)
  (centaur-tabs-group-by-projectile-project)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>"  . centaur-tabs-forward))

;; -------------------------------------
;; Dashboard
;; -------------------------------------
(use-package dashboard
  :demand t
  :init
  (setq dashboard-center-content t
        dashboard-banner-logo-title " Helllooooo Alice!"
        dashboard-startup-banner "/home/alice/nixmacs/assets/logo.png"
        dashboard-items '((recents  . 5)
                          (projects . 5))
        initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name)))
  :config
  (dashboard-setup-startup-hook)
  (dashboard-insert-startupify-lists))

;; -------------------------------------
;; Xah Fly Keys (Modal Editing)
;; -------------------------------------
(use-package xah-fly-keys
  :demand t
  :config
  (xah-fly-keys-set-layout "qwerty")
  (xah-fly-keys 1))

;; -------------------------------------
;; Magit
;; -------------------------------------
(use-package magit
  :commands magit-status
  :bind ("C-x g" . magit-status))

;; -------------------------------------
;; Which-Key
;; -------------------------------------
(use-package which-key
  :demand t
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; -------------------------------------
;; Marginalia (rich annotations in the minibuffer)
;; -------------------------------------
(use-package marginalia
  :demand t
  :config
  (marginalia-mode 1))

;; -------------------------------------
;; Consult (enhanced search & navigation)
;; -------------------------------------
(use-package consult
  :bind (("C-s"     . consult-line)
         ("C-x b"   . consult-buffer)
         ("C-x C-r" . consult-recent-file)
         ("M-g g"   . consult-goto-line)
         ("M-g e"   . consult-compile-error)
         ("M-s f"   . consult-find)
         ("M-s r"   . consult-ripgrep)))

;; ---------------------------------------------------------------------------
;; Ivy & Counsel (Navigation & Search) — kept alongside Consult for now
;; ---------------------------------------------------------------------------
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
  (setq ivy-initial-inputs-alist nil)
  (counsel-mode 1))

(use-package swiper)

(use-package ivy-posframe
  :after ivy
  :config
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-center)))
  (ivy-posframe-mode 1))

;; -------------------------------------
;; Projectile
;; -------------------------------------
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/projects")
    (setq projectile-project-search-path '("~/projects")))
  (setq projectile-switch-project-action #'projectile-dired))

;; -------------------------------------
;; Treemacs
;; -------------------------------------
(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") 'treemacs-select-window))
  :config
  (setq treemacs-no-png-images t)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (setq treemacs-width 35
        treemacs-is-never-other-window t
        treemacs-silent-refresh t
        treemacs-silent-filewatch t)
  (when treemacs-python-executable
    (treemacs-git-commit-diff-mode t)))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package lsp-treemacs
  :after (treemacs lsp-mode))

;; -------------------------------------
;; Org-Roam
;; -------------------------------------
(use-package org-roam
  :demand t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  (org-roam-completion-everywhere t)
  (org-roam-dailies-directory "daily/")
  (org-roam-capture-templates
   '(("d" "default" plain
      "%?"
      :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+date: %U\n#+filetags: \n\n")
      :unnarrowed t)
     ("f" "fleeting" plain
      "* %?\n\n%i"
      :target (file+head "fleeting/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+date: %U\n#+filetags: :fleeting:\n\n")
      :unnarrowed t)
     ("l" "literature" plain
      "* Source\n- Author: %^{Author}\n- URL: %^{URL}\n\n* Notes\n%?\n\n* Summary\n"
      :target (file+head "literature/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+date: %U\n#+filetags: :literature:\n\n")
      :unnarrowed t)
     ("p" "permanent" plain
      "%?"
      :target (file+head "permanent/%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+date: %U\n#+filetags: :permanent:\n\n")
      :unnarrowed t)))
  (org-roam-dailies-capture-templates
   '(("d" "default" entry
      "* %<%H:%M> %?"
      :target (file+head "%<%Y-%m-%d>.org"
                         "#+title: %<%Y-%m-%d>\n#+filetags: :daily:\n\n"))))
  :config
  (make-directory org-roam-directory t)
  (org-roam-db-autosync-mode))

;; -------------------------------------
;; Org-Roam UI
;; -------------------------------------
(use-package org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

;; -------------------------------------
;; Org-Modern (prettier org buffers)
;; -------------------------------------
(use-package org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  (setq org-modern-star '("◉" "○" "✸" "✿")
        org-modern-table t
        org-modern-block-fringe 8))

;; -------------------------------------
;; Org-Appear (show markup on cursor entry)
;; -------------------------------------
(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks t
        org-appear-autosubmarkers t
        org-appear-autoentities t
        org-appear-autokeywords t))

;; -------------------------------------
;; DAP Mode (Debug Adapter Protocol)
;; -------------------------------------
(use-package dap-mode
  :after lsp-mode
  :commands (dap-debug dap-debug-last dap-breakpoint-toggle)
  :config
  (dap-auto-configure-mode 1)
  ;; Load language-specific debug adapters as needed
  (require 'dap-python)
  (require 'dap-lldb)   ; C/C++ via LLDB
  (require 'dap-node))  ; Node.js / TypeScript

;; -------------------------------------
;; Mastodon.el (Fediverse client)
;; -------------------------------------
(use-package mastodon
  :commands mastodon
  :config
  (setq mastodon-instance-url "https://fosstodon.org/ "
        mastodon-active-user "alicel"))  ;

;; -------------------------------------
;; LSP Mode
;; -------------------------------------
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
  (setq company-idle-delay 0.0
        company-minimum-prefix-length 1)
  (global-company-mode t))

;; -------------------------------------
;; Language Support
;; -------------------------------------
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

;; -------------------------------------
;; Ement.el (Matrix Client)
;; -------------------------------------
(use-package ement
  :commands ement-connect)

;; -------------------------------------
;; EMMS (Emacs Multimedia System)
;; -------------------------------------
(use-package emms
  :commands (emms emms-play-file)
  :config
  (require 'emms-setup)
  (emms-all)
  (setq emms-player-list '(emms-player-mpv)
        emms-info-functions '(emms-info-native)))

;; Media helper
(defun nixmacs-watch-video (file)
  "Watch a video file in mpv (external window)."
  (interactive "fVideo file: ")
  (start-process "mpv" nil "mpv" file))

;; -------------------------------------
;; Fireplace (cosy)
;; -------------------------------------
(use-package fireplace
  :commands fireplace)

;; -------------------------------------
;; Vterm
;; -------------------------------------
(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 5000))

;; -------------------------------------
;; TRAMP (Remote Development & Root Editing)
;; -------------------------------------
(use-package tramp
  :defer t
  :config
  ;; Default to SSH for fast interactive remote access
  (setq tramp-default-method "ssh")

  ;; Performance optimization
  (setq remote-file-name-inhibit-cache nil
        tramp-verbose 1
        remote-file-name-inhibit-locks t
        remote-file-name-inhibit-auto-save-visited t)

  ;; Faster version control checking over TRAMP (only check Git, bypass others)
  (setq vc-handled-backends '(Git))

  ;; Enable control master for ssh connection reuse
  (customize-set-variable 'tramp-use-connection-share t)

  ;; Direct async processes for improved remote execution speed (Magit, LSP, etc. over TRAMP)
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))
  (connection-local-set-profiles
   '((tramp-connection-type . direct-async))
   'remote-direct-async-process)

  ;; Maintain clean remote paths using the remote's own path
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

;; Sudo editing helper
(defun nixmacs-sudo-edit (&optional arg)
  "Edit currently visited file as root via TRAMP sudo."
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (read-file-name "Find file (as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

;; -------------------------------------
;; Nov.el (EPUB Reader)
;; -------------------------------------
(use-package nov
  :mode ("\\.epub\\'" . nov-mode)
  :config
  (setq nov-text-width 80))

;; -------------------------------------
;; Elfeed (RSS Reader)
;; -------------------------------------
(use-package elfeed
  :commands elfeed
  :bind ("C-x w" . elfeed))

;; -------------------------------------
;; Mu4e (Email Client)
;; -------------------------------------
(use-package mu4e
  :commands mu4e
  :config
  (setq mu4e-change-filenames-when-moving t
        mu4e-update-interval (* 10 60)
        mu4e-get-mail-command "mbsync -a"
        mu4e-maildir "~/Mail"))

;; -------------------------------------
;; Keybindings (SPC Leader via Xah Fly Keys)
;; -------------------------------------
(with-eval-after-load 'xah-fly-keys
  (define-prefix-command 'my-leader-map)
  (define-prefix-command 'my-file-map)
  (define-prefix-command 'my-buffer-map)
  (define-prefix-command 'my-window-map)
  (define-prefix-command 'my-project-map)
  (define-prefix-command 'my-git-map)
  (define-prefix-command 'my-explorer-map)
  (define-prefix-command 'my-terminal-map)
  (define-prefix-command 'my-notes-map)
  (define-prefix-command 'my-notes-daily-map)
  (define-prefix-command 'my-media-map)
  (define-prefix-command 'my-apps-map)
  (define-prefix-command 'my-debug-map)
  (define-prefix-command 'my-social-map)

  ;; SPC in command mode → leader map
  (define-key xah-fly-command-map (kbd "SPC") 'my-leader-map)
  ;; C-SPC as global fallback
  (global-set-key (kbd "C-SPC") 'my-leader-map)

  ;; Top-level
  (define-key my-leader-map (kbd "SPC") 'counsel-M-x)

  ;; Files (SPC f)
  (define-key my-leader-map (kbd "f") 'my-file-map)
  (define-key my-file-map (kbd "f") 'counsel-find-file)
  (define-key my-file-map (kbd "s") 'save-buffer)
  (define-key my-file-map (kbd "r") 'consult-recent-file)
  (define-key my-file-map (kbd "S") 'nixmacs-sudo-edit)
  (define-key my-file-map (kbd "t") 'tramp-cleanup-all-connections)

  ;; Buffers / Tabs (SPC b)
  (define-key my-leader-map (kbd "b") 'my-buffer-map)
  (define-key my-buffer-map (kbd "b") 'consult-buffer)
  (define-key my-buffer-map (kbd "n") 'centaur-tabs-forward)
  (define-key my-buffer-map (kbd "p") 'centaur-tabs-backward)
  (define-key my-buffer-map (kbd "d") 'kill-current-buffer)
  (define-key my-buffer-map (kbd "N") 'centaur-tabs-forward-group)
  (define-key my-buffer-map (kbd "P") 'centaur-tabs-backward-group)
  (define-key my-buffer-map (kbd ">") 'centaur-tabs-move-current-tab-to-right)
  (define-key my-buffer-map (kbd "<") 'centaur-tabs-move-current-tab-to-left)
  (define-key my-buffer-map (kbd "g") 'centaur-tabs-switch-group)

  ;; Windows (SPC w)
  (define-key my-leader-map (kbd "w") 'my-window-map)
  (define-key my-window-map (kbd "l") 'windmove-right)
  (define-key my-window-map (kbd "h") 'windmove-left)
  (define-key my-window-map (kbd "j") 'windmove-down)
  (define-key my-window-map (kbd "k") 'windmove-up)
  (define-key my-window-map (kbd "v") 'split-window-right)
  (define-key my-window-map (kbd "s") 'split-window-below)
  (define-key my-window-map (kbd "d") 'delete-window)

  ;; Projects (SPC p)
  (define-key my-leader-map (kbd "p") 'my-project-map)
  (define-key my-project-map (kbd "f") 'projectile-find-file)
  (define-key my-project-map (kbd "p") 'projectile-switch-project)

  ;; Git (SPC g)
  (define-key my-leader-map (kbd "g") 'my-git-map)
  (define-key my-git-map (kbd "s") 'magit-status)

  ;; Explorer (SPC e)
  (define-key my-leader-map (kbd "e") 'my-explorer-map)
  (define-key my-explorer-map (kbd "e") 'treemacs)
  (define-key my-explorer-map (kbd "f") 'treemacs-find-file)
  (define-key my-explorer-map (kbd "p") 'treemacs-projectile)
  (define-key my-explorer-map (kbd "s") 'lsp-treemacs-symbols)
  (define-key my-explorer-map (kbd "i") 'lsp-treemacs-implementations)
  (define-key my-explorer-map (kbd "r") 'lsp-treemacs-references)

  ;; Terminal (SPC t)
  (define-key my-leader-map (kbd "t") 'my-terminal-map)
  (define-key my-terminal-map (kbd "t") 'vterm)

  ;; Notes / Org-Roam (SPC n)
  (define-key my-leader-map (kbd "n") 'my-notes-map)
  (define-key my-notes-map (kbd "f") 'org-roam-node-find)
  (define-key my-notes-map (kbd "i") 'org-roam-node-insert)
  (define-key my-notes-map (kbd "c") 'org-roam-capture)
  (define-key my-notes-map (kbd "b") 'org-roam-buffer-toggle)
  (define-key my-notes-map (kbd "U") 'org-roam-ui-open)
  (define-key my-notes-map (kbd "d") 'my-notes-daily-map)
  (define-key my-notes-daily-map (kbd "t") 'org-roam-dailies-goto-today)
  (define-key my-notes-daily-map (kbd "y") 'org-roam-dailies-goto-yesterday)
  (define-key my-notes-daily-map (kbd "d") 'org-roam-dailies-goto-date)
  (define-key my-notes-daily-map (kbd "c") 'org-roam-dailies-capture-today)
  (define-key my-notes-map (kbd "s") 'org-roam-db-sync)

  ;; Media (SPC m)
  (define-key my-leader-map (kbd "m") 'my-media-map)
  (define-key my-media-map (kbd "v") 'nixmacs-watch-video)

  ;; Debug (SPC d)
  (define-key my-leader-map (kbd "d") 'my-debug-map)
  (define-key my-debug-map (kbd "d") 'dap-debug)
  (define-key my-debug-map (kbd "l") 'dap-debug-last)
  (define-key my-debug-map (kbd "b") 'dap-breakpoint-toggle)
  (define-key my-debug-map (kbd "c") 'dap-continue)
  (define-key my-debug-map (kbd "n") 'dap-next)
  (define-key my-debug-map (kbd "s") 'dap-step-in)
  (define-key my-debug-map (kbd "o") 'dap-step-out)
  (define-key my-debug-map (kbd "q") 'dap-disconnect)

  ;; Social (SPC z)
  (define-key my-leader-map (kbd "z") 'my-social-map)
  (define-key my-social-map (kbd "m") 'mastodon)
  (define-key my-social-map (kbd "e") 'ement-connect)

  ;; Apps / Fun (SPC a)
  (define-key my-leader-map (kbd "a") 'my-apps-map)
  (define-key my-apps-map (kbd "f") 'fireplace)

  ;; Consult search (SPC s)
  (define-prefix-command 'my-search-map)
  (define-key my-leader-map (kbd "s") 'my-search-map)
  (define-key my-search-map (kbd "s") 'consult-line)
  (define-key my-search-map (kbd "r") 'consult-ripgrep)
  (define-key my-search-map (kbd "f") 'consult-find)

  ;; Which-key prefix descriptions
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements my-leader-map
      "f" "files"
      "b" "buffers/tabs"
      "w" "windows"
      "p" "projects"
      "g" "git"
      "e" "explorer"
      "t" "terminal"
      "n" "notes"
      "m" "media"
      "d" "debug"
      "z" "social"
      "s" "search"
      "a" "apps/fun")
    (which-key-add-keymap-based-replacements my-notes-map
      "d" "dailies")))
