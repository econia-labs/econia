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
elif [ $1 = mp ]
then # Change directory to Move package
    python src/python/ultima/build.py prep short
    cd src/move/ultima
    move sandbox clean
else
    echo Invalid option
fi