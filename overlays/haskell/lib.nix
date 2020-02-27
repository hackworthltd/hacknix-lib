self: super:

let

  # A proper super.haskellPackage.extend that fixes
  # https://github.com/NixOS/nixpkgs/issues/26561.
  #
  # Note that f takes super: self: arguments, scoped within the
  # Haskell package set hp.

  properExtend = hp: f: hp.override (oldArgs: {
    overrides =
    super.lib.composeExtensions (oldArgs.overrides or (_: _: {}))
      f;
  });


  ## Sometimes you don't want any haddocks to be generated for an
  ## entire package set, rather than just a package here or there.
  noHaddocks = hp: (properExtend hp (self: super: (
    {
      mkDerivation = args: super.mkDerivation (args // {
        doHaddock = false;
      });
    }
  )));

in

{
  haskell = (super.haskell or {}) // {
    lib = (super.haskell.lib or {}) // {
      inherit noHaddocks;
      inherit properExtend;
    };
  };
}
