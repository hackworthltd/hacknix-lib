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
      overlay = import overlays/default.nix;
    in
    {
      inherit overlay;

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
                overlays = [ self.overlay ];
              };
          in
          {
            inherit (pkgs) ffdhe2048Pem ffdhe3072Pem ffdhe4096Pem;
          }
        );

      hydraJobs = {
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
                overlays = [
                  overlay
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
