# Aggregator v2

This directory contains an experimental aggregator for the Econia Data Service
Stack.

## Architecture

The new aggregator works using feeds.

There are three types of feeds:

- ones that can generate a result from their previous value and the events that
  occurred since that previous value was generated
- ones that can generate a result from only events that occurred in a time
  period
- ones that can generate a result from another feed

You can generate the result for the first two types in parallel.
Once done, you can generate the result of the third type in parallel.

There are some unit numeric types defined that wrap `BigDecimal`.
This avoids confusion (you can add lots and ticks together) and simplifies
calculus (dividing a `Tick` value by a `Price` value outputs a `Lot`).

## In depth overview

There are 3 main threads running (4 if you count the thread responsible for
logging statistics):

- an aggregator thread
- an inserter thread
- a cache manager thread

They each play a part in the aggregating process.

### The cache manager

There is a piece of shared state called the `event_cache`, which is just a
`BTreeMap` of events that have yet to be aggregated. That map is kept filled up
by the cache manager thread, that checks the length of the cache every X
milliseconds, and if a certain threshold is reached, a DB read will be
triggered and the cached will be filled with the result. Since one of the
current bottlenecks is DB reads, that means that right now, the cache is filled
constantly. The reason this is done in a separate thread is because reading
from the database is a slow process, and does not need to stop the processing
of already read events.

### The aggregator thread

The aggregator thread uses the events in `event_cache` to generate data, that
it then puts into the `insert_cache`. It will take all the events from
`truncate(events.first().timestamp, second)` to
`truncate(events.first().timestamp, second) + 1 second` that are in the
`event_cache` and generate the data for that interval. This means that if the
cache isn't filled fast enough, which currently happens for time to time, the
aggregating process will hang briefly while the cache is filled. Once said data is generated, it will be added to the `insert_cache`, which is a map from timestamps to data. The timestamp represents the time frame of the generated data.

### The inserter thread

The inserter thread will loop every X milliseconds, and insert everything that
is present in the `insert_cache` if nothing was inserted in the last Y
milliseconds. Since writing to the database is currently a bottleneck, this
means that the insert is triggered on every iteration of the loop. The reason this is done in a separate thread is because writing to the database is a slow process, and does not need so stop the aggregation process of other events.

## Findings

- This implementation has a throughput of over 50k events per second
- The current bottleneck is reads and writes into PostreSQL
- The upcoming SDK will help alleviate some of the bottlenecks (reads)
- Consider insert optimizations or using something else than PostgreSQL to overcome write bottlenecks

## Breaking changes

This aggregator has a fundamental difference in how it operates compared to the
old aggregator. First of all, all data is timestamped and immutable (contract
state is an exception because of how big the database would get if it wasn't),
compared to the old one where some data is being updated (e.g. `user_history`).

It also does not rely on SQL processing. All the calculations are made in Rust.
This is not a breaking change itself, but that does mean that it does not rely
on SQL views like the previous aggregator. This has the upper side of vastly
improved performance, as nothing is calculated on request, but it has the
downside of being less space efficient and also more time consuming to
implement.

For the preceding reasons, the aggv2 will not be replacing the old aggregator,
but this should be the way to go for the next generations of the Econia
protocol.
