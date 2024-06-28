![](.assets/newbanner.png)

[![](https://img.shields.io/badge/docs-Econia-59f)](https://www.econia.dev)
[![](https://img.shields.io/badge/docs-Move-59f)](src/move/econia/doc)
[![](https://img.shields.io/discord/988942344776736830?style=flat)](discord.gg/econia)
[![](https://img.shields.io/badge/license-Business_Source_License-white.svg)](LICENSE.md)

# Econia

**e·co·ni·a** | /ə'känēə/

*Hyper-parallelized on-chain order book for the Aptos blockchain*

If you haven't already, consider checking out Econia Labs' [Teach yourself Move on Aptos] guide for some helpful background information, then see the official [Econia docs]!

## Select filetype notes

### Move

Move source code is at [`src/move/econia`].

Auto-generated module documentation files are at [`src/move/econia/doc`].

> When Econia development began, the initial developer of the Econia v4 protocol had not yet programmed in Rust (Move is implemented in Rust).
> Hence, in the absence of a formal style guide, Move code was formatted according to the opinionated PEP8 Python style guide.
> For future projects it is suggested that Move be formatted according to Rust guidelines, or ideally per a Move linter, and that format be consistent *within* a single codebase.

### Markdown

Markdown files have a line break for each new sentence to make diff tracking easier.
Documentation markdown source files are at [`doc/doc-site/docs`].
New markdown files should be formatted via [mdformat].

### Python

Econia comes with a Python package at [`src/python/build_scripts`], used for assorted developer scripting functionality, with dependencies managed by [Poetry].
Most Python developer script commands are called on by [`scripts.sh`], which is not actively maintained but may still be useful for aspiring Econia developers.

[econia docs]: https://econia.dev/
[mdformat]: https://pypi.org/project/mdformat/0.5.1/
[poetry]: https://python-poetry.org/
[teach yourself move on aptos]: https://github.com/econia-labs/teach-yourself-move
[`doc/doc-site/docs`]: doc/doc-site/docs
[`scripts.sh`]: scripts.sh
[`src/move/econia/doc`]: src/move/econia/doc
[`src/move/econia`]: src/move/econia
[`src/python/build_scripts`]: src/python/build_scripts
