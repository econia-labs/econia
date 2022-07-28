# Move modules

| Module | Source code | Documentation |
| ------ | ----------- | ------------- |
| `book` | [book.move](../../src/move/econia/sources/book.move) | [book.md](../../src/move/econia/build/Econia/docs/book.md) |

## Use dependencies

```mermaid
flowchart TD

    market --> critbit
    market --> registry
    market --> capability
    market --> |test-only| coins
    market --> user
    init --> registry
    init --> market
    user --> capability
    user --> critbit
    user --> open_table
    user --> registry
    user --> |test-only| coins
    registry --> capability
    registry --> |test-only| coins
    registry --> open_table
    registry --> util

```