{ pkgs ? import <nixpkgs> {} }:
let
  ghc = pkgs.haskellPackages.ghcWithHoogle
    ( hs : with hs;
        [ websockets ]
    );
in
pkgs.mkShell {
  buildInputs = [ ghc ];
}
