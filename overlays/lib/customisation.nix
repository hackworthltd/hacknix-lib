self: super:

let

  localLib = import ../../lib;

in
{
  lib = (super.lib or {}) // {
    customisation = (super.lib.customisation or {}) // {
      inherit (localLib) composeOverlays composeOverlaysFromFiles;
    };
  };
}
