Scripts in this directory should be run from one directory up:

```sh
source scripts/script-to-run.sh
```

Scripts are [enclosed in `()`](https://unix.stackexchange.com/questions/219314/best-way-to-make-variables-local-in-a-sourced-bash-script/219346#comment1456557_219346) to avoid namespace clutter.