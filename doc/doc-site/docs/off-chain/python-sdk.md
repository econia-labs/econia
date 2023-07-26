# Python SDK

The code for the Python SDK lives in `/econia/src/python/sdk/econia_sdk` ([link](https://github.com/econia-labs/econia/tree/main/src/python/sdk/econia_sdk)). There are 2 primary packages (`econia_sdk.entry` and `econia_sdk.view`) complemented by two secondary imports

# Primary Packages
## `econia_sdk.entry`

This package contains helpers for the `public entry` (that is, "targetable by transactions") functions possessed by the Econia exchange. Each method's name corresponds to the name of a public entry function in one of the following Econia Move modules:

- `incentives` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/incentives.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/incentives.py))
- `market` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/market.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/market.py))
- `registry` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/registry.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/registry.py))
- `user` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/user.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/user.py))

The corresponding Move code is well-commented and up-to-date, so it's helpful to have handy when working with the Python SDK. If the function you desire happens to not be supported by the Python SDK (or sadly isn't working), it's possible to use `econia_sdk.lib.EconiaClient` to execute the appropriate `public entry` Move function yourself. See the Python code linked above for examples of how an `EntryFunction` instance is created.

## `econia_sdk.view`

This package contains helps for the `#[view]` (that is, "targetable off-chain") functions possessed by the Econia exchange. Each method's name corresponds to the name of a public view function in one of the following Econia Move modules:

- `incentives` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/incentives.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/entry/incentives.py))
- `market` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/market.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/market.py))
- `registry` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/registry.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/registry.py))
- `user` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/user.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/user.py))
- `resource_account` ([move](https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/resource_account.move)) ([python](https://github.com/econia-labs/econia/blob/main/src/python/sdk/econia_sdk/view/resource_account.py))

The corresponding Move code is well-commented and up-to-date, so it's helpful to have handy when working with the Python SDK. If the function you desire happens to not be supported by the Python SDK (or sadly isn't working), it's possible to use `econia_sdk.lib.EconiaViewer` to execute the appropriate `#[view]` Move function yourself. See the Python code linked above for examples of how an `EconiaViewer` instance is used. Note the return value of the `EconiaViewer` functions "[quacks](https://en.wikipedia.org/wiki/Duck_typing) like JSON" but every field-value is stringified.

