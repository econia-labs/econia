# Move modules

| Module | Source code | Documentation |
| ------ | ----------- | ------------- |
| `book` | [book.move](../../src/move/econia/sources/book.move) | [book.md](../../src/move/econia/build/Econia/docs/book.md) |

## Use dependencies

```mermaid
flowchart TD

    init --> order
    user --> critbit
    user --> registry
    book --> critbit
    user --> open_table
    user --> |test-only| coins
    book --> capability
    registry --> capability
    registry --> |test-only| coins
    registry --> open_table
    init --> registry
    registry --> util
    registry --> book
    order --> user
    order --> book
    order --> capability

```