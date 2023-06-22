![](.assets/newbanner.png)

[![](https://img.shields.io/badge/docs-Econia-59f)](https://www.econia.dev)
[![](https://img.shields.io/badge/docs-Move-59f)](src/move/econia/doc)
[![](https://img.shields.io/discord/988942344776736830?style=flat)](discord.gg/econia)
[![](https://img.shields.io/badge/license-Business_Source_License-white.svg)](LICENSE.md)

# Econia

Foo

**e·co·ni·a** | /ə'känēə/

*Hyper-parallelized on-chain order book for the Aptos blockchain*

- [Econia](#econia)
  - [Developing Econia](#developing-econia)
    - [Shell scripts](#shell-scripts)
    - [Environment setup](#environment-setup)
    - [Freeing up disk space](#freeing-up-disk-space)
  - [Key filetypes for Econia developers](#key-filetypes-for-econia-developers)
    - [Move](#move)
    - [Markdown](#markdown)
    - [Python](#python)

If you haven't already, consider checking out Econia Labs' [Teach yourself Move on Aptos] guide for some helpful background information!

## Developing Econia

### Shell scripts

The easiest way to develop Econia is with the provided `zsh` shell scripts at [`scripts.sh`], and the fastest way to run these scripts is by adding the following function to your runtime configuration file (`~/.zshrc`):

```bash
# Pass all commands to scripts.sh file.
s() {source scripts.sh "$@"}
```

Now you will be able to run the provided [`scripts.sh`] commands simply by typing `s`.

```bash
git clone https://github.com/econia-exchange/econia.git
cd econia
s hello
Hello, Econia developer
```

See [`scripts.sh`] for more commands.

### Environment setup

1. Run the `init` command for [`scripts.sh`]:

   ```bash
   # You should see output like this if you have already initialized.
   s init
   Initializing developer environment
   brew already installed
   aptos already installed
   entr already installed
   poetry already installed
   shfmt already installed
   Installing Python package
   Installing dependencies from lock file

   No dependencies to install or update

   Installing the current project: econia (1.0.0)
   ```

1. Now you should be able to run all Move tests:

   ```bash
   # Run all Move tests.
   s tm
   INCLUDING DEPENDENCY AptosFramework
   INCLUDING DEPENDENCY AptosStdlib
   INCLUDING DEPENDENCY MoveStdlib
   BUILDING Econia
   Running Move unit tests
   [ PASS    ] 0x0::tablist::test_destroy_empty_not_empty
   [ PASS    ] 0x0::tablist::test_iterate
   ...
   ```

### Freeing up disk space

Installing all of the dependencies necessary to develop Econia can quickly take up disk space.
To clean up cache files and intermediate artifacts, consider the following tools:

- [`kondo`]
- [`cargo cache`]
- [`detox`]

In particular, if using a Mac [local Time Machine snapshots] of intermediate artifacts may lead to excessive "purgable" disk space should substantial time pass between backups.
It is possible to disable snapshots as mentioned in the support thread, but backing up to Time Machine should also help purge snapshots of intermediate artifacts, once the above tools are invoked.

Also consider deleting `~/.move` from time to time.

## Key filetypes for Econia developers

### Move

Move source code is at [`src/move/econia`].
In the absence of a formal style guide, Move code is formatted similarly to PEP8-style Python code.
Auto-generated module documentation files are at [`src/move/econia/doc`].

### Markdown

Markdown files have a line break for each new sentence to make diff tracking easier.
Documentation markdown source files are at [`doc/doc-site/docs`].

### Python

Econia comes with a Python package at [`src/python/build_scripts`], used for assorted build scripting functionality.
Most Python commands are called on by [`scripts.sh`] commands, with dependencies managed by [Poetry].

[local time machine snapshots]: https://discussions.apple.com/thread/7676695
[poetry]: https://python-poetry.org/
[teach yourself move on aptos]: https://github.com/econia-labs/teach-yourself-move
[`cargo cache`]: https://github.com/matthiaskrgr/cargo-cache
[`detox`]: https://github.com/whitfin/detox
[`doc/doc-site/docs`]: doc/doc-site/docs
[`kondo`]: https://github.com/tbillington/kondo
[`scripts.sh`]: scripts.sh
[`src/move/econia/doc`]: src/move/econia/doc
[`src/move/econia`]: src/move/econia
[`src/python/build_scripts`]: src/python/build_scripts
