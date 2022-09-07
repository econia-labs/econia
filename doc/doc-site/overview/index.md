# Design overview

## General

As an [Aptos](https://aptos.dev)-native project, Econia is designed from the ground up to leverage [Block-STM](https://arxiv.org/abs/2203.06871) and the [Move](https://move-language.github.io/move/) programming language.
In particular, Econia is optimized for parallel execution across markets, such that transactions for different trading pairs operate on non-overlapping regions of global state.
With additional access controls for global resources like the Econia [registry](registry.md), the result is a hyper-parallelized settlement engine with maximum throughput.

## This section

The documentation in this section provides a high-level technical overview of Econia's system architecture, intended to be read in order.
Throughout the documentation there are links to assorted data structures and functions from Econia's source code, which is indexed on the [module listing page](../modules.md).
There you will additionally find auto-generated documentation files for each [Move](https://move-language.github.io/move/) module, which is what the links in this section reference.
For example, [`OrderBook`](../../../src/move/econia/build/Econia/docs/market.md#0xc0deb00c_market_OrderBook) is from the [`market.move`](../../../src/move/econia/build/Econia/docs/market.md) module.