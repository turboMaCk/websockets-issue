{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs;
  [ haskellPackages.ghc
    haskellPackages.websockets
  ];
}
