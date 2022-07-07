# Shell scripts for common developer workflows

# Return if no arguments passed
if test "$#" = 0; then return

# Initiate sphinx-autobuild
elif test $1 = ab; then
    python -mwebbrowser http://127.0.0.1:8000/
    sphinx-autobuild doc/sphinx/src doc/sphinx/build --watch src/python

# Clear terminal
elif test $1 = c; then clear

# Run Sphinx doctest
elif test $1 = dt; then make -C doc/sphinx doctest

# Verify that this script can be invoked
elif test $1 = hello; then echo Hello, Econia developer

# Go to Move package folder
elif test $1 = mp; then
    cd src/move/econia
    move sandbox clean

# Start a Jupyter notebook server
elif test $1 = nb; then
    cd src/jupyter
    jupyter notebook

# Install dependencies and generate relevant files
# Designed so can be re-run without overwriting/throwing errors
# Does not fully work, manual setup is easier
# Scripts included as reference
elif test $1 = setup; then

    # Install homebrew, a package manager
    echo The package dependency installer will now ask for your password
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrew install package dependencies
    brew install python # API scripting
    brew install miniconda # Manages Python packages
    brew install rust # Move is built on rust

    # Install conda environment if it doesn't exist
    # Included because attempted re-install throws errors
    if ! conda info -e | grep -q 'econia '; then
        conda env create -f env/conda.yml
    fi
    conda activate econia

    # Pip install the Econia python package to econia conda environment
    # Install in editable mode so can update Python source in real time
    pip install -e src/python

    # Create .secrets directory, which is ignored by git, for keyfiles
    # Do not overwrite if .secrets already exists
    if ! test -d .secrets; then mkdir .secrets; fi
    # Similarly create a directory for old secrets, used by build utils
    if ! test -d .secrets/old; then mkdir .secrets/old; fi

    # Generate a random keyfile for publishing bytecode
    python src/python/econia/build.py gen

    echo Setup complete

# If no corresponding option
else echo Invalid option; fi