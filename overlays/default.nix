self: super:

let

  localLib = import ../lib;
  overlays = [
    ./lib/attrsets.nix
    ./lib/customisation.nix
    ./lib/dns.nix
    ./lib/fetchers.nix
    ./lib/ipaddr.nix
    ./lib/maintainers.nix
    ./lib/hacknix.nix
    ./lib/environment.nix
    ./lib/misc.nix
    ./lib/operators.nix
    ./lib/secrets.nix
    ./lib/security.nix
    ./lib/ssh.nix
    ./lib/sources.nix
    ./lib/testing.nix
    ./lib/types.nix
    ./haskell/lib.nix
    ./pkgs/build-support
    ./pkgs/emacs
    ./pkgs/security
    ./pkgs/hacknix-lib-source
  ];

in
localLib.composeOverlaysFromFiles overlays super
