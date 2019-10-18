{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "ipfs-cluster";
  version = "0.11.0";
  rev = "v${version}";

  src = fetchFromGitHub {
    owner = "ipfs";
    repo = "ipfs-cluster";
    inherit rev;
    sha256 = "0q5lanm2zdwwhdwv05fssb34y4y4dha3dq7x1iaabbf70lpqv6yx";
  };

  modSha256 = "1riz5wmd7b88dklma95dgy1jirdq56db7i3916vvkd5456raw7xi";

  meta = with stdenv.lib; {
    description = "Allocate, replicate, and track Pins across a cluster of IPFS daemons";
    homepage = https://cluster.ipfs.io/;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ jglukasik ];
  };
}

