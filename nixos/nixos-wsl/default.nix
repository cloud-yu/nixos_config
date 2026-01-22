# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{pkgs, ...}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    ../common/nix.nix
    ../common/region.nix
    ../common/programs.nix
    ../common/kernel.nix
    ./users.nix
    ./programs.nix
    ./mount.nix
    ./wsl-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    curl
  ];
  # TODO: Set your hostname
  networking.hostName = "nixos";
  networking.domain = "wsl";
  # networking.proxy.default = "http://127.0.0.1:10808/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # enable documentations
  documentation = {
    enable = true;
    man.enable = true;
    man.generateCaches = false;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    nixos.enable = true;
  };

  #nix.settings.substituters = [
  #    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  #    "https://mirrors.ustc.edu.cn/nix-channels/store"
  #  ];

  environment.etc = {
    # hostnamectl location read from /etc/machine-info, set location information
    "machine-info".text = ''
      LOCATION=notebook
    '';
  };

  specialisation = {
    lix = {
      inheritParentConfig = true;

      configuration = {
        # use Lix instead of Nix
        nix.package = pkgs.lixPackageSets.stable.lix;
        environment.etc."specialisation".text = "lix";
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
