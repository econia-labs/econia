#!/bin/bash

# URL to download homebrew.
brew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Python package directory.
python_dir="src/python/"

# Move package directory.
move_dir="src/move/econia/"

# Incentives modules.
incentives_module=$move_dir"sources/incentives.move"

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
        if which brew &>/dev/null; then            # If brew installed:
            echo "Brew already installed"          # Print notice as such.
        else                                       # Otherwise:
            echo "installing Brew"                 # Print notice of installation.
            /bin/bash -c "$(curl -fsSL $brew_url)" # Install brew.
        fi
        brew_install aptos               # Install aptos CLI.
        brew_install poetry              # Insall poetry.
        brew_install shfmt               # Install shell script formatter.
        cd src/python                    # Navigate to Python package directory.
        echo "Installing Python package" # Print notice.
        poetry install                   # Install the Python package and dependencies.
        cd ../..                         # Navigate back to Econia root directory.
        ;;

    # Format shell scripts
    fs)
        echo "Formatting shell scripts" # Print notice.
        # Recursively format scripts.
        shfmt --list --write --simplify --case-indent --indent 4 .
        ;;

    # Set genesis parameters.
    sg)
        echo "Setting genesis parameters." # Print notice.
        cd python_dir # Change working directory to Python package.
        # Run incentives CLI genesis command, passing arguments 2 onward.
        poetry run python -m econia.incentives genesis \
            "../../"$incentives_module "${@:2}"
        cd ../../ # Navigate back to Econia root directory.
        ;;

    # Develop Python package.
    dp)
        cd $python_dir # Change working directory to Python package.
        ;;

esac

# Command line argument parsers <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<