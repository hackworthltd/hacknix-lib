final: prev:
let
  getEnvNonEmpty = name:
    let
      value = builtins.getEnv name;
    in
    assert prev.lib.assertMsg (value != "")
      "environment.getEnvNonEmpty: environment variable ${name} is not set or has empty value";
    value;
in
{
  lib = (prev.lib or { }) // {
    environment = (prev.lib.environment or { }) // {
      inherit getEnvNonEmpty;
    };
  };
}
