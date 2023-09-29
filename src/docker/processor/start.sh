#!/bin/bash

while true; do
    curl -f streamer:8090

    if [ $? -eq 0 ]; then
        break
    else
        echo "THE STREAMER IS NOT READY!!!!"
        sleep 1
    fi
done

/usr/local/bin/processor -c /config.yaml