## Convenience functions for tests, esp. for Hydras.

self: super:

let

in
{
  lib = (super.lib or {}) // {
    testing = (super.lib.testing or {}) // {
      enumerateSystems = pkg: systems: map (system: pkg.${system}) systems;
    };
  };
}
