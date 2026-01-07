{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    lib = nixpkgs.lib;
    eachSystem = lib.genAttrs systems;
  in {
    packages = eachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      icon-pkg = pkgs.fetchgit {
        url = "https://github.com/twbs/icons.git";
        hash = "sha256-zYTTy3w7qW39kpwpqW59ZDBCgZEq+8djvobhz+ABwzA=";
        sparseCheckout = [
          "icons/person-arms-up.svg"
        ];
      };
    in {
      default = pkgs.stdenv.mkDerivation {
        name = "faux-business-card";
        src = ./.;
        buildPhase = ''
          mkdir -p $out/share
          cp ${icon-pkg}/icons/person-arms-up.svg .
          ${pkgs.typst}/bin/typst compile business-card.typ \
            $out/share/business-card.pdf
        '';
      };
    });

    devShells = eachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = [
          pkgs.typst
        ];
      };
    });
  };
}
