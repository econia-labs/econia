#!/bin/bash

# Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# URL to download homebrew.
brew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Move package directory.
move_dir="src/move/econia/"

# Manifest path.
manifest=$move_dir"Move.toml"

# Python directory.
python_dir="src/python/"

# Relative path to this directory from Python directory.
python_dir_inverse="../../"

# Secrets directory.
secrets_dir=".secrets/"

# DocGen address name.
docgen_address="0xc0deb00c"

# Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

# Substiute econia named address.
function set_econia_address {
    address=$1     # Get address.
    cd $python_dir # Navigate to Python package directory.
    # Set address.
    poetry run python -m econia.manifest address \
        $python_dir_inverse$manifest \
        $address
    cd $python_dir_inverse # Go back to repository root.
}

# Build Move documentation.
function build_move_docs {
    set_econia_address $docgen_address
    aptos move document --include-impl --package-dir $move_dir "$@"
}

# Generate temporary account.
function generate_temporary_account {
    cd $python_dir # Navigate to Python package directory.
    # Generate temporary account.
    poetry run python -m econia.account generate \
        $python_dir_inverse$secrets_dir \
        --type temporary
    cd $python_dir_inverse # Go back to repository root.
}

# Print authentication key message for persistent or temporary account secret.
function print_auth_key_message {
    type=$1        # Get address.
    cd $python_dir # Navigate to Python package directory.
    # Print authentication key message.
    poetry run python -m econia.account authentication-key \
        $python_dir_inverse$secrets_dir$type
    cd $python_dir_inverse # Go back to repository root.
}

# Run Move unit tests.
function run_move_unit_tests {
    aptos move test --instructions 1000000 --package-dir $move_dir "$@"
}

# Publish Move package using REST url in ~/.aptos/config.yaml config file.
function publish {
    type=$1 # Get account type, persistent or temporary.
    # If a temporary account type, generate a temporary account.
    if [ $type = temporary ]; then generate_temporary_account; fi
    # Generate and store authentication key message.
    auth_key_message=$(print_auth_key_message $type)
    # Extract secret file path from message (2nd line).
    secret_file_path=$(echo "$auth_key_message" | sed -n '2 p')
    # Extract authentication key from message (4th line).
    auth_key=$(echo "$auth_key_message" | sed -n '4 p')
    set_econia_address 0x$auth_key # Set Econia address in manifest.
    # Fund the account.
    aptos account fund-with-faucet \
        --account 0x$auth_key \
        --amount 1000000000
    # Publish the package.
    aptos move publish \
        --private-key-file $secret_file_path \
        --override-size-check \
        --included-artifacts none \
        --package-dir $move_dir \
        --assume-yes
    # Print explorer link for account.
    echo https://aptos-explorer.netlify.app/account/0x$auth_key
    set_econia_address $docgen_address # Set DocGen address in manifest.
}

# Publish bytecode

# Functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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
        cd $python_dir_inverse           # Go back to repository root.
        ;;

    # Set econia address to underscore.
    a_)
        set_econia_address _
        ;;

    # Set econia address to DocGen address.
    ad)
        set_econia_address $docgen_address
        ;;

    # Develop Python (go to Python directory).
    dp)
        cd $python_dir
        echo "Now at $(pwd)"
        ;;

    # Format shell scripts
    fs)
        echo "Formatting shell scripts" # Print notice.
        # Recursively format scripts.
        shfmt --list --write --simplify --case-indent --indent 4 .
        ;;

    # Clean Move package directory.
    mc)
        echo "Cleaning Move package"
        aptos move clean --package-dir $move_dir --assume-yes
        ;;

    # Build Move documentation.
    md)
        build_move_docs
        ;;

    # Publish to persistent account.
    pp)
        publish persistent
        ;;

    # Publish to temporary account.
    pt)
        publish temporary
        ;;

    # Run all Move unit tests, passing possible additional arguments.
    ta)
        run_move_unit_tests "${@:2}"
        ;;

    # Run unit tests with a filter, passing possible additional arguments.
    tf)
        run_move_unit_tests --filter "${@:2}"
        ;;

    # Print invalid option.
    *)
        echo Invalid
        ;;

esac

# Command line argument parsers <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
