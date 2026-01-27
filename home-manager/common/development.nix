{pkgs, ...}: {
  home.packages = with pkgs; [
    nil
    nix-inspect
    alejandra
    shellcheck
    podman
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
