let
  inherit (import <nixpkgs> {}) fetchFromGitHub;
  nixpkgs = fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs-channels";
    rev    = "9e44b46bab02ae739a50d5edc38d0d338f402f46";
    sha256 = "08g4ac40gajgxgpjv9kvlrmmhhgq6fhfzj0d7781jnr1n6ij040g";
  };
  pkgs = import nixpkgs {};
in pkgs.runCommand "dummy" {
  buildInputs = [ pkgs.elmPackages.elm ];
} ""
