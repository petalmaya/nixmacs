{ emacs-overlay }:

{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    emacs-overlay.overlay
  ];

  home.packages = with pkgs; [
    clang-tools                  # C/C++ LSP (clangd)
    pyright                      # Python LSP
    typescript-language-server   # JS/TS LSP
    nixd                         # Nix LSP
    mpv                          # Media player backend for EMMS
    ffmpeg                       # Metadata tools
    cava                         # Audio visualizer backend
    sqlite                       # Required by org-roam
    graphviz                     # Optional: for org-roam graph visualizations
    mu                           # Required by mu4e
    isync                        # Commonly used with mu4e for fetching mail
    sbcl                         # Common Lisp implementation (used by SLY)
    # DAP debug adapters
    lldb                         # C/C++ debug adapter (via dap-lldb)
    nodejs                       # Node.js debug adapter (via dap-node)
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;

    extraPackages = epkgs: with epkgs; [
      # Modal editing
      xah-fly-keys

      # UI & Theming
      ef-themes
      spacious-padding
      doom-modeline
      all-the-icons
      dashboard
      rainbow-delimiters

      # Org enhancements
      org-modern
      org-appear

      # Completion & Navigation
      vertico
      orderless
      embark
      embark-consult
      consult
      marginalia

      # Key discovery
      which-key
      use-package

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

      # Common Lisp
      sly
      sly-quicklisp
      sly-asdf
      sly-named-readtables
      paredit

      # Debug Adapter Protocol
      dap-mode

      # Matrix client
      ement

      # Fediverse / Mastodon
      mastodon

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
      websocket

      # Mail, RSS, and EPUBs
      nov
      elfeed
      mu4e
    ];

    # Load init.el directy
    extraConfig = builtins.readFile ./init.el;
  };
}
