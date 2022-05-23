# Return if no arguments passed
if test "$#" = 0; then
    return
fi

# Verify that this script can be invoked
if test $1 = hello; then
    echo Hello, Econia developer

# Clear the terminal
elif test $1 = c; then
    clear

# Go back to Econia project repository root
elif test $1 = er; then
    cd ../../../

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

# Clean up temp files and terminal
elif test $1 = cl; then
    move sandbox clean
    clear

# Build package via Move command line
elif test $1 = b; then
    move package build

# Run tests with coverage, passing optional argument
# For example `s tc -f coin`
elif test $1 = tc; then
    move package test --coverage $2 $3

# Run tests in standard form , passing optional argument
# For example `s ts -f coin`
elif test $1 = t; then
    move package test $2 $3

# Output test coverage summary
elif test $1 = cs; then
    move package coverage summary

# Run test coverage summary against a module
# For instance, `s cm Coin`
elif test $1 = cm; then
    move package coverage source --module $2

# Build documentation
elif test $1 = d; then
    move package build --doc

# Watch source code and rebuild documentation if it changes
elif test $1 = wd; then
    ls sources/*.move | entr move package build --doc

# Add all and commit
elif test $1 = ac; then
    cd ../../../
    git add .
    git commit
    cd src/move/econia

else
    echo Invalid option
fi