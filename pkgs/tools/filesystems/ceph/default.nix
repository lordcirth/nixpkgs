{ callPackage, fetchgit, fetchpatch, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "14.2.0";

  src = fetchgit {
    url = "https://github.com/ceph/ceph.git";
    rev = "refs/tags/v${version}";
    sha256 = "1rrsahvhsdr5yfd4j3r5xjkq398zxs6j61sv1x561rdhz68lyfds";
  };

})
