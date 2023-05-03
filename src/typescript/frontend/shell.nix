with import <nixpkgs> { };

pkgs.mkShell {
  buildInputs = [
    nodejs-18_x
    nodePackages.pnpm
  ];

  shellHook = ''
    alias pd='pnpm dev'
    alias pb='pnpm build'
  '';
}