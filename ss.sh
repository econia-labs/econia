# Shell scripts for common developer workflows

# Return if no arguments passed
if test "$#" = 0; then return

# Initiate sphinx-autobuild
elif test $1 = ab; then
    conda activate econia # Activate Econia conda environment
    python -mwebbrowser http://127.0.0.1:8000/
    sphinx-autobuild doc/sphinx/src doc/sphinx/build --watch src/python

# Clear terminal
elif test $1 = c; then clear

# Run Sphinx doctest
elif test $1 = dt; then
    conda activate econia # Activate Econia conda environment
    make -C doc/sphinx doctest

# Verify that this script can be invoked
elif test $1 = hello; then echo Hello, Econia developer

# Go to Move package folder
elif test $1 = mp; then
    conda activate econia # Activate Econia conda environment
    cd src/move/econia

# Start a Jupyter notebook server
elif test $1 = nb; then
    cd src/jupyter
    conda activate econia # Activate Econia conda environment
    jupyter notebook

# If no corresponding option
else echo Invalid option; fi