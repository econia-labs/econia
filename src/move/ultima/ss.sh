# Shell scripts for common developer workflows
if [ $1 = cl ]
then # Clean up for sandbox development
    move sandbox clean
    python ../../python/ultima/build.py prep short ../../..
elif [ $1 = bp ]
then # Build and publish bytecode for all modules
    python ../../python/ultima/build.py prep long ../../..
    cargo run -- sources
    python ../../python/ultima/build.py publish ../../../.secrets/Ultima.key ../../../
elif [ $1 = mp ]
then # Clean up and run move package build
    python ../../python/ultima/build.py prep short ../../..
    move package build
elif [ $1 = sa ]
then # Switch Move.toml to use short addresses
    python ../../python/ultima/build.py prep short ../../..
elif [ $1 = ur ]
then # Change directory to Ultima project respository root
    cd ../../../
else
    echo Invalid option
fi