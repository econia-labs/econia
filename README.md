![](.assets/cover-banner.png)

[![Discord chat](https://img.shields.io/badge/docs-Econia-59f)](https://www.econia.dev)
[![Econia move documentation (move)](https://img.shields.io/badge/docs-Move-59f)](src/move/econia/build/Econia/docs)
[![Discord chat](https://img.shields.io/discord/988942344776736830?style=flat)](https://discord.gg/Z7gXcMgX8A)
[![License](https://img.shields.io/badge/license-Apache_2.0-white.svg)](LICENSE.md)


# Econia

**e·co·ni·a** | /ə'känēə/

*Hyper-parallelized on-chain order book for the Aptos blockchain*

- [Econia](#econia)
  - [Developer setup](#developer-setup)
    - [Shell scripts](#shell-scripts)
    - [Command line setup](#command-line-setup)
    - [Using the Python package](#using-the-python-package)
  - [Major filetypes](#major-filetypes)
    - [Jupyter](#jupyter)
    - [Markdown](#markdown)
    - [Move](#move)
    - [Python](#python)

## Developer setup

### Shell scripts

The easiest way to develop Econia is with the provided shell scripts, and the fastest way to run these scripts is by adding the following function to your runtime configuration file (`~/.zshrc`, `~/.bash_profile`, etc):

```zsh
# Shell script wrapper: pass all commands to ./ss.sh
s() {source ss.sh "$@"}
```

Now you will be able to run the provided `ss.sh` shell script file in whatever directory you are in by simply typing `s`:

```
% git clone https://github.com/econia-exchange/econia.git
% cd econia
% s hello
Hello, Econia developer
```

See `ss.sh` within a given directory for its available options

### Command line setup

1. First install the `aptos` CLI:

    ```zsh
    cargo install --git https://github.com/aptos-labs/aptos-core.git aptos
    ```

1. Now you should be able to run all Move tests:

    ```zsh
    # From inside Econia repository root directory
    s mp # Navigate to Move package
    s ta # Run all tests
    INCLUDING DEPENDENCY AptosFramework
    INCLUDING DEPENDENCY MoveStdlib
    BUILDING Econia
    Running Move unit tests
    ...
    ```

### Using the Python package

Econia comes with a Python package for assorted build scripting functionality.
The Python package is not as actively maintained as the Move code, and is mostly used for publishing bytecode to the blockchain, simple on-chain tests, etc.
It is not necessary to use the Python package to develop Econia, but not all of the shell scripts will work without it.
To install the `econia` Python package:

1. First install Homebrew:

    ```zsh
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

2. Then `brew install` Miniconda:

    ```zsh
    brew install miniconda # Python package management
    ```

3. Create the `econia` conda environment with the `Econia` Python package inside:

    ```zsh
    conda env create -f env/conda.yml
    ```

    ```zsh
    conda activate econia
    ```

    ```zsh
    pip install -e src/python
    ```

4. Create the secrets directories as needed:

    ```zsh
    if ! test -d .secrets; then mkdir .secrets; fi
    ```

    ```zsh
    if ! test -d .secrets/old; then mkdir .secrets/old; fi
    ```

Econia uses `conda` (a command line tool for managing Python environments), the `econia` conda environment, and the Econia Python package within the `econia` conda environment.
If using VS Code, select `econia` as the default Python interpreter, and the integrated terminal should automatically activate it as needed, otherwise use the command line:

```zsh
# To activate
(base) % conda activate econia
# To deactivate
(econia) econia % conda deactivate
```

With the `econia` conda environment active, you can then build the Python package documentation, explore the provided interactive Jupyter notebook archive, and run Move command line tools:

```zsh
# Autobuild Sphinx documentation with realtime updates
(econia) % s ab
```

```zsh
# Open Jupyter notebook gallery
# Earliest notebooks subject to breaking changes
(econia) % s nb
```

```zsh
# Change directory to the Econia Move package
# Move package has its own utility shell scripts
(econia) % s p # Publish bytecode
```

## Major filetypes

### Jupyter

Interactive Jupyter notebook examples are at [`src/jupyter`](src/jupyter), listed in increasing order of creation number.
The earliest notebooks are subject to breaking changes at the most recent commit, but they have been archived so as to be functional at the commit when they where finalized.
Hence, older commits can be checked out and experimented with, but mostly they are useful for harvesting old code patterns.

### Markdown

Markdown files have a line break for each new sentence to make diff tracking easier.
GitBook markdown source files are at [`doc/doc-site/`](doc/doc-site/).

### Move

Move source code is at [`src/move/econia`](src/move/econia).
In the absence of a formal style guide, Move code is formatted similarly to PEP8-style Python code.
Auto-generated module documentation files are at [`src/move/econia/build/Econia/docs`](src/move/econia/build/Econia/docs).

### Python

The Econia Python package source code is at [`src/python/econia`](src/python/econia).
Python source is formatted according to the PEP8 style guide, and uses NumPy-style docstrings and PEP484-style type annotations, which are automatically parsed into a documentation website via Sphinx.
Sphinx documentation source files are at [`doc/sphinx`](doc/sphinx).