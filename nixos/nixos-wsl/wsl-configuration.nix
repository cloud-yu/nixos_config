{
  nixpkgs.hostPlatform = "x86_64-linux";
  wsl = {
    enable = true;
    wrapBinSh = false;
    defaultUser = "nixos";
    wslConf = {
      interop = {
        enabled = false;
        appendWindowsPath = false;
      };
    };
  };
}
