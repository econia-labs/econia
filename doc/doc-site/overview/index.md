# Design overview

## General

As an [Aptos]-native project, Econia is designed from the ground up to leverage [Block-STM] and the [Move] programming language.
In particular, Econia is optimized for parallel execution across markets, such that transactions for different trading pairs operate on non-overlapping regions of global state.
With additional access controls for global resources like [the registry], the result is a hyper-parallelized settlement engine with maximum throughput.

## This section

The documentation in this section provides a high-level technical overview of Econia's system architecture, intended to be read in order.
Throughout the documentation there are links to assorted data structures and functions from Econia's auto-generated [Move module] documentation files.
For example: [`OrderBook`].

<!---Alphabetized reference links-->

[Aptos]:        https://aptos.dev
[Block-STM]:    https://arxiv.org/abs/2203.06871
[Move]:         https://move-language.github.io/move/
[Move module]:  ../modules.md
[`OrderBook`]:  ../../../src/move/econia/doc/market.md#0xc0deb00c_market_OrderBook
[the registry]: registry.md