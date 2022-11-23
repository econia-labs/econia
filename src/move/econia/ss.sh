# Shell scripts for common developer workflows

# Variables >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

repo_root=../../../ # Relative path to Econia repository root
# Relative path to secrets directory
secrets_dir=$repo_root".secrets/"
# Realtive path to Python build file
build_py=$repo_root"src/python/econia/build.py"

# Variables <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Generate temporary devnet address, fund the account, store keyfiles
#
# Should be run from inside Move package directory.
generate_temporary_devnet_address() {
    # Generate temporary keypair files
    aptos key generate --output-file tmp --assume-yes > /dev/null
    private_key=$(<tmp) # Store private key
    get_keyfile_address tmp # Store address for given hexseed
    rm tmp* # Remove temporary keypair files
    # Move all non-dir files in secrets folder to old secrets folder
    # (https://unix.stackexchange.com/a/617582)
    mv $secrets_dir*(DN^/) $secrets_dir"old/"
    # Store private key in file having <address>.key as name
    echo $private_key > $secrets_dir"$addr.key"
    echo $addr # Print corresponding address
}

# Get address from relative path to hex seed keyfile, store as `addr`
#
# Should be run from inside Move package directory.
get_keyfile_address() {
    conda activate econia # Activate Econia conda environment
    addr=$(python $build_py print-keyfile-address $1)
}

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
        keyfile=($secrets_dir*(N.[1]))
    elif test $1 = official; then # If using official devnet keyfile
        # Look inside secrets devnet directory
        keyfile=($secrets_dir"devnet/"*(N.[1]))
    fi
    # Get address from keyfile hex seed
    get_keyfile_address $keyfile
}

# Print git log in one line
git_log_one_line() {git log --oneline --max-count=1}

# Publish to either a temporary devnet address or an official devnet
# address
#
# Should be run from inside Move package directory.
publish() {
    clear # Clear terminal for ease of printout review
    # If publishing to temporary address, generate one first
    if test $1 = temp; then generate_temporary_devnet_address; fi
    publish_from_keyfile $1 # Publish from keyfile accordingly
}

# Publish bytecode to blockchain, via keyfile flag
#
# Should be run from inside Move package directory.
publish_from_keyfile() {
    # Get keyfile for given flag argument
    get_keyfile_info $1
    # Substitute named address in Move.toml
    substitute_econia_address $addr
    # Fund the account
    aptos account fund-with-faucet \
        --account $addr \
        --amount 1000000000
    # Publish the package
    aptos move publish \
        --private-key-file $keyfile \
        --override-size-check \
        --included-artifacts none \
        --assume-yes
    # Print explorer link for address
    echo https://aptos-explorer.netlify.app/account/0x$addr
    # Substitute back docgen address
    substitute_econia_address docgen
}

# Use passed argument flag to substitute `@econia` address in Move.toml.
#
# Should be run from inside Move package directory.
substitute_econia_address() {
    # If flag is for temporary keyfile or for official devnet keyfile
    if [[ $1 = temp || $1 = official ]]; then
        get_keyfile_info $1 # Get keyfile info for given flag
    else # Else set address argument to the argument
        addr=$1
    fi
    # Substitute address in memory in Move.toml
    python $build_py substitute $addr $repo_root
}

# Update Git revision hash for dependency in Move.toml
#
# Should be run from inside Move package directory
update_rev_hash() {
    # Get hash of latest commit to aptos-core main branch
    hash=$(git ls-remote https://github.com/aptos-labs/aptos-core \
        refs/heads/main | grep -o '^\w\+')
    # Update Move.toml to indicate new hash dependency
    python $build_py rev $hash $repo_root
}

# Functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Commands >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Return if no arguments passed
if test "$#" = 0; then return

# Git add all and commit from project root, then come back
elif test $1 = ac; then
    cd $repo_root # Navigate to Econia project root directory
    git add . # Add all files
    git commit # Commit
    cd src/move/econia # Navigate back to Move package
    conda activate econia # Activate Econia conda environment
    git_log_one_line # Show git log with one line

# Clear the terminal
elif test $1 = c; then clear

# Conda activate econia environment
elif test $1 = ca; then conda activate econia

# Clean up temp files and terminal
elif test $1 = cl; then
    aptos move clean
    clear

# Build documentation
elif test $1 = d; then
    conda activate econia # Activate Econia conda environment
    substitute_econia_address docgen # Substitute docgen address
    aptos move document --include-impl # Build docs
    substitute_econia_address official # Substitute official address

# Go back to Econia project repository root
elif test $1 = er; then cd $repo_root

# Get address of keyfile with relative path
elif test $1 = ga; then get_keyfile_address $2; echo $addr

# Show git log with one line
elif test $1 = gl; then git_log_one_line

# Generate a temporary keyfile in secrets directory
elif test $1 = gt; then
    generate_temporary_devnet_address

# Git push then show the log in one line
elif test $1 = gp; then git push; git_log_one_line

# Verify that this script can be invoked
elif test $1 = hello; then echo Hello, Econia developer

# Run pre-commit checks
elif test $1 = pc; then
    conda activate econia # Activate Econia conda environment
    update_rev_hash # Update revision hash for devnet dependency
    substitute_econia_address docgen # Substitute docgen address
    aptos move test -i 1000000 # Run all tests
    aptos move document --include-impl # Build docs
    substitute_econia_address official # Substitute official address

# Publish bytecode using official devnet address
elif test $1 = po; then publish official

# Publish bytecode using a temporary devnet address
elif test $1 = pt; then publish temp

# Update devnet revision hash in Move.toml
elif test $1 = r; then
    conda activate econia # Activate Econia conda environment
    update_rev_hash

# Substitute given address into Move.toml
elif test $1 = sg; then
    conda activate econia # Activate Econia conda environment
    substitute_econia_address $2

# Substitute docgen address into Move.toml
elif test $1 = sd; then
    conda activate econia # Activate Econia conda environment
    substitute_econia_address docgen

# Substitute official devnet address into Move.toml
elif test $1 = so; then
    conda activate econia # Activate Econia conda environment
    substitute_econia_address official

# Substitute generic address into Move.toml
elif test $1 = s_; then
    conda activate econia # Activate Econia conda environment
    substitute_econia_address _ # Subsitute generic address

# Run aptos CLI test on all modules
elif test $1 = ta; then aptos move test -i 1000000

# Run aptos CLI test with filter and passed argument
elif test $1 = tf; then aptos move test --filter $2 -i 1000000

# Watch source code and rebuild documentation if it changes
# May require `brew install entr` beforehand
elif test $1 = wd; then
    conda activate econia # Activate Econia conda environment
    # Substitute docgen address into Move.toml
    substitute_econia_address docgen
    ls sources/*.move | entr aptos move document --include-impl

# Watch source code and run a specific test if it changes
# May require `brew install entr` beforehand
elif test $1 = wt; then
    conda activate econia # Activate Econia conda environment
    # Substitute docgen address into Move.toml
    substitute_econia_address docgen
    ls sources/*.move | entr aptos move test --filter $2 -i 1000000

else echo Invalid option; fi

# Commands <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<