# Ultima

*Hyper-parallelized on-chain order book for the Aptos blockchain*

## Environment management

### Python

* Python environments are managed via the ``env/conda.yml`` conda environment
* The `ultima` Python package is in development and must be installed from source

#### Installation

```
conda env create -f env/conda.yml
```

* Pip install the ``ultima`` Python package from source, in editable mode:

```
conda activate ultima
pip install -e src/python
```

#### Exporting

* If you install a new conda package, update the environment specification:

```
conda env export > env/conda.yml
```

* Delete the last line of the file, which will look something like:

```
prefix: /Users/user/opt/miniconda3/envs/ultima
```

## Documentation

### Python

* Source code contains Numpy style docstrings and PEP484-style type annotations
* Sphinx documentation uses autodoc

### Sphinx

#### Static build

```
make -C doc/sphinx/ html
```

* Then point a browser to ``doc/sphinx/build/html/index.html``

#### Auto build

```
sphinx-autobuild doc/sphinx/src doc/sphinx/build --watch src/python
```

* Then point a browser to ``http://127.0.0.1:8000/``

#### Clearing tempfiles

```
make -C doc/sphinx clean
```

#### Checking links

```
make -C doc/sphinx linkcheck
```