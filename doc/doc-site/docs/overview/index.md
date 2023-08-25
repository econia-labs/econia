# Design overview

## General

As an [Aptos]-native project, Econia is designed from the ground up to leverage [Block-STM] and the [Move] programming language.
In particular, Econia is optimized for parallel execution across markets, such that transactions for different trading pairs operate on non-overlapping regions of global state.
With additional access controls for global resources like [the registry], the result is a hyper-parallelized settlement engine with maximum throughput.

## This section

The documentation in this section provides a high-level technical overview of Econia's system architecture, intended to be read in order.
Throughout the documentation there are links to assorted data structures and functions from Econia's auto-generated [Move module] documentation files.
For example: [`OrderBook`].

[aptos]: https://aptos.dev
[block-stm]: https://arxiv.org/abs/2203.06871
[move]: https://move-language.github.io/move/
[move module]: ../move/modules
[the registry]: registry
[`orderbook`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/market.md#struct-orderbook
