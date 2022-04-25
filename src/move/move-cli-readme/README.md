# Command modifications

* A [pull request](https://github.com/move-language/move/pull/80) was submitted to rectify the below errors
* Additionally, commands could be run from within `move-cli-readme` without the `-p` option, yielding:
    * `move sandbox exp-test`
    * `move sandbox exp-test --track-cov`

## Path provision

Under [Expected Value Testing with the Move CLI](https://github.com/move-language/move/tree/main/language/tools/move-cli#expected-value-testing-with-the-move-cli), where the tutorial lists command

``` move
move sandbox exp-test readme
```

instead run

```move
move sandbox exp-test -p move-cli-readme
```

## Coverage
Under [Testing with code coverage tracking](https://github.com/move-language/move/tree/main/language/tools/move-cli#testing-with-code-coverage-tracking), where the tutorial lists command

```move
move sandbox test readme --track-cov
```

instead run

```move
move sandbox exp-test -p move-cli-readme --track-cov
```