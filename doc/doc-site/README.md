# Econia Docs

Econia's docs are built using [Docusaurus].

## Building locally

1. Install [Homebrew] or a similar package manager.

1. Install [pnpm]:

   ```zsh
   brew install pnpm
   ```

1. Install the docs site package dependencies:

   ```zsh
   pnpm install
   ```

1. To serve a local site preview:

   ```zsh
   pnpm start
   ```

1. Open http://localhost:3000

## Updating API docs

With data service stack running per `/src/docker/README.md`, run in this directory:

```sh
curl localhost:3000 > openapi.json
```

[docusaurus]: https://docusaurus.io/
[homebrew]: https://brew.sh
[pnpm]: https://pnpm.io/
