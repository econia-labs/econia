# Econia wrapper demo

This package contains a demo Move wrapper, useful for combining multiple Econia Move operations into one.

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

- [Publication transaction](https://explorer.aptoslabs.com/txn/789995990?network=testnet)
- [Package deployment](https://explorer.aptoslabs.com/account/0x6a8134d4a23c44b7b8f0db989568825c155ccc6d020cc85224a188cd9b9d37c1/modules/code/cancel_and_place?network=testnet)

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

- [Successful transaction](https://explorer.aptoslabs.com/txn/790010705/events?network=testnet)
