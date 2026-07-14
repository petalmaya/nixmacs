;; -*- lexical-binding: t; -*-
;; Alice's emacs config. Packages managed by Nix (emacs.nix).

;;; Startup

(setq gc-cons-threshold (* 50 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1024 1024))
            (message "up in %s" (emacs-init-time))))

;;; Theme + basic UI

(load-theme 'ef-elea-dark t)

(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)
(set-fringe-mode 10)

;; A little transparency never hurt
(set-frame-parameter nil 'alpha-background 90)
(add-to-list 'default-frame-alist '(alpha-background . 90))

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

;;; Spacious Padding

(use-package spacious-padding
  :demand t
  :config
  (setq spacious-padding-widths
        '(:internal-border-width 20
          :header-line-width     4
          :mode-line-width       4
          :tab-width             4
          :right-divider-width   24
          :scroll-bar-width      8
          :fringe-width          8))
  (spacious-padding-mode 1))

;;; Tab Bar

(tab-bar-mode 1)
(setq tab-bar-show            t
      tab-bar-new-tab-choice  "*scratch*"
      tab-bar-close-button-show nil
      tab-bar-new-button-show   nil
      tab-bar-tab-hints         t)

;;; Modeline + Icons

(doom-modeline-mode 1)
(setq doom-modeline-height 35)

(use-package all-the-icons
  :if (display-graphic-p))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;; Dashboard

(use-package dashboard
  :demand t
  :init
  (setq dashboard-center-content     t
        dashboard-banner-logo-title  " Helllooooo Alice!"
        dashboard-startup-banner     "/home/alice/nixmacs/assets/logo.png"
        dashboard-items              '((recents  . 5)
                                       (projects . 5))
        initial-buffer-choice        (lambda () (get-buffer-create dashboard-buffer-name)))
  :config
  (dashboard-setup-startup-hook)
  (dashboard-insert-startupify-lists))

;;; Modal editing — Xah Fly Keys

(use-package xah-fly-keys
  :demand t
  :config
  (xah-fly-keys-set-layout "qwerty")
  (xah-fly-keys 1))

;;; Completion stack — Vertico / Orderless / Embark / Consult

;; Vertico: vertical minibuffer completion UI
(use-package vertico
  :demand t
  :config
  (vertico-mode 1)
  ;; Cycle at the edges of the candidate list
  (setq vertico-cycle t))

;; Orderless: space-separated component matching
(use-package orderless
  :demand t
  :config
  (setq completion-styles             '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

;; Embark: right-click-style actions on any completion candidate
(use-package embark
  :bind (("C-," . embark-act)
         ("C-." . embark-dwim)
         ("C-h B" . embark-bindings))
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

;; Embark + Consult integration (e.g. preview in embark-collect)
(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Consult: enhanced commands built on completing-read
(use-package consult
  :bind (("C-s"     . consult-line)
         ("C-x b"   . consult-buffer)
         ("C-x C-r" . consult-recent-file)
         ("M-g g"   . consult-goto-line)
         ("M-g e"   . consult-compile-error)
         ("M-s f"   . consult-find)
         ("M-s r"   . consult-ripgrep))
  :config
  ;; Use consult for xref navigation
  (setq xref-show-xrefs-function       #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package marginalia
  :demand t
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :config (marginalia-mode 1))

(use-package which-key
  :demand t
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.3))

;;; Projects + Git

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/projects")
    (setq projectile-project-search-path '("~/projects")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package magit
  :commands magit-status
  :bind ("C-x g" . magit-status))

;;; Tree explorer

(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") 'treemacs-select-window))
  :config
  (setq treemacs-no-png-images         t
        treemacs-width                 35
        treemacs-is-never-other-window t
        treemacs-silent-refresh        t
        treemacs-silent-filewatch      t)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (when treemacs-python-executable
    (treemacs-git-commit-diff-mode t)))

(use-package treemacs-projectile :after (treemacs projectile))
(use-package treemacs-magit      :after (treemacs magit))
(use-package lsp-treemacs        :after (treemacs lsp-mode))

;;; LSP + Company

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init (setq lsp-keymap-prefix "C-c l")
  :config (lsp-enable-which-key-integration t))

(use-package lsp-ui :commands lsp-ui-mode)

(use-package company
  :config
  (setq company-idle-delay           0.0
        company-minimum-prefix-length 1)
  (global-company-mode t))

;;; DAP (Debug Adapter Protocol)

(use-package dap-mode
  :after lsp-mode
  :commands (dap-debug dap-debug-last dap-breakpoint-toggle)
  :config
  (dap-auto-configure-mode 1)
  (require 'dap-python)
  (require 'dap-lldb)
  (require 'dap-node))

;;; Language support

(use-package haskell-mode
  :mode "\\.hs\\'"
  :hook (haskell-mode . lsp-deferred))

(use-package lsp-haskell :after (lsp-mode haskell-mode))

(use-package nix-mode
  :mode "\\.nix\\'"
  :hook (nix-mode . lsp-deferred))

(use-package js2-mode
  :mode "\\.js\\'"
  :hook (js2-mode . lsp-deferred))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred))

(add-hook 'c-mode-hook     'lsp-deferred)
(add-hook 'c++-mode-hook   'lsp-deferred)
(add-hook 'python-mode-hook 'lsp-deferred)

;;; Common Lisp — SLY

(use-package sly
  :commands (sly sly-connect)
  :init
  ;; Declare ALL contribs before SLY/SLYNK loads — adding them later causes
  ;; "Package SLYNK-MREPL does not exist" because the server starts without them.
  (setq sly-contribs '(sly-fancy sly-asdf sly-named-readtables))
  :config
  (setq inferior-lisp-program "sbcl"
        sly-mrepl-pop-sylvester nil))


;; ASDF integration
(use-package sly-asdf :after sly)

;; Named readtables (useful for e.g. cl-interpol)
(use-package sly-named-readtables :after sly)

;; Paredit for structural s-expr editing
(use-package paredit
  :hook ((lisp-mode       . paredit-mode)
         (sly-mrepl-mode  . paredit-mode)
         (emacs-lisp-mode . paredit-mode)
         (scheme-mode     . paredit-mode)))

;; Pretty-print λ and a few other symbols in Lisp buffers
(defun nixmacs-lisp-prettify ()
  (setq prettify-symbols-alist
        '(("lambda"  . ?λ)
          ("nil"     . ?∅)))
  (prettify-symbols-mode 1))
(add-hook 'lisp-mode-hook       #'nixmacs-lisp-prettify)
(add-hook 'emacs-lisp-mode-hook #'nixmacs-lisp-prettify)

;;; Org / Org-Roam

(use-package org-modern
  :hook
  (org-mode            . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  :config
  (setq org-modern-star         '("◉" "○" "✸" "✿")
        org-modern-table        t
        org-modern-block-fringe 8))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks      t
        org-appear-autosubmarkers t
        org-appear-autoentities   t
        org-appear-autokeywords   t))

(use-package org-roam
  :demand t
  :init (setq org-roam-v2-ack t)
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

(use-package org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme     t
        org-roam-ui-follow         t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start  nil))

;;; Social + Multimedia

(use-package mastodon
  :commands mastodon
  :config
  (setq mastodon-instance-url "https://fosstodon.org/"
        mastodon-active-user  "alicel"))

(use-package ement
  :commands ement-connect)

(use-package emms
  :commands (emms emms-play-file)
  :config
  (require 'emms-setup)
  (emms-all)
  (setq emms-player-list    '(emms-player-mpv)
        emms-info-functions '(emms-info-native)))

(defun nixmacs-watch-video (file)
  "Watch a video FILE in mpv (external window)."
  (interactive "fVideo file: ")
  (start-process "mpv" nil "mpv" file))

(use-package fireplace :commands fireplace)

;;; Terminal + TRAMP

(use-package ghostel
  :commands (ghostel ghostel-project ghostel-project-list-buffers)
  :bind (("C-x m" . ghostel)
         :map project-prefix-map
         ("m" . ghostel-project)
         ("M" . ghostel-project-list-buffers))
  :config
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package tramp
  :defer t
  :config
  (setq tramp-default-method "ssh")
  (setq remote-file-name-inhibit-cache            nil
        tramp-verbose                              1
        remote-file-name-inhibit-locks             t
        remote-file-name-inhibit-auto-save-visited t)
  (setq vc-handled-backends '(Git))
  (customize-set-variable 'tramp-use-connection-share t)
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))
  (connection-local-set-profiles
   '((tramp-connection-type . direct-async))
   'remote-direct-async-process)
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(defun nixmacs-sudo-edit (&optional arg)
  "Edit currently visited file as root via TRAMP sudo."
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (read-file-name "Find file (as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

;;; Dired

(use-package dired
  :ensure nil  ; built-in
  :config
  ;; Reuse the same buffer when navigating into a subdirectory,
  ;; instead of spawning a new one each time.
  (setq dired-kill-when-opening-new-dired-buffer t)
  :bind (:map dired-mode-map
         ;; RET and ^ both reuse the current buffer (no new buffer spam)
         ("RET" . dired-find-alternate-file)
         ("^"   . (lambda () (interactive)
                    (find-alternate-file "..")))))

;;; Other readers

(use-package nov
  :mode ("\\.epub\\'" . nov-mode)
  :config (setq nov-text-width 80))

(use-package elfeed
  :commands elfeed
  :bind ("C-x w" . elfeed))

(use-package mu4e
  :commands mu4e
  :config
  (setq mu4e-change-filenames-when-moving t
        mu4e-update-interval              (* 10 60)
        mu4e-get-mail-command             "mbsync -a"
        mu4e-maildir                      "~/Mail"))

;;; Keybindings (SPC leader via Xah Fly Keys)

(with-eval-after-load 'xah-fly-keys
  (define-prefix-command 'my-leader-map)
  (define-prefix-command 'my-file-map)
  (define-prefix-command 'my-buffer-map)
  (define-prefix-command 'my-tab-map)
  (define-prefix-command 'my-window-map)
  (define-prefix-command 'my-project-map)
  (define-prefix-command 'my-git-map)
  (define-prefix-command 'my-explorer-map)
  (define-prefix-command 'my-terminal-map)
  (define-prefix-command 'my-notes-map)
  (define-prefix-command 'my-notes-daily-map)
  (define-prefix-command 'my-search-map)
  (define-prefix-command 'my-media-map)
  (define-prefix-command 'my-apps-map)
  (define-prefix-command 'my-debug-map)
  (define-prefix-command 'my-social-map)
  (define-prefix-command 'my-lisp-map)

  (define-key xah-fly-command-map (kbd "SPC") 'my-leader-map)
  (global-set-key (kbd "C-SPC") 'my-leader-map)

  (define-key my-leader-map (kbd "SPC") 'execute-extended-command)

  ;; f — files
  (define-key my-leader-map (kbd "f") 'my-file-map)
  (define-key my-file-map   (kbd "f") 'find-file)
  (define-key my-file-map   (kbd "s") 'save-buffer)
  (define-key my-file-map   (kbd "r") 'consult-recent-file)
  (define-key my-file-map   (kbd "S") 'nixmacs-sudo-edit)
  (define-key my-file-map   (kbd "t") 'tramp-cleanup-all-connections)

  ;; b — buffers
  (define-key my-leader-map (kbd "b") 'my-buffer-map)
  (define-key my-buffer-map (kbd "b") 'consult-buffer)
  (define-key my-buffer-map (kbd "d") 'kill-current-buffer)
  (define-key my-buffer-map (kbd "n") 'next-buffer)
  (define-key my-buffer-map (kbd "p") 'previous-buffer)

  ;; TAB — tabs
  (define-key my-leader-map (kbd "TAB") 'my-tab-map)
  (define-key my-tab-map    (kbd "n")   'tab-bar-new-tab)
  (define-key my-tab-map    (kbd "d")   'tab-bar-close-tab)
  (define-key my-tab-map    (kbd "r")   'tab-bar-rename-tab)
  (define-key my-tab-map    (kbd "]")   'tab-bar-switch-to-next-tab)
  (define-key my-tab-map    (kbd "[")   'tab-bar-switch-to-prev-tab)
  (define-key my-tab-map    (kbd "s")   'tab-bar-switch-to-tab)
  (define-key my-tab-map    (kbd "m")   'tab-bar-move-tab)

  ;; w — windows
  (define-key my-leader-map (kbd "w") 'my-window-map)
  (define-key my-window-map (kbd "l") 'windmove-right)
  (define-key my-window-map (kbd "h") 'windmove-left)
  (define-key my-window-map (kbd "j") 'windmove-down)
  (define-key my-window-map (kbd "k") 'windmove-up)
  (define-key my-window-map (kbd "v") 'split-window-right)
  (define-key my-window-map (kbd "s") 'split-window-below)
  (define-key my-window-map (kbd "d") 'delete-window)

  ;; p — projects
  (define-key my-leader-map  (kbd "p") 'my-project-map)
  (define-key my-project-map (kbd "f") 'projectile-find-file)
  (define-key my-project-map (kbd "p") 'projectile-switch-project)

  ;; g — git
  (define-key my-leader-map (kbd "g") 'my-git-map)
  (define-key my-git-map    (kbd "s") 'magit-status)

  ;; e — explorer
  (define-key my-leader-map   (kbd "e") 'my-explorer-map)
  (define-key my-explorer-map (kbd "e") 'treemacs)
  (define-key my-explorer-map (kbd "f") 'treemacs-find-file)
  (define-key my-explorer-map (kbd "p") 'treemacs-projectile)
  (define-key my-explorer-map (kbd "s") 'lsp-treemacs-symbols)
  (define-key my-explorer-map (kbd "i") 'lsp-treemacs-implementations)
  (define-key my-explorer-map (kbd "r") 'lsp-treemacs-references)

  ;; t — terminal
  (define-key my-leader-map   (kbd "t") 'my-terminal-map)
  (define-key my-terminal-map (kbd "t") 'ghostel)

  ;; n — notes / org-roam
  (define-key my-leader-map      (kbd "n") 'my-notes-map)
  (define-key my-notes-map       (kbd "f") 'org-roam-node-find)
  (define-key my-notes-map       (kbd "i") 'org-roam-node-insert)
  (define-key my-notes-map       (kbd "c") 'org-roam-capture)
  (define-key my-notes-map       (kbd "b") 'org-roam-buffer-toggle)
  (define-key my-notes-map       (kbd "U") 'org-roam-ui-open)
  (define-key my-notes-map       (kbd "s") 'org-roam-db-sync)
  (define-key my-notes-map       (kbd "d") 'my-notes-daily-map)
  (define-key my-notes-daily-map (kbd "t") 'org-roam-dailies-goto-today)
  (define-key my-notes-daily-map (kbd "y") 'org-roam-dailies-goto-yesterday)
  (define-key my-notes-daily-map (kbd "d") 'org-roam-dailies-goto-date)
  (define-key my-notes-daily-map (kbd "c") 'org-roam-dailies-capture-today)

  ;; s — search
  (define-key my-leader-map (kbd "s") 'my-search-map)
  (define-key my-search-map (kbd "s") 'consult-line)
  (define-key my-search-map (kbd "r") 'consult-ripgrep)
  (define-key my-search-map (kbd "f") 'consult-find)

  ;; m — media
  (define-key my-leader-map (kbd "m") 'my-media-map)
  (define-key my-media-map  (kbd "v") 'nixmacs-watch-video)

  ;; d — debug
  (define-key my-leader-map (kbd "d") 'my-debug-map)
  (define-key my-debug-map  (kbd "d") 'dap-debug)
  (define-key my-debug-map  (kbd "l") 'dap-debug-last)
  (define-key my-debug-map  (kbd "b") 'dap-breakpoint-toggle)
  (define-key my-debug-map  (kbd "c") 'dap-continue)
  (define-key my-debug-map  (kbd "n") 'dap-next)
  (define-key my-debug-map  (kbd "s") 'dap-step-in)
  (define-key my-debug-map  (kbd "o") 'dap-step-out)
  (define-key my-debug-map  (kbd "q") 'dap-disconnect)

  ;; z — social
  (define-key my-leader-map (kbd "z") 'my-social-map)
  (define-key my-social-map (kbd "m") 'mastodon)
  (define-key my-social-map (kbd "e") 'ement-connect)

  ;; a — apps / fun
  (define-key my-leader-map (kbd "a") 'my-apps-map)
  (define-key my-apps-map   (kbd "f") 'fireplace)

  ;; l — common lisp / sly
  (define-key my-leader-map (kbd "l") 'my-lisp-map)
  (define-key my-lisp-map   (kbd "s") 'sly)
  (define-key my-lisp-map   (kbd "c") 'sly-connect)
  (define-key my-lisp-map   (kbd "q") 'sly-quicklisp)
  (define-key my-lisp-map   (kbd "e") 'sly-eval-last-expression)
  (define-key my-lisp-map   (kbd "E") 'sly-eval-defun)
  (define-key my-lisp-map   (kbd "b") 'sly-eval-buffer)
  (define-key my-lisp-map   (kbd "d") 'sly-describe-symbol)
  (define-key my-lisp-map   (kbd "h") 'sly-hyperspec-lookup)

  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements my-leader-map
      "f"   "files"
      "b"   "buffers"
      "TAB" "tabs"
      "w"   "windows"
      "p"   "projects"
      "g"   "git"
      "e"   "explorer"
      "t"   "terminal"
      "n"   "notes"
      "s"   "search"
      "m"   "media"
      "d"   "debug"
      "z"   "social"
      "a"   "apps/fun"
      "l"   "lisp")
    (which-key-add-keymap-based-replacements my-notes-map
      "d" "dailies")))
