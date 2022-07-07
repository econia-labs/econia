# Shell scripts for common developer workflows

# Return if no arguments passed
if test "$#" = 0; then return

# Git add all and commit from project root, then come back
elif test $1 = ac; then
    cd ../../../
    git add .
    git commit
    cd src/move/econia

# Build package via Move command line
elif test $1 = b; then move package build

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
elif test $1 = d; then move package build --doc

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
    aptos move compile --named-addresses "Econia=0x$addr" > /dev/null
    # Publish under corresponding account (restores named address)
    python ../../python/econia/build.py publish \
        ../../../.secrets/"$addr".key ../../../ $2
    # Rebuild docs with named address to avoid git diffs
    move package build --doc >/dev/null

# Run tests in standard form , passing optional argument
# For example `s ts -f coin`
elif test $1 = t; then move package test $2 $3

# Run aptos CLI test on all modules
elif test $1 = ta; then aptos move test

# Run tests with coverage, for given filter argument
# For example `s tc critbit`
elif test $1 = tc; then move package test --coverage -f $2

# Run aptos CLI test with filter and passed argument
elif test $1 = tf; then aptos move test --filter $2

# Watch source code and rebuild documentation if it changes
# May require `brew install entr` beforehand
elif test $1 = wd; then
    ls sources/*.move | entr move package build --doc

else echo Invalid option; fi