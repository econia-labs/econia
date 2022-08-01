# System integration

## Friend-like capabilities

As described in the [`econia::capability` module documentation](../../../src/move/econia/build/Econia/docs/capability.md), Econia uses an internal capability to authorize cross-module invocations.

## Core resource initialization

Before trades can be placed, Econia's core account resources must be initialized per [`econia::init::init_econia()`](../../../src/move/econia/build/Econia/docs/init.md#0xc0deb00c_init_init_econia).

## Open table

Econia implements an [`econia::init::OpenTable()`](../../../src/move/econia/build/Econia/docs/open_table.md#0xc0deb00c_open_table_OpenTable), which allows for simple on-chain indexing of table keys.