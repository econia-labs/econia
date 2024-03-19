#!/bin/bash

psql $DATABASE_URL -c '\copy processor_status to /app/out.csv csv'

if [ -s "/app/out.csv" ];then
    export STARTING_VERSION=$(cut -d, -f2 /app/out.csv)
fi

rm /app/out.csv

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
