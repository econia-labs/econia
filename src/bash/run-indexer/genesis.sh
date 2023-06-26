#!/bin/bash

if [ "$1" == "dev" ]; then
    curl "https://github.com/aptos-labs/aptos-networks/raw/main/devnet/genesis.blob" -o genesis.blob
elif [ "$1" == "test" ]; then
    curl "https://github.com/aptos-labs/aptos-networks/raw/main/testnet/genesis.blob" -o genesis.blob
elif [ "$1" == "main" ]; then
    curl "https://github.com/aptos-labs/aptos-networks/raw/main/mainnet/genesis.blob" -o genesis.blob
else
    echo "Invalid environment specified: $1. Please provide 'dev', 'test', or 'main' as the first argument."
    exit 1
fi