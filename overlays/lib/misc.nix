self: super:

let

  shortRev = builtins.substring 0 7;

in
{
  lib = (super.lib or {}) // {
    misc = (super.lib.misc or {}) // {
      inherit shortRev;
    };
  };
}
