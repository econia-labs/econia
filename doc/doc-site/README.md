# Econia Docs

Econia's docs are built using [Docusaurus], and are served through [Cloudflare Pages] via the following build configurations:

| Config                              | Value           |
| ----------------------------------- | --------------- |
| Build command                       | `yarn build`    |
| Build output directory              | `/build`        |
| Root directory                      | `/doc/doc-site` |
| Environment variable `NODE_VERSION` | 16              |

## Building locally

1. Install [Homebrew] or a similar package manager.

1. Install [Yarn]:

   ```zsh

   brew install yarn

   ```

1. Install the docs site package dependencies:

   ```zsh

   yarn

   ```

1. To build locally:

   ```zsh

   yarn build

   ```

1. To serve a local site preview:

   ```zsh

   yarn start

   ```

1. Open http://localhost:3000

<!---Alphabetized reference links-->

[cloudflare pages]: https://pages.cloudflare.com/
[docusaurus]: https://docusaurus.io/
[homebrew]: https://brew.sh
[yarn]: https://yarnpkg.com/
