# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    ../common/nix.nix
    ../common/users.nix
    ../common/region.nix
    ../common/programs.nix
    ./disk-config.nix
    ./services.nix
    ./acme.nix
    ./nginx.nix
    ./proxy-service.nix
    ./programs.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ./facter.nix
  ];

  environment.etc = {
    # hostnamectl location read from /etc/machine-info, set location information
    "machine-info".text = ''
      LOCATION=hk
    '';
  };

  # TODO: Set your hostname
  networking.hostName = "ucloud";
  networking.useNetworkd = true;
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
