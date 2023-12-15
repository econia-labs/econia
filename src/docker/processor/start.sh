#!/bin/bash

if [[ "$HEALTHCHECK_BEFORE_START" == "true" ]];then
    while true; do
        curl -f streamer:8090

        if [ $? -eq 0 ]; then
            break
        else
            echo "THE STREAMER IS NOT READY!!!!"
            sleep 1
        fi
    done
fi

psql $DATABASE_URL -c '\copy processor_status to out.csv csv'

if [ -s "out.csv" ];then
    sed -i "s/starting_version: *[0-9]\+/starting_version: $(cut -d, -f2 out.csv)/g" /config/data/config.yaml
fi

/usr/local/bin/processor -c /config/data/config.yaml
