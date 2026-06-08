{
  description = "nix config";
  # nixConfig = {
  #   extra-experimental-features = "nix-command flakes configurable-impure-env";

  #   impure-env = true;
  #   allowed-impure-env-deps = [
  #     "HTTP_PROXY"
  #     "HTTPS_PROXY"
  #     "http_proxy"
  #     "https_proxy"
  #     "ALL_PROXY"
  #     "all_proxy"
  #     "NO_PROXY"
  #     "no_proxy"
  #     "GOPROXY"
  #   ];
  # };
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nixos-cli
    nixos-cli.url = "github:nix-community/nixos-cli";
    # nixos-cli.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    # pre-commit-hooks
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.inputs.flake-compat.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    disko,
    nixos-facter-modules,
    nixos-wsl,
    nixos-cli,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      # "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
    confRev =
      if (self ? shortRev)
      then self.shortRev
      else if (self ? dirtyShortRev)
      then self.dirtyShortRev
      else "unknown";
  in {
    debug = let
      traceMsg = ''
        --- DEBUG TRACE ---
        Value of confRev: ${confRev}
        Dose self have shortRev: ${toString (self ? shortRev)}
        Dose self have dirtyShortRev: ${toString (self ? dirtyShortRev)}
        All attributes in self: ${builtins.concatStringsSep ", " (builtins.attrNames self)}
        --- END DEBUG TRACE ---
      '';
    in
      # The trace function prints the message and then returns the second argument.
      builtins.trace traceMsg {
        calculatedConfRev = confRev;
        selfAttributes = builtins.attrNames self;
      };
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # `nix flake check` will use this to check your nix files
    checks = forAllSystems (system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
        };
      };
    });

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # FIXME replace with your hostname
      ucloud-hk = nixpkgs.lib.nixosSystem {
        system = builtins.elemAt systems 0;
        specialArgs = {inherit confRev inputs outputs;};
        modules = [
          # nixos-cli.nixosModules.nixos-cli
          disko.nixosModules.disko
          # > Our main nixos configuration file <
          ./nixos/ucloud-hk
          nixos-facter-modules.nixosModules.facter
        ];
      };

      nixos-wsl = nixpkgs.lib.nixosSystem {
        system = builtins.elemAt systems 0;
        specialArgs = {inherit confRev inputs outputs;};
        modules = [
          nixos-wsl.nixosModules.wsl
          nixos-cli.nixosModules.nixos-cli
          # > Our main nixos configuration file <
          ./nixos/nixos-wsl
          home-manager.nixosModules.home-manager
          {
            # Force disable channel management here to override home-manager's default
            nix.channel.enable = nixpkgs.lib.mkForce false;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixos = {
              imports = [
                ./home-manager/nixos-wsl
              ];
              home.file.".nix-profile".enable = false;
            };
          }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "mistery@ucloud-hk" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/common/nix.nix
          ./home-manager/ucloud-hk
          outputs.homeManagerModules.rcloneService
        ];
      };
      "nixos@nixos-wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/common/nix.nix
          ./home-manager/nixos-wsl
        ];
      };
    };
  };
}
