let
  localLib = import nix/default.nix;
  localPkgs = (import ./default.nix) {};
in
{ supportedSystems ? [ "x86_64-linux" "x86_64-darwin" ]
, scrubJobs ? true
, nixpkgsArgs ? {
    config = {
      allowUnfree = false;
      inHydra = true;
    };
    overlays = [ localPkgs.overlays.all (import ./tests) ];
  }
}:

with import (localLib.fixedNixpkgs + "/pkgs/top-level/release-lib.nix") {
  inherit supportedSystems scrubJobs nixpkgsArgs;
};
let
  jobs = mapTestOn {
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
in
jobs
