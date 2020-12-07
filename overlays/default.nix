final: prev:
let
  composeOverlays = overlays: pkgSet: with prev;
    let
      toFix = lib.foldl' (lib.flip lib.extends) (lib.const pkgSet) overlays;
    in
    lib.fix toFix;

  composeOverlaysFromFiles = overlaysFiles: pkgSet:
    composeOverlays (map import overlaysFiles) pkgSet;

  overlays = [
    ./lib/attrsets.nix
    ./lib/dns.nix
    ./lib/ipaddr.nix
    ./lib/maintainers.nix
    ./lib/hacknix-lib.nix
    ./lib/environment.nix
    ./lib/misc.nix
    ./lib/operators.nix
    ./lib/secrets.nix
    ./lib/security.nix
    ./lib/ssh.nix
    ./lib/sources.nix
    ./lib/types.nix
    ./haskell/lib.nix
    ./pkgs/build-support
    ./pkgs/emacs
    ./pkgs/security
  ];
in
composeOverlaysFromFiles overlays prev
