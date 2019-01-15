{ pkgs ? import <nixpkgs> {} }:
let
  ghc =
    pkgs.haskellPackages.ghcWithHoogle
      ( hs:
        with hs;
        [ websockets
          servant
          servant-server
          servant-websockets
          wai
          warp
        ]
      );
in
pkgs.mkShell {
  buildInputs = [ ghc ];
}
