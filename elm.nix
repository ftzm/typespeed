let
  inherit (import <nixpkgs> {}) fetchFromGitHub;
  # Very old nixpkgs with elm 0.18
  nixpkgs = fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs-channels";
    rev    = "9e44b46bab02ae739a50d5edc38d0d338f402f46";
    sha256 = "08g4ac40gajgxgpjv9kvlrmmhhgq6fhfzj0d7781jnr1n6ij040g";
  };
  pkgs = import nixpkgs {};
in with pkgs;
stdenv.mkDerivation {
  name = "typespeed";
  phases = "";
  buildInputs = [ pkgs.elmPackages.elm ];
}
