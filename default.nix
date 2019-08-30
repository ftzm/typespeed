{ pkgs ? import <nixpkgs> {}, version ? "latest"}:

let
  inherit (import <nixpkgs> { }) fetchFromGitHub;
  # ----------------------------------------------------------------------
  # Import stable nixpkgs as buildImage was broken on unstable
  # at time of writing.
  nixpkgs_19_03 = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "2516c454c35344d551420fb74541371c6bfcc5e9";
    sha256 = "1fsxwd3x5ag1ihgprrlgk06s5ja7rkk5a5s04qmrp32784iylkpn";
  };
  pkgs_19_03 = import nixpkgs_19_03 { };
  # ----------------------------------------------------------------------
  nginxPort = "80";
in rec {
  nginxWebRoot = pkgs.stdenv.mkDerivation {
    name = "typespeed-files";
    src = ./.;
    phases = "installPhase";
    installPhase = ''
      mkdir $out
      cp $src/main.html $out/main.html
      cp $src/out/main.js $out/main.js
      cp $src/style.css $out/style.css
      cp $src/texts.json $out/texts.json
    '';
  };
  nginxConf = pkgs.writeText "nginx.conf" ''
          user nginx nginx;
          daemon off;
          error_log /dev/stdout info;
          pid /dev/null;
          events {}
          http {
            include    ${pkgs.nginx}/conf/mime.types;
            access_log /dev/stdout;
            root ${nginxWebRoot};
            server {
              listen ${nginxPort};
    	        location ~ \.css {
    	            add_header  Content-Type    text/css;
    	        }
    	        location ~ \.js {
    	            add_header  Content-Type    application/x-javascript;
    	        }
              location / {
                index main.html;
              }
            }
          }
      '';
  image = pkgs_19_03.dockerTools.buildImage {
    name = "ftzm/typespeed";
    tag = version;
    contents = pkgs.nginx;

    runAsRoot = ''
      #!${pkgs.stdenv.shell}
      ${pkgs.dockerTools.shadowSetup}
      groupadd --system nginx
      useradd --system --gid nginx nginx
    '';

    config = {
      Cmd = [ "nginx" "-c" nginxConf ];
      ExposedPorts = { "${nginxPort}/tcp" = { }; };
    };
  };
}
