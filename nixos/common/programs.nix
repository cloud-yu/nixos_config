{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = lib.mkBefore (
    with pkgs; [
      binutils
      eza
      file
      gnupg
      home-manager
      jq
      libarchive
      lsof
      rclone
      ripgrep
      rsync
      tmux
      fd
      fzf
      zoxide
      vim
      wget
      zsh
      fish
      delta
    ]
  );

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
  };
  programs.nix-ld.enable = true;
  programs.bandwhich.enable = true;
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "vim";
        pager = "delta";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      delta = {
        side-by-side = true;
        navigate = true;
        file-style = "yellow bold";
        file-decoration-style = "blue ul";
        syntax-theme = "OneHalfDark";
      };
    };
  };

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-tty;
    };
  };

  programs.fish.enable = true;
}
