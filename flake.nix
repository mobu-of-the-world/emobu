{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/f2406198ea0e4e37d4380d0e20336c575b8f8ef9";
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
              nil
              nixpkgs-fmt
              dprint
              nodejs_20
              typos

              # https://github.com/NixOS/nixpkgs/issues/215450#issuecomment-1526251592
              playwright
              playwright-driver.browsers
            ];

            shellHook = ''
              export PLAYWRIGHT_BROWSERS_PATH=${playwright-driver.browsers}
              export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
            '';
          };
      });
}
