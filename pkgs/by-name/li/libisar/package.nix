{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  buildPackages,
  pkg-config,
}:
let
  arch = stdenv.hostPlatform.parsed.cpu.name;
  triplet = lib.getAttr arch {
    "x86_64" = "x86_64-unknown-linux-gnu";
    "aarch64" = "aarch64-unknown-linux-gnu";
  };

  libmdbx = fetchFromGitHub {
    owner = "isar-community";
    repo = "libmdbx";
    tag = "v0.13.8-temp-upstream-fix";
    hash = "sha256-Ndsr6o4sAWGdOHZ7GcT8Jjm6f+N7hgxbLRTv/TUflAY=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "libisar";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "isar-community";
    repo = "isar-community";
    tag = finalAttrs.version;
    hash = "sha256-r7KfTfTKN27+t2cPOXSBnx5nkCjDMJMT03oXKn8837Y=";
  };

  cargoHash = "sha256-mxcr4nIeS3dIUpmi7OViCAqmE0NjcFH9p+yGTHFKRDM=";

  cargoPatches = [
    ./0001-add-cargo-lock.patch
    ./0002-use-vendored-libmdbx.patch
  ];

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  preBuild = ''
    export LIBMDBX_DIR=$(mktemp -d)
    cp -r ${libmdbx}/* $LIBMDBX_DIR
    chmod -R +w $LIBMDBX_DIR
  '';

  meta = {
    description = "Extremely fast, easy to use, and fully async NoSQL database for Flutter";
    homepage = "https://github.com/isar-community/isar-community";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ azban ];
    platforms = lib.platforms.linux;
  };
})
