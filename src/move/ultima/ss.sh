# Shell scripts for common developer workflows

if [ $1 = cl ]
then # Clean up for sandbox development
    move sandbox clean
    python ../../python/ultima/build.py prep short ../../..
elif [ $1 = cp ]
then # Cargo build and publish bytecode for all modules
    python ../../python/ultima/build.py prep long ../../..
    cargo run -- sources
    python ../../python/ultima/build.py publish ../../../.secrets/767f55126ad35ac6acaa130a2a18ba38d721fd42e5fa4bfe10885216ee307706.key ../../../
elif [ $1 = na ]
then # Generate new dev account
    python ../../python/ultima/build.py gen  ../../..
elif [ $1 = mb ]
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