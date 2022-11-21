![](.assets/cover-banner-blue.png)

[![Discord chat](https://img.shields.io/badge/docs-Econia-59f)](https://www.econia.dev)
[![Econia move documentation (move)](https://img.shields.io/badge/docs-Move-59f)](src/move/econia/build/Econia/docs)
[![Discord chat](https://img.shields.io/discord/988942344776736830?style=flat)](https://discord.gg/Z7gXcMgX8A)
[![License](https://img.shields.io/badge/license-Business_Source_License-white.svg)](LICENSE.md)

# Econia

**e·co·ni·a** | /ə'känēə/

*Hyper-parallelized on-chain order book for the Aptos blockchain*

- [Econia](#econia)
  - [Developer setup](#developer-setup)
    - [Shell scripts](#shell-scripts)
    - [Command line setup](#command-line-setup)
    - [Using the Python package](#using-the-python-package)
    - [Freeing up disk space](#freeing-up-disk-space)
  - [Major filetypes](#major-filetypes)
    - [Jupyter](#jupyter)
    - [Markdown](#markdown)
    - [Move](#move)
    - [Python](#python)

If you haven't already, consider checking out Econia Labs' [Teach yourself Move on Aptos] guide for some helpful background information!

## Developer setup

### Shell scripts

The easiest way to develop Econia is with the provided shell scripts, and the fastest way to run these scripts is by adding the following function to your runtime configuration file (`~/.zshrc`, `~/.bash_profile`, etc):

```zsh
# Shell script wrapper: pass all arguments to ./ss.sh
s() {source ss.sh "$@"}
```

Now you will be able to run the provided `ss.sh` shell script file in whatever directory you are in by simply typing `s`:

```
% git clone https://github.com/econia-exchange/econia.git
% cd econia
% s hello
Hello, Econia developer
```

See `ss.sh` within a given directory for its available options.

### Command line setup

1. First follow the [official Aptos developer setup guide].

1. Then [install the `aptos` CLI].

    * Note that this will go faster if [adding a precompiled binary] to `~/.cargo/bin` rather than installing via `cargo`.
    * If the precompiled binary has not been released yet, additionally consider installing from Git, a method that does not always require rebuilding intermediate artifacts (see same resource for instructions, noting that building from binary can take up plenty of disk space inside of the `aptos-core` directory).


1. Now you should be able to run all Move tests:

    ```zsh
    # From inside Econia repository root directory
    cd src/move/econia # Navigate to Move package
    aptos move test -i 1000000 # Run all tests
    INCLUDING DEPENDENCY AptosFramework
    INCLUDING DEPENDENCY MoveNursery
    INCLUDING DEPENDENCY MoveStdlib
    BUILDING Econia
    Running Move unit tests
    ...
    ```
1. Then try building the Move documentation:

    ```zsh
    # Still within Move package
    aptos move document
    INCLUDING DEPENDENCY AptosFramework
    INCLUDING DEPENDENCY MoveNursery
    INCLUDING DEPENDENCY MoveStdlib
    BUILDING Econia
    ```

### Using the Python package

Econia comes with a Python package for assorted build scripting functionality.
The Python package is not as actively maintained as the Move code, and is mostly used for managing account addresses in `Move.toml` during package compilation (see [`src/move/econia/ss.sh`]).
Econia uses `conda` (a command line tool for managing Python environments), the `econia` conda environment, and the Econia Python package within the `econia` conda environment.
It is not necessary to use the Python package to develop Econia, but not all of the shell scripts will work without it.
To install the `econia` Python package:

1. First install Homebrew:

    ```zsh
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

1. Then `brew install` Miniconda:

    ```zsh
    brew install miniconda # Python package management
    ```

1. Create the `econia` conda environment with the `Econia` Python package inside:

    ```zsh
    # From inside Econia project root
    conda env create -f conda.yml
    conda activate econia
    pip install -e src/python
    ```

1. Then [install the Aptos Python SDK from source] with the `econia` conda environment still active.

1. Create the secrets directories as needed:

    ```zsh
    # From inside Econia project root
    if ! test -d .secrets; then mkdir .secrets; fi
    if ! test -d .secrets/devnet; then mkdir .secrets/old; fi
    if ! test -d .secrets/old; then mkdir .secrets/old; fi
    if ! test -d .secrets/vanity; then mkdir .secrets/devnet; fi
    ```

If using VS Code, select `econia` as the default Python interpreter, and the integrated terminal should automatically activate it as needed, otherwise use the command line:

```zsh
# To activate
(base) % conda activate econia
# To deactivate
(econia) econia % conda deactivate
```

With the `econia` conda environment active, you can then build the Python package documentation, explore the provided interactive Jupyter notebook archive, and run package management shell scripts:

```zsh
# From inside Econia project root
# Autobuild Sphinx documentation with realtime updates
(econia) % s ab
```

```zsh
# From inside Econia project root
# Open Jupyter notebook gallery
# Earliest notebooks subject to breaking changes
(econia) % s nb
```

```zsh
# From inside Jupyter notebook gallery
# Go back up to the Econia project root
(econia) % cd ../..
# Change directory to the Econia Move package
(econia) % s mp
# Move package has its own utility shell scripts
(econia) % s pt # Publish bytecode to temporary devnet address
```

### Freeing up disk space

Installing all of the dependencies necessary to develop Econia can quickly take up disk space.
To clean up cache files and intermediate artifacts, consider the following tools:

* [`kondo`]
* [`cargo cache`]
* [`detox`]

In particular, if using a Mac [local Time Machine snapshots] of intermediate artifacts may lead to excessive "purgable" disk space should substantial time pass between backups.
It is possible to disable snapshots as mentioned in the support thread, but backing up to Time Machine should also help purge snapshots of intermediate artifacts, once the above tools are invoked.

Also consider deleting `~/.move` from time to time.

## Major filetypes

### Jupyter

Interactive Jupyter notebook examples are at [`src/jupyter`], listed in increasing order of creation number.
The earliest notebooks are subject to breaking changes at the most recent commit, but they have been archived so as to be functional at the commit when they where finalized.
Hence, older commits can be checked out and experimented with, but mostly they are useful for harvesting old code patterns.

### Markdown

Markdown files have a line break for each new sentence to make diff tracking easier.
GitBook markdown source files are at [`doc/doc-site/`].

### Move

Move source code is at [`src/move/econia`].
In the absence of a formal style guide, Move code is formatted similarly to PEP8-style Python code.
Auto-generated module documentation files are at [`src/move/econia/build/Econia/docs`].

### Python

The Econia Python package source code is at [`src/python/econia`].
Python source is formatted according to the PEP8 style guide, and uses NumPy-style docstrings and PEP484-style type annotations, which are automatically parsed into a documentation website via Sphinx.
Sphinx documentation source files are at [`doc/sphinx`].

<!---Alphabetized reference links-->

[`aptos-core` #2142]:                       https://github.com/aptos-labs/aptos-core/issues/2142
[`cargo cache`]:                            https://github.com/matthiaskrgr/cargo-cache
[`detox`]:                                  https://github.com/whitfin/detox
[`doc/doc-site/`]:                          doc/doc-site/
[`doc/sphinx`]:                             doc/sphinx
[`kondo`]:                                  https://github.com/tbillington/kondo
[`src/jupyter`]:                            src/jupyter
[`src/move/econia`]:                        src/move/econia
[`src/move/econia/build/Econia/docs`]:      src/move/econia/build/Econia/docs
[`src/move/econia/ss.sh`]:                  src/move/econia/ss.sh
[`src/python/econia`]:                      src/python/econia
[adding a precompiled binary]:              https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli#install-precompiled-binary-easy-mode
[install the `aptos` CLI]:                  https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli
[install the Aptos Python SDK from source]: https://aptos.dev/sdks/python-sdk#install-from-the-source
[local Time Machine snapshots]:             https://discussions.apple.com/thread/7676695
[official Aptos developer setup guide]:     https://aptos.dev/guides/getting-started
[Teach yourself Move on Aptos]:             https://github.com/econia-labs/teach-yourself-move