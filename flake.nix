{
  inputs = {
    # Candidate channels
    #   - https://github.com/kachick/anylang-template/issues/17
    #   - https://discourse.nixos.org/t/differences-between-nix-channels/13998
    # How to update the revision
    #   - `nix flake update --commit-lock-file` # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-update.html
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = with pkgs;
          mkShell {
            buildInputs = [
              # https://github.com/NixOS/nix/issues/730#issuecomment-162323824
              bashInteractive

              nil
              nixpkgs-fmt
              dprint
              nodejs_20
              elmPackages.elm-json
              deno
              typos
            ];
          };

        apps = {
          bump-nix-dependencies = {
            type = "app";
            program = with pkgs; lib.getExe (writeShellApplication {
              name = "bump-nix-dependencies.bash";
              runtimeInputs = [ nix git nodejs_20 sd ];
              # Why --really-refresh?: https://stackoverflow.com/q/34807971
              text = ''
                set -x

                node --version | sd '^v?' "" > .node-version && git add .node-version
                git update-index -q --really-refresh
                git diff-index --quiet HEAD || git commit -m 'Sync .node-version with nixpkgs' .node-version
              '';
              meta = {
                description = "Bump dependency versions except managed by node package manager";
              };
            });
          };
        };
      }
    );
}
