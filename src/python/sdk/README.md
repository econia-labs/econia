# Econia Python SDK

## Development

To format the code, install dev dependencies with

```sh
poetry install --with dev
```

Then, run

```sh
poetry run black econia_sdk
poetry run isort econia_sdk
```

To run the type checker, run

```sh
poetry run mypy --config-file=./mypy.ini
```

## Documentation

To build [pdoc](https://pdoc.dev/docs/pdoc.html):

```zsh
poetry install --with docs
poetry run pdoc -o docs econia_sdk
```
