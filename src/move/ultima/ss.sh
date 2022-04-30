# Shell scripts for common developer workflows

if [ $1 = cl ]
then # Clean up for sandbox development
    move sandbox clean
    python ../../python/ultima/build.py prep short ../../..
elif [ $1 = pb ]
then # Cargo build and publish bytecode for all modules
    python ../../python/ultima/build.py prep long ../../..
    cargo run -- sources
    python ../../python/ultima/build.py publish ../../../.secrets/116ca02847a9ef95f6a9437152936ab242b4d00f4846e0f760ced2c497c6a4f9.key ../../../
elif [ $1 = na ]
then # Generate new dev account
    python ../../python/ultima/build.py gen  ../../..
elif [ $1 = mb ]
then # Clean up and run move package build
    python ../../python/ultima/build.py prep short ../../..
    move package build
elif [ $1 = tc ]
then # Move package test with coverage
    python ../../python/ultima/build.py prep short ../../..
    move package test --coverage
elif [ $1 = cs ]
then # Move package coverage summary
    move package coverage summary
elif [ $1 = sa ]
then # Switch Move.toml to use short addresses
    python ../../python/ultima/build.py prep short ../../..
elif [ $1 = ur ]
then # Change directory to Ultima project respository root
    cd ../../../
else
    echo Invalid option
fi