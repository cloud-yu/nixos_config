# Lix variant of nixos-wsl.
#
# This module replaces the default Nix implementation with Lix and adds
# zellij. It is imported on top of the common nixos-wsl configuration by
# the `nixos-wsl-lix` nixosConfiguration in flake.nix.
#
# Activate with:
#   sudo nixos-rebuild switch --flake .#nixos-wsl-lix
#
# Switch back to the Nix variant:
#   sudo nixos-rebuild switch --flake .#nixos-wsl
{
  pkgs,
  lib,
  ...
}: {
  # Use Lix instead of Nix.
  nix.package = pkgs.lixPackageSets.stable.lix;

  # Marker file indicating this system is running the lix variant.
  # (Previously set inside specialisation.lix; kept for compatibility so
  # scripts checking /etc/specialisation still work.)
  environment.etc."specialisation".text = "lix";

  environment.systemPackages = lib.mkAfter (
    with pkgs; [
      zellij
    ]
  );
}
