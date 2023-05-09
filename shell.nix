with import <nixpkgs> { };

pkgs.mkShell {
  buildInputs = [
    nodejs-14_x
    yarn
    pkg-config
    rustc
    cargo
    rustfmt
    llvmPackages_12.llvm
    llvmPackages_12.clang
    openssl_1_1
  ] ++ (
    lib.optional stdenv.isDarwin([ libiconv ]
      ++ (with darwin.apple_sdk.frameworks; [ SystemConfiguration ])
    )
  );
  LD_LIBRARY_PATH = "${lib.getLib openssl_1_1}/lib";
}