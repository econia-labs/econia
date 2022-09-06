# Design overview

As an [Aptos](https://aptos.dev)-native project, Econia is designed from the ground up to leverage [Block-STM](https://arxiv.org/abs/2203.06871) and the [Move](https://move-language.github.io/move/) programming language.
In particular, Econia is optimized for parallel execution across markets, such that transactions for different trading pairs operate on non-overlapping regions of global state.
With additional access controls for global resources like the Econia registry, the result is a hyper-parallelized settlement engine with maximum throughput.