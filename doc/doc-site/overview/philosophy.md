# Philosophy

## Settlement optimization

Econia is optimized for a singular purpose:
to settle trades as fast as possible.

As such, Econia is designed from the ground up leverage Aptos' Block-STM execution engine, which parallelizes transactions via optimistic concurrency methods.
However, optimizing for parallel execution occasionally results in design decisions that may appear bulky or unintuitive to the uninformed developer, like requiring a separate collateral container for each market that a user trades on, or enforcing a single trade per transaction.
Within the context of execution parallelism, however, these design principles are crucial for optimal performance, as they isolate execution into non-overlapping regions of memory, thus avoiding read/write contention that would otherwise result in degraded performance.

Moreover, Econia is designed only to settle trades, not to keep detailed records of them, because building in this kind of additional functionality would introduce computational overhead, whether by increased execution time or by enlarged memory requirements, and again this would slow down the rate of settlement.
Trade history is still accessible immutably and indefinitely, however, because all trades are settled on-chain, so indexers and other associated implements can be used to analyze historical trading data.

## Testing

Whenever possible, Econia source code is coverage tested using the `move` CLI to 100% coverage, to provide robust design assurance and streamline the audit process.
However, as described in `aptos-core` [#1275](https://github.com/aptos-labs/aptos-core/issues/1275) and [#1835](https://github.com/aptos-labs/aptos-core/issues/1835):

1. The `move` CLI does not support general coverage testing for `AptosFramework` native functions,
1. The `aptos` CLI does not provide any coverage testing support whatsoever,
1. And the `af-cli` is broken as of the time of this writing

Hence, functionality that can be accomplished purely in Move is isolated into standalone modules which are then subject to coverage testing, separate from functionality that requires `AptosFramework` native functions.
Modules incorporating `AptosFramework` functionality are still tested using the `aptos` CLI in an attempt to verify all conditional execution branches (simulated 100% coverage), but per the limitations described above, there is no command line printout to verify that they have actually been tested to 100% coverage.