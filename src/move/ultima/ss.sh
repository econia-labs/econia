# References to "short" and "long" addresses refer to named addresses in
# the Move.toml file. The Move command line takes 16-byte addresses,
# while the Aptos blockchain takes 32-byte addresses, so scripting
# utilities are provided to quickly shift between the two formats

# Return if no arguments passed
if test "$#" = 0; then
    return
fi

# Verify that this script can be invoked
if test $1 = hello; then
    echo Hello, Ultima developer

# Clear the terminal
elif test $1 = c; then
    clear

# Go back to Ultima project repository root
elif test $1 = ur; then
    cd ../../../

# Aptos build and publish bytecode for all modules, passing arguments
# Other scripts automatically update the specified keyfile
elif test $1 = pb; then
    python ../../python/ultima/build.py prep long ../../..
    aptos move compile
    python ../../python/ultima/build.py publish ../../../.secrets/e6d77e11c84fbc9c54913b98c704231842f7367520ec21e72a1ec4bf53e3eded.key ../../../ $2

# Clean up temp files and format addresses in short form
elif test $1 = cl; then
    move sandbox clean
    python ../../python/ultima/build.py prep short ../../..

# Generate a new dev account keyfile
elif test $1 = na; then
    python ../../python/ultima/build.py gen  ../../..

# Build package via Move command line
elif test $1 = mb; then
    python ../../python/ultima/build.py prep short ../../..
    move package build

# Run tests with coverage, passing optional argument
# For example `s tc -f coin`
elif test $1 = tc; then
    python ../../python/ultima/build.py prep short ../../..
    move package test --coverage $2 $3

# Run tests in standard form , passing optional argument
# For example `s ts -f coin`
elif test $1 = ts; then
    python ../../python/ultima/build.py prep short ../../..
    move package test $2 $3

# Output test coverage summary
elif test $1 = cs; then
    move package coverage summary

# Run test coverage summary against a module
# For instance, `s cm Coin`
elif test $1 = cm; then
    move package coverage source --module $2

# Format short address form
elif test $1 = sa; then
    python ../../python/ultima/build.py prep short ../../..

# Format long address form
elif test $1 = la; then
    python ../../python/ultima/build.py prep long ../../..

# Build documentation
elif test $1 = bd; then
    move package build --doc

else
    echo Invalid option
fi