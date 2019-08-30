let
  pkgs = import <nixpkgs> { };

in
  { typespeedImage = pkgs.callPackage ./docker.nix {};
  }
