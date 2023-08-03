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

To check types with mypy, run the following command:

```sh
poetry run mypy --config-file=./mypy.ini
```

Run autoflake with the following command:

```sh
poetry run autoflake -i -r econia_sdk
```

## Documentation

To build [pdoc](https://pdoc.dev/docs/pdoc.html):

```zsh
poetry install --with docs
poetry run pdoc -o docs econia_sdk
```
