# Shell scripts for common developer workflows

# Substitute named `@econia`` address in Move.toml, passing optional
# argument specifying the address to substitute.
#
# Should be run from inside Move package directory.
substitute_econia_address() {
    cd ../../../ # Navigate to Econia repository root
    # Substitute docgen address, passing optional argument
    python src/python/econia/build.py substitute $1
    cd src/move/econia # Navigate back to move package
}

# Get relative (to Econia project root) path to devnet keyfile, and
# account address derived from the hex seed within.
#
# Should be run from inside Move package directory.
get_devnet_keyfile_info () {
    cd ../../../.secrets/devnet/ # Navigate to devnet secrets folder
    keyfile=(*(N[1])) # Get first file name in directory (zsh)
    cd ../.. # Navigate to Econia root directory
    keyfile=".secrets/devnet/$keyfile" # Get relative path to keyfile
    # Get address from keyfile hex seed
    addr=$(python src/python/econia/build.py print-keyfile-address "$keyfile")
    cd src/move/econia # Navigate back to move package
}

# Return if no arguments passed
if test "$#" = 0; then return

# Git add all and commit from project root, then come back
elif test $1 = ac; then
    cd ../../../
    git add .
    git commit
    cd src/move/econia

# Build package via Move command line
elif test $1 = b; then move build

# Clear the terminal
elif test $1 = c; then clear

# Conda activate econia environment
elif test $1 = ca; then conda activate econia

# Clean up temp files and terminal
elif test $1 = cl; then
    move sandbox clean
    clear

# Run test coverage summary against a module
# For instance, `s cm Coin`
elif test $1 = cm; then move package coverage source --module $2

# Output test coverage summary
elif test $1 = cs; then move package coverage summary

# Build documentation
elif test $1 = d; then
    substitute_econia_address # Substitute address with default option
    move build --doc # Build docs

# Substitute devnet address into Move.toml
elif test $1 = da; then
    get_devnet_keyfile_info
    substitute_econia_address $keyfile

# Go back to Econia project repository root
elif test $1 = er; then cd ../../../

# Verify that this script can be invoked
elif test $1 = hello; then echo Hello, Econia developer

# Publish bytecode using a newly-generated address
elif test $1 = p; then
    # Capture RegEx search on printed output of address generator
    addr=$(python ../../python/econia/build.py gen ../../.. \
        | grep -E -o "(\w+)$")
    # Compile package using new named address
    aptos move compile --named-addresses "econia=0x$addr" > /dev/null
    # Publish under corresponding account (restores docgen address)
    python ../../python/econia/build.py publish \
        ../../../.secrets/"$addr".key ../../../ $2
    # Rebuild docs with docgen address for readability
    move build --doc &> /dev/null

# Publish using a keyfile in ../../.secrets/devnet
elif test $1 = pd; then
    get_devnet_keyfile_info
    # Substitute generic named address in Move.toml
    substitute_econia_address _
    # Compile package using devnet named address
    aptos move compile --named-addresses "econia=0x$addr" > /dev/null
    cd ../../.. # Navigate to Econia root folder
    # Publish using devnet account keyfile
    python src/python/econia/build.py publish-keyfile $keyfile
    # Update Move.toml with devnet named address
    python src/python/econia/build.py substitute $keyfile
    # Navigate back to Move package
    cd src/move/econia

# Run tests in standard form , passing optional argument
# For example `s ts -f coin`
elif test $1 = t; then move package test $2 $3

# Run aptos CLI test on all modules, rebuild documentation
elif test $1 = ta; then aptos move test; move build --doc

# Run tests with coverage, for given filter argument
# For example `s tc critbit`
elif test $1 = tc; then move package test --coverage -f $2

# Run aptos CLI test with filter and passed argument
elif test $1 = tf; then aptos move test --filter $2

# Watch source code and rebuild documentation if it changes
# May require `brew install entr` beforehand
elif test $1 = wd; then
    # Substitute address with default option (subs docgen address)
    substitute_econia_address
    ls sources/*.move | entr move build --doc

# Watch source code and run all tests if it changes
# May require `brew install entr` beforehand
elif test $1 = wt; then
    # Substitute address with default option (subs docgen address)
    substitute_econia_address
    ls sources/*.move | entr aptos move test

else echo Invalid option; fi