{
  description = "A library of useful Nix functions and types.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    nix-darwin.url = github:hackworthltd/nix-darwin/fixes-v2;
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , ...
    }@inputs:
    let
      bootstrap = (import ./nix/overlays/000-bootstrap.nix) { } nixpkgs;

      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSupportedSystems = bootstrap.lib.flakes.forAllSystems supportedSystems;

      nixosSystems = [ "x86_64-linux" ];
      forAllNixosSystems = bootstrap.lib.flakes.forAllSystems nixosSystems;

      darwinSystems = [ "x86_64-darwin" ];
      forAllDarwinSystems = bootstrap.lib.flakes.forAllSystems darwinSystems;

      pkgsFor = forAllSupportedSystems
        (system:
          import nixpkgs
            {
              inherit system;
              config = {
                allowUnfree = true;
                allowBroken = true;
              };
              overlays = [ self.overlay ];
            }
        );

    in
    {
      lib = pkgsFor.x86_64-linux.lib;

      overlay =
        let
          overlaysFromDir = bootstrap.lib.overlays.combineFromDir ./nix/overlays;
        in
        bootstrap.lib.overlays.combine [
          (final: prev:
            {
              lib = (prev.lib or { }) // {
                flakes = (prev.lib.flakes or { }) // {
                  # For some reason, the nixpkgs flake doesn't roll its local
                  # lib.nixosSystem into nixpkgs.lib. We expose it here.
                  inherit (nixpkgs.lib) nixosSystem;

                  # Ditto for nix-darwin's lib.darwinSystem function.
                  inherit (nix-darwin.lib) darwinSystem;
                };
              };
            }
          )
          overlaysFromDir
        ];

      packages = forAllSupportedSystems
        (system:
          let
            pkgs = pkgsFor.${system};
          in
          {
            inherit (pkgs) ffdhe2048Pem ffdhe3072Pem ffdhe4096Pem;
          }
        );

      nixosConfigurations =
        let
          extraModules = [
            {
              boot.isContainer = true;
            }
          ];
          mkSystem = self.lib.flakes.nixosSystem' extraModules;
        in
        self.lib.flakes.nixosConfigurations.importFromDirectory
          mkSystem
          ./test-configs/nixos
          {
            inherit (self) lib;
          };

      darwinConfigurations =
        let
          extraModules = [
            {
              services.nix-daemon.enable = true;
              users.nix.configureBuildUsers = true;
              users.nix.nrBuildUsers = 32;
            }
          ];
          mkSystem = self.lib.flakes.darwinSystem' extraModules;
        in
        self.lib.flakes.darwinConfigurations.importFromDirectory
          mkSystem
          ./test-configs/nix-darwin
          {
            inherit (self) lib;
          };

      hydraJobs = {
        build = self.packages;
        nixosConfigurations.x86_64-linux = self.lib.flakes.nixosConfigurations.build self.nixosConfigurations;
        darwinConfigurations.x86_64-darwin = self.lib.flakes.darwinConfigurations.build self.darwinConfigurations;

        tests = forAllSupportedSystems
          (
            system:
              with import (nixpkgs + "/pkgs/top-level/release-lib.nix")
                {
                  supportedSystems = [ system ];
                  scrubJobs = true;
                  nixpkgsArgs = {
                    config = {
                      allowUnfree = false;
                      allowBroken = true;
                      inHydra = true;
                    };
                    overlays = [
                      self.overlay
                      (import ./tests)
                    ];
                  };
                };
              mapTestOn {
                dlnCleanSourceNix = all;
                dlnCleanSourceHaskell = all;
                dlnCleanSourceSystemCruft = all;
                dlnCleanSourceEditors = all;
                dlnCleanSourceMaintainer = all;
                dlnCleanSourceAllExtraneous = all;
                dlnCleanPackageNix = all;
                dlnCleanPackageHaskell = all;
                dlnCleanPackageSystemCruft = all;
                dlnCleanPackageEditors = all;
                dlnCleanPackageMaintainer = all;
                dlnCleanPackageAllExtraneous = all;
                dlnAttrSets = all;
                dlnIPAddr = all;
                dlnMisc = all;
                dlnFfdhe = all;
                dlnTypes = all;
              }
          );

        amazonImages = forAllNixosSystems (
          system:
          let
            extraModules = [
              {
                ec2.hvm = true;
                amazonImage.format = "qcow2";
                amazonImage.sizeMB = 4096;
              }
            ];
            mkSystem = self.lib.flakes.amazonImage extraModules;
            configs =
              self.lib.flakes.nixosConfigurations.importFromDirectory
                mkSystem
                ./test-configs/nixos
                {
                  inherit (self) lib;
                  inherit system;
                };
          in
          self.lib.flakes.nixosConfigurations.buildAmazonImages configs
        );

        isoImages = forAllNixosSystems (
          system:
          let
            extraModules = [
              {
                isoImage.isoBaseName = self.lib.mkForce "hacknix-lib-test-iso";
              }
            ];
            mkSystem = self.lib.flakes.isoImage extraModules;
            configs =
              self.lib.flakes.nixosConfigurations.importFromDirectory
                mkSystem
                ./test-configs/nixos
                {
                  inherit (self) lib;
                  inherit system;
                };
          in
          self.lib.flakes.nixosConfigurations.buildISOImages configs
        );
      };

      ciJobs = self.lib.flakes.recurseIntoHydraJobs self.hydraJobs;
    };
}
