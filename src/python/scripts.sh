#!/bin/bash

# Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Econia package root directory.
econia_root="../../"

# Move package directory.
move_dir=$econia_root"src/move/econia/"

# Secrets directory.
secrets_dir=$econia_root".secrets/"

# Governance script path.
governance_script=$move_dir"scripts/govern.move"

# Incentives Move module path.
incentives_module=$move_dir"sources/incentives.move"

# Manifest path.
manifest=$move_dir"Move.toml"

# Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Command line argument parsers >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

case "$1" in

    # Format code.
    f)
        echo "Formatting code"
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
        ;;

    # Print account authentication key for persistent account
    ap)
        echo "Getting authentication key for peristent account"
        # Run authentication key Python command for persistent directory.
        poetry run python -m econia.account authentication-key \
            $secrets_dir"persistent"
        ;;

    # Print account authentication key for temporary account
    at)
        echo "Getting authentication key for temporary account"
        # Run authentication key Python command for temporary directory.
        poetry run python -m econia.account authentication-key \
            $secrets_dir"temporary"
        ;;

    # Go to Econia root.
    er)
        cd $econia_root
        echo "Now at $(pwd)"
        ;;

    # Generate account file in persistent secrets directory.
    gp)
        echo "Generating persistent account" # Print notice.
        # Run account generator command for persistent type.
        poetry run python -m econia.account generate \
            $secrets_dir --type persistent
        ;;

    # Generate account file in temporary secrets directory.
    gt)
        echo "Generating temporary account" # Print notice.
        # Run account generator command for temporary type.
        poetry run python -m econia.account generate \
            $secrets_dir --type temporary
        ;;

    # Update named address in manifest.
    na)
        echo "Updating named address" # Print notice.
        # Run manifest address setter command, passing remaining arguments.
        poetry run python -m econia.manifest address \
            $manifest "${@:2}"
        ;;

    # Update genesis parameters.
    pg)
        echo "Updating genesis parameters" # Print notice.
        # Run incentives CLI genesis command, passing remaining arguments.
        poetry run python -m econia.incentives update \
            $incentives_module --genesis-parameters "${@:2}"
        ;;

    # Update script parameters.
    ps)
        echo "Updating script parameters" # Print notice.
        # Run incentives CLI command, passing remaining arguments.
        poetry run python -m econia.incentives update \
            $governance_script "${@:2}"
        ;;

    # Test code.
    t)
        echo "Running Python tests"                   # Print notice.
        find . -name "*.py" | xargs python -m doctest # Doctest all source.
        ;;

    # Print invalid option.
    *)
        echo invalid
        ;;

esac

# Command line argument parsers <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
