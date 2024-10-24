# Econia wrapper demo

This package contains a demo Move wrapper, useful for combining multiple Econia
Move operations into one.

## Publishing the package

Setting shell variables:

```sh
ECONIA=<ECONIA_ADDRESS>
WRAPPER_PUBLISHER=<WRAPPER_PUBLISHER>
WRAPPER_PUBLISHER_SECRET=<WRAPPER_PUBLISHER_SECRET>
NODE_URL=<APTOS_NODE_URL>
```

Publishing the Move package (run from inside this directory):

```sh
aptos move publish \
    --named-addresses econia=$ECONIA,wrapper_publisher=$WRAPPER_PUBLISHER \
    --private-key $WRAPPER_PUBLISHER_SECRET \
    --url $NODE_URL
```

Results:

- [Initial publication transaction (`v0.1.0`)]
- [Package `v0.2.0` re-publication]
- [Package deployment]

## Invoking a transaction:

Setting additional shell variables:

```sh
USER_SECRET=<USER_SECRET>
ECONIA_FAUCET_ADDR=0xc0de11113b427d35ece1d8991865a941c0578b0f349acabbe9753863c24109ff
```

Invoking a wrapper (once it is already published):

```sh
aptos move run \
    --function-id $WRAPPER_PUBLISHER::cancel_and_place::cancel_and_place \
    --type-args \
        $ECONIA_FAUCET_ADDR::example_apt::ExampleAPT \
        $ECONIA_FAUCET_ADDR::example_usdc::ExampleUSDC \
    --args \
        u64:3 \
        u128:'[69673519005926178638800656]' \
        u128:'[69673482136553082880791432, 69673500079406722930708884]' \
        u64:'[5001, 5002]' \
        u64:'[10001, 10002]' \
        u64:'[5003]' \
        u64:'[4501]' \
        address:"0x0" \
        u8:0 \
        u8:0 \
    --url $NODE_URL \
    --private-key $USER_SECRET
```

Results:

- [Successful transaction (order IDs to cancel are for open orders, `v0.1.0`)]
- [Successful transaction (order IDs to cancel are for closed orders), `v0.2.0`]
- [Successful transaction (order IDs to cancel are for open orders, `v0.2.0`)]

[Initial publication transaction (`v0.1.0`)]: https://explorer.aptoslabs.com/txn/789995990?network=testnet
[Package deployment]: https://explorer.aptoslabs.com/account/0x6a8134d4a23c44b7b8f0db989568825c155ccc6d020cc85224a188cd9b9d37c1/modules/code/cancel_and_place?network=testnet
[Package `v0.2.0` re-publication]: https://explorer.aptoslabs.com/txn/6175261891?network=testnet
[Successful transaction (order IDs to cancel are for open orders, `v0.1.0`)]: https://explorer.aptoslabs.com/txn/790010705/events?network=testnet
[Successful transaction (order IDs to cancel are for closed orders), `v0.2.0`]: https://explorer.aptoslabs.com/txn/0x7dc56f6f46bf6ca06b5d94eb06cf2be7b865f000da63fd6398412fb889dcb95d/events?network=testnet
[Successful transaction (order IDs to cancel are for open orders, `v0.2.0`)]: https://explorer.aptoslabs.com/txn/0x276adc25fecb975b51272a44d7f8596ba4fb4f4467178ac26a912e7f7086c595/events?network=testnet