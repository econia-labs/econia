#!/bin/bash

# URL to download homebrew.
brew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Python package directory.
python_dir="src/python/"

# Path to this directory from Python directory.
python_dir_inverse="../../"

# Move package directory.
move_dir="src/move/econia/"

# Incentives Move module.
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
        echo "Initializing developer environment"  # Print notice.
        if which brew &>/dev/null; then            # If brew installed:
            echo "Brew already installed"          # Print notice as such.
        else                                       # Otherwise:
            echo "installing Brew"                 # Print notice of installation.
            /bin/bash -c "$(curl -fsSL $brew_url)" # Install brew.
        fi
        brew_install aptos               # Install aptos CLI.
        brew_install poetry              # Insall poetry.
        brew_install shfmt               # Install shell script formatter.
        cd $python_dir                   # Navigate to Python package directory.
        echo "Installing Python package" # Print notice.
        poetry install                   # Install the Python package and dependencies.
        cd $python_dir_inverse           # Navigate back to Econia root directory.
        ;;

    # Format Python code
    fp)
        echo "Formatting Python code"
        cd $python_dir # Change working directory to Python package.
        # Find all files ending in .py, pass to autoflake command.
        find . -name "*.py" | xargs \
            poetry run autoflake \
            --in-place \
            --recursive \
            --remove-all-unused-imports \
            --remove-unused-variables \
            --ignore-init-module-imports
        poetry run isort .                  # Sort imports.
        poetry run black . --line-length 80 # Format code.
        cd $python_dir_inverse              # Navigate back to Econia root directory.
        ;;

    # Format shell scripts
    fs)
        echo "Formatting shell scripts" # Print notice.
        # Recursively format scripts.
        shfmt --list --write --simplify --case-indent --indent 4 .
        ;;

    # Set genesis parameters.
    sg)
        echo "Setting genesis parameters" # Print notice.
        cd $python_dir                    # Change working directory to Python package.
        # Run incentives CLI genesis command, passing arguments 2 onward.
        poetry run python -m econia.incentives genesis \
            $python_dir_inverse$incentives_module "${@:2}"
        cd $python_dir_inverse # Navigate back to Econia root directory.
        ;;

    # Test Python code.
    tp)
        echo "Running Python tests" # Print notice.
        cd $python_dir              # Change working directory to Python package.
        # Doctest all source.
        find . -name "*.py" | xargs python -m doctest
        cd $python_dir_inverse # Navigate back to Econia root directory.
        ;;

esac

# Command line argument parsers <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
