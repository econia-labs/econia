# Shell scripts for common developer workflows

# Load into global memory a relative path (relative to Move package
# directory) to flagged keyfile, and the address derived from the hex
# seed within the keyfile. Stores in variables `keyfile` and `addr`.
#
# If called with argument `temp`, operates on temporary keyfile in
# secrets directory
#
# If called with argument `official`, operates on official devnet file
#
# Should be run from inside Move package directory.
get_keyfile_info() {
    if test $1 = temp; then # If using a temporary keyfile
        # Keyfile is first regular file in secrets directory
        # (https://unix.stackexchange.com/a/617582)
        keyfile=(../../../.secrets/*(N.[1]))
    elif test $1 = official; then # If using official devnet keyfile
        # Look inside secrets devnet directory
        keyfile=(../../../.secrets/devnet/*(N.[1]))
    fi
    # Get address from keyfile hex seed
    addr=$(python ../../../src/python/econia/build.py print-keyfile-address \
        "$keyfile")
}


# Use passed argument flag to substitute `@econia` address in Move.toml.
#
# Should be run from inside Move package directory.
substitute_econia_address() {
    # If flag is for docgen or for generic address
    if [[ $1 = docgen || $1 = _ ]]; then
        addr=$1 # Set address argument to the argument
    # If flag is for temporary keyfile or for official devnet keyfile
    elif [[ $1 = temp || $1 = official ]]; then
        get_keyfile_info $1 # Get keyfile info for given flag
    fi
    # Substitute address in memory in Move.toml
    python ../../../src/python/econia/build.py substitute $addr ../../../
}

# Publish bytecode to blockchain, via keyfile flag
#
# Should be run from inside Move package directory.
publish_from_keyfile () {
    # Substitute generic named address in Move.toml
    substitute_econia_address _
    # Get keyfile for given flag argument
    get_keyfile_info $1
    # Compile package using new named address
    aptos move compile --named-addresses "econia=0x$addr" > /dev/null
    # Publish under corresponding account
    python ../../python/econia/build.py publish "$keyfile" ../../../
    # Substitute back docgen address
    substitute_econia_address docgen
}

# Return if no arguments passed
if test "$#" = 0; then return

# Git add all and commit from project root, then come back
elif test $1 = ac; then
    cd ../../../ # Navigate to Econia project root directory
    git add . # Add all files
    git commit # Commit
    cd src/move/econia # Navigate back to Move package

# Clear the terminal
elif test $1 = c; then clear

# Conda activate econia environment
elif test $1 = ca; then conda activate econia

# Clean up temp files and terminal
elif test $1 = cl; then
    move sandbox clean
    clear

# Build documentation
elif test $1 = d; then
    substitute_econia_address docgen # Substitute docgen address
    move build --doc # Build docs

# Go back to Econia project repository root
elif test $1 = er; then cd ../../../

# Generate a temporary keyfile account in secrets directory
elif test $1 = gt; then python ../../python/econia/build.py generate ../../../

# Verify that this script can be invoked
elif test $1 = hello; then echo Hello, Econia developer

# Run pre-commit checks
elif test $1 = pc; then
    substitute_econia_address docgen # Substitute docgen address
    aptos move test # Run all tests
    move build --doc # Build docs
    substitute_econia_address official # Substitute official address

# Publish bytecode using official devnet address
elif test $1 = po; then
    publish_from_keyfile official

# Publish bytecode using a temporary devnet address
elif test $1 = pt; then
    # Generate temporary address
    python ../../python/econia/build.py generate ../../../
    # Publish from temporary keyfile
    publish_from_keyfile temp

# Substitute docgen address into Move.toml
elif test $1 = sd; then substitute_econia_address docgen

# Substitute official devnet address into Move.toml
elif test $1 = so; then substitute_econia_address official

# Run aptos CLI test on all modules, rebuild documentation
elif test $1 = ta; then aptos move test; move build --doc

# Run aptos CLI test with filter and passed argument
elif test $1 = tf; then aptos move test --filter $2

# Watch source code and rebuild documentation if it changes
# May require `brew install entr` beforehand
elif test $1 = wd; then
    # Substitute docgen address into Move.toml
    substitute_econia_address docgen
    ls sources/*.move | entr move build --doc

else echo Invalid option; fi