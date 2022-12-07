with import <nixpkgs> { };

pkgs.mkShell {
  buildInputs = [
    nodejs-18_x
    yarn
  ];
}