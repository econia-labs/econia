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
    export STARTING_VERSION=$(cut -d, -f2 out.csv)
fi

echo "health_check_port: 8085
server_config:
  processor_config:
    type: econia_transaction_processor
    econia_address: $ECONIA_ADDRESS
  postgres_connection_string: $DATABASE_URL
  indexer_grpc_data_service_address: $GRPC_DATA_SERVICE_URL
  indexer_grpc_http2_ping_interval_in_secs: 60
  indexer_grpc_http2_ping_timeout_in_secs: 10
  auth_token: $GRPC_AUTH_TOKEN
  number_concurrent_processing_tasks: 1
  starting_version: $STARTING_VERSION" > /app/config.yaml

/usr/local/bin/processor -c /app/config.yaml
