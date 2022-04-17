# Shell scripts for common developer workflows

if [ $1 = ab ]
then # Initiate sphinx-autobuild
    sphinx-autobuild doc/sphinx/src doc/sphinx/build --watch src/python
elif [ $1 = lc ]
then # Run Sphinx linkcheck
    make -C doc/sphinx linkcheck
else
    echo Invalid option
fi