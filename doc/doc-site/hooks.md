# `move-to-ts` hooks

Econia is designed for use with [Hippo's `move-to-ts` tool], which auto-generates a TypeScript software development kit (SDK) from Move source code.

As such, Econia's Move source code contains assorted  `#[cmd]` attributes on public entry functions for SDK generation.

Additionally, [`market.move`] applies [`index_orders()`] as a `#[method]` attribute to [`OrderBook`], for off-chain order book indexing.

<!---Reference links-->
[Hippo's `move-to-ts` tool]: https://github.com/hippospace/move-to-ts
[`index_orders()`]:          ../../src/move/econia/doc/market.md#0xc0deb00c_market_index_orders
[`market.move`]:             ../../src/move/econia/doc/market.md
[`OrderBook`]:               ../../src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook