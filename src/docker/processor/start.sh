#!/bin/bash

while true; do
    timeout 10 grpcurl -format json -d '{ "starting_version": 0 }' -H x-aptos-data-authorization:dummy_token -plaintext streamer:50051 aptos.indexer.v1.RawData/GetTransactions

    if [ $? -eq 124 ]; then
        break
    else
        echo "THE STREAMER IS NOT READY!!!!"
        sleep 1
    fi
done

/usr/local/bin/processor -c /config.yaml