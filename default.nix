{ mkDerivation, base, http-client, http-client-tls, lib
, modern-uri, parsec, postgresql-simple
, text
, pkgs
, callCabal2nix
, nodejs
, aeson
}:
let
  nix-thunk = pkgs.fetchFromGitHub {
    owner = "obsidiansystems";
    repo = "nix-thunk";
    rev = "8fe6f2de2579ea3f17df2127f6b9f49db1be189f";
    sha256 = "14l2k6wipam33696v3dr3chysxhqcy0j7hxfr10c0bxd1pxv7s8b";
  };
  n = import nix-thunk {};

  #gargoylePkgs = import ./deps/gargoyle { haskellPackages = pkgs.haskellPackages; postgresql = pkgs.postgresql; };
  # gargoyle = n.thunkSource "deps/gargoyle";
  # gargoyle-postgresql = n.thunkSource "deps/gargoyle-postgresql";
  # gargoyle-postgresql-connect = repos.gargoyle + "/gargoyle-postgresql-connect";
  # gargoyle-postgresql-nix = repos.gargoyle + "/gargoyle-postgresql-nix";
  
  scrappySrc = n.thunkSource ./deps/scrappy; 
  scrappy = pkgs.haskell.lib.overrideCabal (callCabal2nix "scrappy" scrappySrc {}) {
    librarySystemDepends = [ nodejs ];
  };


  my-network-uri = pkgs.haskell.lib.dontCheck (callCabal2nix "my-network-uri" (n.thunkSource ./deps/network-uri) {});
    
in

mkDerivation {
  pname = "email-spambot";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base http-client http-client-tls modern-uri my-network-uri parsec
    postgresql-simple scrappy text my-network-uri
    aeson
  ];
  license = lib.licenses.mit;
  mainProgram = "email-spambot";
}

# mkDerivation {
#   pname = "wikiScraper";
#   version = "0.1.0.0";
#   src = ./.;
#   isLibrary = true;
#   isExecutable = true;
#   libraryHaskellDepends = [
#     cryptohash
#     aeson base bytestring containers directory exceptions extra HTTP
#     http-client http-client-tls lens modern-uri mtl parsec random
#     scrappy
#     text time transformers uuid  witherable csv stm geckodriver# nodeDeps
#     postgresql-simple gargoylePkgs.gargoyle-postgresql postgresql uuid
#     aeson
#     #uri-encode
#     my-network-uri
#   ];
#   executableHaskellDepends = [
#     cryptohash
#     aeson base bytestring containers directory exceptions extra HTTP
#     http-client http-client-tls lens modern-uri mtl parsec random
#     scrappy
#     text time transformers uuid witherable csv stm geckodriver
#     postgresql-simple gargoylePkgs.gargoyle-postgresql postgresql uuid
#     aeson
#     #uri-encode
#     my-network-uri
#   ];
#   testHaskellDepends = [
#     cryptohash
#     nix-thunk 
#     aeson base bytestring containers directory exceptions extra HTTP
#     http-client http-client-tls lens modern-uri mtl parsec random
#     scrappy
#     text time transformers uuid csv stm geckodriver
#     postgresql-simple gargoylePkgs.gargoyle-postgresql postgresql uuid
#     aeson
#     uri-encode
#   ];
#   librarySystemDepends = [ postgresql ];
#   homepage = "TODO";
#   license = lib.licenses.bsd3;
# }
