self: super:

let

  localLib = import ../../nix/default.nix;

in {
  lib = (super.lib or { }) // {
    customisation = (super.lib.customisation or { }) // {
      inherit (localLib) composeOverlays composeOverlaysFromFiles;
    };
  };
}
