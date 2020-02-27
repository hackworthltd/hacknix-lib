self: super:

let

  exclusiveOr = x: y: (x && !y) || (!x && y);

in
{
  lib = (super.lib or {}) // {
    inherit exclusiveOr;
    trivial = (super.lib.trivial or {}) // {
      inherit exclusiveOr;
    };
  };
}
