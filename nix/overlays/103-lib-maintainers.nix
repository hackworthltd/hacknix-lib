self: super:
let
  dhess = "Drew Hess <dhess-src@hackworthltd.com>";
in
{
  lib = (super.lib or {}) // {
    maintainers = (super.lib.maintainers or {}) // {
      inherit dhess;
    };
  };
}
