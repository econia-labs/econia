# Models

This document contains a complete list of all the event tables in our database. **If you're searching for aggregator tables, please look into the aggregator crate (`src/rust/aggregator`).**

## market_registration_event

| Column                  | Description                                                                                                                                  | Type      |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `id`                    | The database ID of the event. Used to chronologically separate events.                                                                       | number    |
| `market_id`             | The ID of the market just registered.                                                                                                        | number    |
| `time`                  | Timestamp at which the event happenned.                                                                                                      | timestamp |
| `base_account_address`  | Account address of the base token.                                                                                                           | string    |
| `base_module_name`      | Module name of the base token.                                                                                                               | string    |
| `base_struct_name`      | Struct name of the base token.                                                                                                               | string    |
| `base_name_generic`     | TODO: wut is dis ?                                                                                                                           | string    |
| `quote_account_address` | Account address of the quote token.                                                                                                          | string    |
| `quote_module_name`     | Module name of the quote token.                                                                                                              | string    |
| `quote_struct_name`     | Struct name of the quote token.                                                                                                              | string    |
| `lot_size`              | Number of base units exchanged per lot.                                                                                                      | number    |
| `tick_size`             | Number of quote coin units exchanged per tick.                                                                                               | number    |
| `min_size`              | Minimum number of lots per order.                                                                                                            | number    |
| `underwriter_id`        | [Link](https://github.com/econia-labs/econia/blob/fdab71182d4a7bf1b0fabc1a030e524575442e68/src/move/econia/sources/registry.move#L286-L289). | number    |
