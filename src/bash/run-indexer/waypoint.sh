#!/bin/bash

if [ "$1" == "dev" ]; then
    curl "https://github.com/aptos-labs/aptos-networks/raw/main/devnet/waypoint.txt" -o waypoint.txt
elif [ "$1" == "test" ]; then
    curl "https://github.com/aptos-labs/aptos-networks/raw/main/testnet/waypoint.txt" -o waypoint.txt
elif [ "$1" == "main" ]; then
    curl "https://github.com/aptos-labs/aptos-networks/raw/main/mainnet/waypoint.txt" -o waypoint.txt
else
    echo "Invalid environment specified: $1. Please provide 'dev', 'test', or 'main' as the first argument."
    exit 1
fi