![](.assets/readme-banner.png)

[![Discord chat](https://img.shields.io/discord/988942344776736830?style=flat)](https://discord.com/invite/ekN8fUCf)
[![Econia move documentation (move)](https://img.shields.io/badge/docs-move-59f)](src/move/econia/build/Econia/docs)
[![License](https://img.shields.io/badge/license-Apache_2.0-white.svg)](LICENSE.md)


# Econia
*Hyper-parallelized on-chain order book for the Aptos blockchain*

- [Econia](#econia)
  - [Developer setup](#developer-setup)
    - [Shell scripts](#shell-scripts)
    - [Installing dependencies](#installing-dependencies)
    - [Conda](#conda)
  - [Major filetypes](#major-filetypes)
    - [Python](#python)
    - [Jupyter](#jupyter)
    - [Move](#move)

## Developer setup

### Shell scripts

The easiest way to develop with Econia is through the provided shell scripts, and the fastest way to run these scripts is by adding the following function to your runtime configuration file (`~/.zshrc`, `~/.bash_profile`, etc):

```zsh
# Shell script wrapper: pass all commands to ./ss.sh
s() {source ss.sh "$@"}
```

Now you will be able to run the provided `ss.sh` script file in whatever directory you are in by simply typing `s`:

```
% git clone https://github.com/econia-exchange/econia.git
% cd econia
% s hello
Hello, Econia developer
```

See `ss.sh` within a given directory for its available options

### Installing dependencies

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
    conda env create -f env/conda.yml
    ```

    ```zsh
    conda activate econia
    ```

    ```zsh
    pip install -e src/python
    ```

1. Create the secrets directories as needed:

    ```zsh
    if ! test -d .secrets; then mkdir .secrets; fi
    ```

    ```zsh
    if ! test -d .secrets/old; then mkdir .secrets/old; fi
    ```

1. In the future, you may be able to get away with only installing the `aptos` CLI and the `move` CLI:

    ```zsh
    cargo install --git https://github.com/aptos-labs/aptos-core.git aptos
    cargo install --git https://github.com/diem/move move-cli --branch main
    ```

    But at the time of the writing of this guide, the potentially-unnecessary steps below were performed too

1. Install `aptos-core` and the `aptos` command line tool per the [official instructions](https://aptos.dev/tutorials/your-first-move-module#step-11-download-aptos-core):

    ```zsh
    # In a different directory
    git clone https://github.com/aptos-labs/aptos-core.git
    cd aptos-core
    ./scripts/dev_setup.sh
    source ~/.cargo/env
    cargo install --git https://github.com/aptos-labs/aptos-core.git aptos
    ```

1. Install `diem` and `move` per the [official instructions](https://github.com/move-language/move/tree/main/language/documentation/tutorial#step-0-installation) (though the next step will install the `move` CLI and this can probably be skipped):

    ```zsh
    # In a different directory
    git clone https://github.com/diem/diem.git
    git clone https://github.com/diem/move.git
    cd diem
    ./scripts/dev_setup.sh -ypt
    source ~/.profile
    cd ..
    cargo install --path diem/diem-move/df-cli
    cargo install --path move/language/move-analyzer
    ```

1. Install the `move` command line tool per the [official instructions](https://github.com/diem/move/tree/main/language/tools/move-cli#installation):

    ```zsh
    cargo install --git https://github.com/diem/move move-cli --branch main
    ```

### Conda

Econia uses `conda` (a command line tool for managing Python environments), the `econia` conda environment, and the Econia Python package within the `econia` conda environment.
If using VS Code, select `econia` as the default Python interpreter, and the integrated terminal should automatically activate it as needed, otherwise use the command line:

```zsh
# To activate
(base) % conda activate econia
# To deactivate
(econia) econia % conda deactivate
```

With the `econia` conda environment active, you can then build the documentation, explore the provided interactive Jupyter notebook archive, and run Move command line tools:

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
(econia) % s mp
```

## Major filetypes

### Python

The Econia Python package source code is at [`src/python/econia`](src/python/econia).
Python source is formatted according to the PEP8 style guide, and uses NumPy-style docstrings and PEP484-style type annotations, which are automatically parsed into a documentation website via Sphinx.
Sphinx documentation source files are at [`doc/sphinx`](doc/sphinx).

### Jupyter

Interactive Jupyter notebook examples are at [`src/jupyter`](src/jupyter), listed in increasing order of creation number.
The earliest notebooks are subject to breaking changes at the most recent commit, but they have been archived so as to be functional at the commit when they where finalized.
Hence, older commits can be checked out and experimented with, but mostly they are useful for harvesting old code patterns.

### Move

Move source code is at [`src/move/econia`](src/move/econia).
In the absence of a formal style guide, Move code is formatted similarly to PEP8-style Python code.
Auto-generated module documentation files are at [`src/move/econia/build/Econia/docs`](src/move/econia/build/Econia/docs).