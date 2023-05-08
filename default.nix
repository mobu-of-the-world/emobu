{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/055a2f470bced98bb34a5d94b775c410e1594cc2.tar.gz") { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nil
    pkgs.nixpkgs-fmt
    pkgs.deno
  ];
}
