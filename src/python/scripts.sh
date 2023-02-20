#!/bin/bash

case "$1" in

    # Format files.
    f)
        echo "Formatting files" # Print notice.
        # Find all files ending in .py, pass to autoflake command.
        find . -name "*.py" | xargs \
            poetry run autoflake \
            --in-place \
            --recursive \
            --remove-all-unused-imports \
            --remove-unused-variables \
            --ignore-init-module-imports
        poetry run isort .                  # Sort imports.
        poetry run black . --line-length 80 # Forma code.
        ;;

    # Test files.
    t)
        echo "Running tests"                          # Print notice.
        find . -name "*.py" | xargs python -m doctest # Doctest all source.
        ;;

    # Go to Econia root directory.
    er)
        cd ../..
        ;;

esac
