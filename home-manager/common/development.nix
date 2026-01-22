{pkgs, ...}: {
  home.packages = with pkgs; [
    nil
    nixfmt-rfc-style
    nix-inspect
    alejandra
    shellcheck
    clang-tools
    devenv
    rustup
    uv
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  services.podman.enable = true;
}
