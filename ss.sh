# Shell scripts for common developer workflows

if [ $1 = ab ]
then # Initiate sphinx-autobuild
    sphinx-autobuild doc/sphinx/src doc/sphinx/build --watch src/python
elif [ $1 = lc ]
then # Run Sphinx linkcheck
    make -C doc/sphinx linkcheck
elif [ $1 = nb ]
then # Start a Jupyter notebook server
    jupyter notebook
elif [ $1 = dt ]
then # Run Sphinx doctest
    make -C doc/sphinx doctest
elif [ $1 = la ]
then # Prepare Move.toml addresses in long form
    python src/python/ultima/build.py prep long
elif [ $1 = sa ]
then # Prepare Move.toml addresses in short form
    python src/python/ultima/build.py prep short
elif [ $1 = mp ]
then # Change directory to Move package
    python src/python/ultima/build.py prep short
    move sandbox clean
    echo Now in:
    cd src/move/ultima
    pwd
else
    echo Invalid option
fi