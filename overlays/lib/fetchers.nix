self: super:
let
  localLibs = import ../../nix/default.nix;
in
{
  lib = (super.lib or {}) // {
    fetchers = (super.lib.fetchers or {}) // {
      inherit (localLibs) fixedNixSrc;
    };
  };
}
