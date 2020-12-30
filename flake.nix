{
  description = "A library of useful Nix functions and types.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    nix-darwin.url = github:LnL7/nix-darwin;
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , ...
    }@inputs:
    let
      forAllSystems = systems: f: nixpkgs.lib.genAttrs systems (system: f system);

      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSupportedSystems = forAllSystems supportedSystems;

      overlaysAsList = map (name: self.overlays.${name}) (builtins.attrNames self.overlays);

      pkgsFor = forAllSupportedSystems
        (system:
          import nixpkgs
            {
              inherit system;
              config = {
                allowUnfree = true;
                allowBroken = true;
              };
              overlays = overlaysAsList;
            }
        );

      ## Useful for importing whole directories.
      ##
      ## Thanks to dtzWill:
      ## https://github.com/dtzWill/nur-packages/commit/f601a6b024ac93f7ec242e6e3dbbddbdcf24df0b#diff-a013e20924130857c649dd17226282ff

      listDirectory = action: dir:
        let
          list = builtins.readDir dir;
          names = builtins.attrNames list;
          allowedName = baseName: !(
            # From lib/sources.nix, ignore editor backup/swap files
            builtins.match "^\\.sw[a-z]$" baseName != null
            || builtins.match "^\\..*\\.sw[a-z]$" baseName != null
            || # Otherwise it's good
            false
          );
          filteredNames = builtins.filter allowedName names;
        in
        builtins.listToAttrs (
          builtins.map
            (
              name: {
                name = builtins.replaceStrings [ ".nix" ] [ "" ] name;
                value = action (dir + ("/" + name));
              }
            )
            filteredNames
        );
      importDirectory = listDirectory import;
      pathDirectory = listDirectory (d: d);
      mkCallDirectory = callPkgs: listDirectory (p: callPkgs p { });

    in
    {
      lib = pkgsFor.x86_64-linux.lib;

      # Nix's flake support expects this to be an attrset, even though
      # it's not useful as an attrset downstream (e.g.,
      # `nixpkgs.overlays` expects to be passed a list of overlays,
      # not an attrset.)
      overlays = importDirectory ./nix/overlays // {
        "000-lib-sources" = final: prev: {
          lib = (prev.lib or { }) // {
            sources = (prev.lib.sources or { }) // {
              inherit listDirectory pathDirectory importDirectory mkCallDirectory;
            };
          };
        };

        "100-lib-flakes" = final: prev: {
          lib = (prev.lib or { }) // {
            flakes = (prev.lib.flakes or { }) // {
              inherit forAllSystems;
            };
          };
        };

        "000-hacknix-lib-flake" = final: prev: {
          lib = (prev.lib or { }) // {
            hacknix-lib = (prev.lib.hacknix-lib or { }) // {
              flake = (prev.lib.hacknix-lib.flake or { }) // {
                inherit inputs;
              };
            };
          };
        };
      };

      packages = forAllSupportedSystems
        (system:
          let
            pkgs = pkgsFor.${system};
          in
          {
            inherit (pkgs) ffdhe2048Pem ffdhe3072Pem ffdhe4096Pem;
          }
        );

      hydraJobs = {
        build = self.packages;

        tests =
          with import (nixpkgs + "/pkgs/top-level/release-lib.nix")
            {
              inherit supportedSystems;
              scrubJobs = true;
              nixpkgsArgs = {
                config = {
                  allowUnfree = false;
                  allowBroken = true;
                  inHydra = true;
                };
                overlays = overlaysAsList ++ [
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
          };

        nixosConfigurations =
          let
            extraModules = [
              {
                boot.isContainer = true;
              }
            ];
            mkSystem = self.lib.flakes.nixosSystem' extraModules;
            configs =
              self.lib.flakes.nixosConfigurations.importFromDirectory
                mkSystem
                ./test-configs/nixos
                {
                  inherit (self) lib;
                };
          in
          self.lib.flakes.nixosConfigurations.build configs;

        amazonImages =
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
                };
          in
          self.lib.flakes.nixosConfigurations.buildAmazonImages configs;

        isoImages =
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
                };
          in
          self.lib.flakes.nixosConfigurations.buildISOImages configs;


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
            configs =
              self.lib.flakes.darwinConfigurations.importFromDirectory
                mkSystem
                ./test-configs/nix-darwin
                {
                  inherit (self) lib;
                };
          in
          self.lib.flakes.darwinConfigurations.build configs;
      };
    };
}
