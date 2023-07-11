{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f2406198ea0e4e37d4380d0e20336c575b8f8ef9.tar.gz") { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nil
    pkgs.nixpkgs-fmt
    pkgs.nodejs-19_x
    pkgs.dprint
  ];
}
