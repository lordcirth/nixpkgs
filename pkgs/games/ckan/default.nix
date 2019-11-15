{ stdenv, fetchFromGitHub, fetchNuGet, fetchurl, makeWrapper, perl, mono, gtk2, curl, unzip }:

let
  nugetVersion = "5.0.2";
  # From packages.config in source
  cakeVersion  = "0.34.1";
in
stdenv.mkDerivation rec {
  pname = "ckan";
  version = "1.26.4";

  src = fetchFromGitHub {
    owner = "KSP-CKAN";
    repo = "CKAN";
    rev = "v${version}";
    sha256 = "0ir6dc4z40mpbzk4zih5vf0i9ibn9k0qxy03jdvf80j6zyfwd8z5";
  };

  nuget = fetchurl {
    url = "https://dist.nuget.org/win-x86-commandline/v${nugetVersion}/nuget.exe";
    sha256 = "16svcf7z04ylmrxz1ayaxmdpbsghs58xgkpzwz1rh4a46vkych9y";
  };

  # fetchNuGet doesn't keep dll's?
  cake = fetchurl {
    url = "https://www.nuget.org/api/v2/package/Cake/${cakeVersion}";
    sha256 = "0v3j72h1gw81ys6lak6bqxk7wn2ik4x2jd3kr2krr1pdpyp7b2pp";
  };

  buildInputs = [ makeWrapper perl mono unzip ];

  # Tests don't currently work, as they try to write into /var/empty.
  doCheck = false;
  checkTarget = "test";

  libraries = stdenv.lib.makeLibraryPath [ gtk2 curl ];

  buildPhase = ''
    libDir="_build/lib/nuget"
    nugetDir="_build/tools/NuGet/${nugetVersion}"

    mkdir -p $libDir $nugetDir

    cp ${nuget} $nugetDir/nuget.exe
    unzip ${cake} -d $libDir/Cake.${cakeVersion}

    ./build
  '';

  installPhase = ''
    mkdir -p $out/bin
    for exe in *.exe; do
      install -m 0644 $exe $out/bin
      makeWrapper ${mono}/bin/mono $out/bin/$(basename $exe .exe) \
        --add-flags $out/bin/$exe \
        --set LD_LIBRARY_PATH $libraries
    done
  '';

  meta = {
    description = "Mod manager for Kerbal Space Program";
    homepage = https://github.com/KSP-CKAN/CKAN;
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.Baughn ];
    platforms = stdenv.lib.platforms.all;
  };    
}
