{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = lib.mkBefore (
    with pkgs; [
      rsync
      lsof
      file
      eza
      ripgrep
      binutils
      jq
      libarchive
      wget
      vim
      zsh
      tmux
      rclone
      home-manager
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
      };
    };
  };
}
