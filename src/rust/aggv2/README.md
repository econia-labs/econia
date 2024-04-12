# Aggregator v2

## Architecture

The new aggregator works using feeds.

There are three types of feeds:

- ones that can generate a result from their previous value and the events that occurred since that previous value was generated
- ones that can generate a result from only events that occurred in a time period
- ones that can generate a result from another feed

You can generate the result for the first two types in parallel.
Once done, you can generate the result of the third type in parallel.

There are some unit numeric types defined that wrap `BigDecimal`.
This avoids confusion (you can add lots and ticks together) and simplifies calculus (dividing a `Tick` value by a `Price` value outputs a `Lot`).

## Findings

Tests and benchmarks have not been conducted yet.

Although some findings are already here:

- This implementation is slower to backfill, as it will query events per 1 second batch, rather than bigger batches, although this can be optimized away.
- This implementation is very likely to have higher throughput, as it is more efficient than the other one.
