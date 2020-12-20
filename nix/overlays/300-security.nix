final: prev:
let
  ## PEM files corresponding to the pre-configured RFC 7919 DH groups
  ## defined in our lib.security overlay.

  ffdhe2048Pem = prev.writeText "ffdhe2048.pem" prev.lib.security.ffdhe2048;
  ffdhe3072Pem = prev.writeText "ffdhe3072.pem" prev.lib.security.ffdhe3072;
  ffdhe4096Pem = prev.writeText "ffdhe4096.pem" prev.lib.security.ffdhe4096;
in
{
  inherit ffdhe2048Pem ffdhe3072Pem ffdhe4096Pem;
}
