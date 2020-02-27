self: super:

let

  packageSource = name: version: srcPath: super.callPackage ./package-source.nix {
    inherit name version srcPath;
  };

in
{
  inherit packageSource;
}
