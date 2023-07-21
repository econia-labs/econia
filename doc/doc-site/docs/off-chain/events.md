# Events

## Registry events

Econia emits two types of registry events:

| Event                       | Event handle          | Field name                   |
| --------------------------- | --------------------- | ---------------------------- |
| [`MarketRegistrationEvent`] | [`Registry`]          | `market_registration_events` |
| [`RecognizedMarketEvent`]   | [`RecognizedMarkets`] | `recognized_market_events`   |

Event handles for registry events are created via the `@econia` package account, and are stored as fields in `key`-able resources stored under the `@econia` account.
Hence they can be easily queried via the Aptos node [events by event handle API].

## Market events

Market events were recently incorporated per [#321] and will soon be deployed under a mainnet contract upgrade, pending an audit.

Stand by for more docs, coming soon!

[#321]: https://github.com/econia-labs/econia/pull/321
[events by event handle api]: https://fullnode.mainnet.aptoslabs.com/v1/spec#/operations/get_events_by_event_handle
[`marketregistrationevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#struct-marketregistrationevent
[`recognizedmarketevent`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#struct-recognizedmarketevent
[`recognizedmarkets`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#resource-recognizedmarkets
[`registry`]: https://github.com/econia-labs/econia/blob/main/src/move/econia/doc/registry.md#resource-registry
