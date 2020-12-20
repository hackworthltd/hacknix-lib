{
  description = "A library of useful Nix functions and types.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      overlaysAsList = map (name: self.overlays.${name}) (builtins.attrNames self.overlays);

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
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
      lib = nixpkgsFor.x86_64-linux.lib;

      # Nix's flake support expects this to be an attrset, even though
      # it's not useful as an attrset downstream (e.g.,
      # `nixpkgs.overlays` expects to be passed a list of overlays,
      # not an attrset.)
      overlays = importDirectory ./nix/overlays // {
        "000-lib-sources" = (final: prev: {
          lib = (prev.lib or { }) // {
            sources = (prev.lib.sources or { }) // {
              inherit listDirectory pathDirectory importDirectory mkCallDirectory;
            };
          };
        });
      };

      packages = forAllSystems
        (system:
          let
            pkgs = import nixpkgs
              {
                inherit system;
                config = {
                  allowUnfree = true;
                  allowBroken = true;
                };
                overlays = overlaysAsList;
              };
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
      };
    };
}
