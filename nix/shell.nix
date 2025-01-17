let nixos = fetchTarball { url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/21.05.tar.gz"; 
                           sha256 = "sha256:1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
}; in

{ compiler ? "ghc8104"
, tutorial ? false
, pkgs ? import nixos { config = {}; }
}:
  
  with pkgs;

  let
    ghc = haskell.packages.${compiler}.ghcWithPackages (_: []);
    docstuffs = python3.withPackages (ps: with ps; [ recommonmark sphinx sphinx_rtd_theme ]);
  in
  stdenv.mkDerivation {
      name = "servant-dev";
      buildInputs = [ ghc zlib python3 wget cabal-install postgresql openssl stack haskellPackages.hspec-discover ]
        ++ (if tutorial then [docstuffs postgresql] else []);
      shellHook = ''
        eval $(grep export ${ghc}/bin/ghc)
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"${zlib}/lib";
      '';
  }
