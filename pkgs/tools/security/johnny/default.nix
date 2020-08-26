{ stdenv, fetchFromGitHub, qt5 }:
with stdenv.lib;

stdenv.mkDerivation rec {
  pname   = "johnny";
  version = "v2.2";

  src = fetchFromGitHub {
    owner   = "openwall";
    repo    = "johnny";
    rev     = version;
    sha256  = "sha256-fwRvyQbRO63iVt9AHlfl+Cv4NRFQmyVsZUQLxmzGjAY=";
  };

  buildInputs = [ qt5.qmake ];

  buildPhase = ''
    qmake && make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp johnny $out/bin
  '';
}
