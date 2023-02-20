# Econia package root directory.
econia_root="../../"

# Move package directory.
move_dir=$econia_root"src/move/econia/"

# Governance script path.
governance_script=$move_dir"scripts/govern.move"

# Incentives Move module path.
incentives_module=$move_dir"sources/incentives.move"

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

    # Go to Econia root.
    er)
        cd $econia_root
        echo "Now at $(pwd)"
        ;;

    # Update genesis parameters.
    pg)
        echo "Updating genesis parameters" # Print notice.
        # Run incentives CLI genesis command, passing remaining arguments.
        poetry run python -m econia.incentives genesis \
            $incentives_module --genesis-parameters "${@:2}"
        ;;

    # Update script parameters.
    ps)
        echo "Updating script parameters" # Print notice.
        # Run incentives CLI command, passing remaining arguments.
        poetry run python -m econia.incentives genesis \
            $governance_script "${@:2}"
        ;;

    # Test code.
    t)
        echo "Running Python tests"                   # Print notice.
        find . -name "*.py" | xargs python -m doctest # Doctest all source.
        ;;

esac

# Command line argument parsers <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
