# `move-to-ts` hooks

Econia is designed for use with [Hippo's `move-to-ts` tool], which auto-generates a TypeScript software development kit (SDK) from Move source code.

As such, Econia's Move source code contains assorted  `#[cmd]` attributes on public entry functions for SDK generation.

Additionally, [`market.move`] provides [`index_orders_sdk()`] with a `#[query]` attribute for off-chain `OrderBook` indexing.

<!---Reference links-->
[Hippo's `move-to-ts` tool]: https://github.com/hippospace/move-to-ts
[`index_orders_sdk()`]:      ../../src/move/econia/doc/market.md#0xc0deb00c_market_index_orders_sdk
[`market.move`]:             ../../src/move/econia/doc/market.md
[`OrderBook`]:               ../../src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook