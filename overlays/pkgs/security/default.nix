self: super:

let

  ## PEM files corresponding to the pre-configured RFC 7919 DH groups
  ## defined in our lib.security overlay.

  ffdhe2048Pem = super.writeText "ffdhe2048.pem" super.lib.security.ffdhe2048;
  ffdhe3072Pem = super.writeText "ffdhe3072.pem" super.lib.security.ffdhe3072;
  ffdhe4096Pem = super.writeText "ffdhe4096.pem" super.lib.security.ffdhe4096;

in
{
  inherit ffdhe2048Pem ffdhe3072Pem ffdhe4096Pem;
}
