{ lib, stdenv, fetchFromGitHub, zlib, xz
, lz4
, lzo
, zstd
}:

stdenv.mkDerivation {
  pname = "squashfs";
  version = "4.4";

  src = fetchFromGitHub {
    owner = "plougher";
    repo = "squashfs-tools";
    sha256 = "0697fv8n6739mcyn57jclzwwbbqwpvjdfkv1qh9s56lvyqnplwaw";
    # Tag "4.4" points to this commit.
    rev = "52eb4c279cd283ed9802dd1ceb686560b22ffb67";
  };

  patches = [
    # This patch adds an option to pad filesystems (increasing size) in
    # exchange for better chunking / binary diff calculation.
    ./4k-align.patch
    # Add -no-hardlinks option. This is a rebased version of
    # c37bb4da4a5fa8c1cf114237ba364692dd522262, can be removed
    # when upgrading to the next version after 4.4
    ./0001-Mksquashfs-add-no-hardlinks-option.patch
  ] ++ lib.optional stdenv.isDarwin ./darwin.patch;

  buildInputs = [ zlib xz zstd lz4 lzo ];

  preBuild = "cd squashfs-tools";

  installFlags = [ "INSTALL_DIR=\${out}/bin" ];

  makeFlags = [ "XZ_SUPPORT=1" "ZSTD_SUPPORT=1" "LZ4_SUPPORT=1" "LZO_SUPPORT=1"];

  meta = {
    homepage = "http://squashfs.sourceforge.net/";
    description = "Tool for creating and unpacking squashfs filesystems";
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ruuda ];
  };
}
