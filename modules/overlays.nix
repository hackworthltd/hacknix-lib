{ ... }:

let

in
{
  nixpkgs.overlays = import ../overlays;
}
