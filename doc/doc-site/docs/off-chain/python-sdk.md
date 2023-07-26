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

# Seconary Packages

## `econia_sdk.lib`

This package contains `EconiaClient`, which takes care of executing transactions pointed at `public entry` function targets, and `EconiaViewer` which takes care of access to off-chain callable `#[view]` function targets. These are not meant to be used without help from this Python SDK. Both are sufficiently capable to handle all possible functions to which they may apply, as long as those functions exist in the deployed Move contract code.

## `econia_sdk.types`

This package contains various enum types useful for parsing and referring to important values. Note that Move doesn't have Enum types so unlike most of the above, these do not map directly to Move. However, each value in each enum is associated with a constant that exists in the Move code.

# Other Contents

## `examples.trade`

This is a script that makes use of both view functions and entry functions to perform a few scenarios in the exchange for the user. After set-up, it should be automatic (except for hitting enter to proceed the script). On display are things like registering a market, creating a market account and funding it, placing limit/market orders under various conditions as well as cancelling them. It's useful as a way to gain an understanding of what different fields/parameters mean and in general how to use the Python SDK. **Running/reading this example script and understanding what it does is recommended before anyone trades real money with the SDK.**

### Running the Example Script ("Trading From Scratch")

You're recommended to run a local Aptos node and faucet first; this prevents any rate-limitting issues from preventing your progress. Install the Aptos CLI & run your local node/faucet:

```bash
brew install aptos # only if necessary
aptos node run-local-testnet --with-faucet
```

In another terminal, run the following:

```bash
export APTOS_NODE_URL=http://0.0.0.0:8080/v1
export APTOS_FAUCET_URL=http://0.0.0.0:8081
```

You'll also have the option of entering these as prompts of the script, but the environment variable is preferred because it's easier to run multiple times. It's time to deploy our own Econia Faucet to the local chain:

```bash
git clone https://github.com/econia-labs/econia.git # only if necessary
cd ./econia/src/move/faucet
aptos init --profile econia_faucet_deploy # enter "local" for the chain
export FAUCET_ADDR=<ADDR-FROM-ABOVE>
# deploy the faucet (all one command)
aptos move publish \
        --named-addresses econia_faucet=$FAUCET_ADDR \
        --profile econia_faucet_deploy \
        --assume-yes
```

We also need to deploy an Econia exchange:
```bash
cd ./econia/src/move/econia
aptos init --profile econia_exchange_deploy # enter "local" for the chain
export ECONIA_ADDR=<ADDR-FROM-ABOVE>
# deploy the faucet (all one command)
aptos move publish \
        --override-size-check \
        --included-artifacts none \
        --named-addresses econia=$ECONIA_ADDR \
        --profile econia_exchange_deploy \
        --assume-yes
```

It's to run the script! Setting our environment variables will have cleared the initial setup prompts for us. In order to run, install Poetry then install dependencies and run the script:

```bash
curl -sSL https://install.python-poetry.org | python3 - # only if necessary
cd ./econia/src/python/sdk && poetry install # only if necessary
poetry run trade # we're off to the races!
```

### Understanding the Example Script
