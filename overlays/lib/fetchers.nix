self: super:

let

  localLibs = import ../../lib;

in
{
  lib = (super.lib or {}) // {
    fetchers = (super.lib.fetchers or {}) // {
      inherit (localLibs) fixedNixSrc fixedNixpkgs;
    };
  };
}
