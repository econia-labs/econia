with import <nixpkgs> { };

pkgs.mkShell {
  buildInputs = [
    nodejs-18_x
    nodePackages.pnpm
  ];

  shellHook = ''
    alias pd='pnpm run dev'
    alias pb='pnpm run build'
    alias pl='pnpm run lint'
  '';
}