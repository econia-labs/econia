#!/bin/bash

# URL to download homebrew.
brew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Move package directory.
move_dir="src/move/econia/"

# Python package directory.
python_dir="src/python/"

# Helper functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Install via brew, printing call to run.
function brew_install {
    package=$1                            # Package name is first argument.
    if which "$package" &>/dev/null; then # If package installed:
        echo "$package already installed" # Print notice.
    else                                  # If package not installed:
        echo "Brew installing $package"   # Print installation notice.
        brew install $package             # Install package.
    fi
}

# Helper functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Command line argument parsers >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

case "$1" in

    # Initialize dev environment.
    init)
        echo "Initializing developer environment"  # Print notice.
        if which brew &>/dev/null; then            # If brew installed:
            echo "Brew already installed"          # Print notice as such.
        else                                       # Otherwise:
            echo "installing Brew"                 # Print notice of installation.
            /bin/bash -c "$(curl -fsSL $brew_url)" # Install brew.
        fi
        brew_install aptos               # Install aptos CLI.
        brew_install poetry              # Install poetry.
        brew_install shfmt               # Install shell script formatter.
        cd $python_dir                   # Navigate to Python package directory.
        echo "Installing Python package" # Print notice.
        poetry install                   # Install the Python package and dependencies.
        source scripts.sh er             # Go back to Econia root.
        ;;

    # Develop Python (go to Python directory).
    dp)
        cd $python_dir
        echo "Now at $(pwd)"
        ;;

    # Develop Move (go to Move package directory).
    dm)
        cd $move_dir
        echo "Now at $(pwd)"
        ;;

    # Format shell scripts
    fs)
        echo "Formatting shell scripts" # Print notice.
        # Recursively format scripts.
        shfmt --list --write --simplify --case-indent --indent 4 .
        ;;

esac

# Command line argument parsers <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
