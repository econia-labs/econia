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

[docusaurus]: https://docusaurus.io/
[homebrew]: https://brew.sh
[pnpm]: https://pnpm.io/

## Updating API docs

1. Make your changes to the database migrations.
2. Run the local end-to-end docker compose according to instructions in `/src/docker/README.md`
3. Visit `localhost:3000` and copy the JSON it returns.
4. Paste the JSON into `/doc/doc-site/openapi.json`
5. Done!