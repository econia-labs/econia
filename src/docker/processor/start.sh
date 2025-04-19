#!/bin/bash

psql $DATABASE_URL -c '\copy processor_status to /app/out.csv csv'

if [ -s "/app/out.csv" ];then
    export STARTING_VERSION=$(cut -d, -f2 /app/out.csv)
fi

rm /app/out.csv

echo "health_check_port: 8085
server_config:
  postgres_config:
    connection_string: $DATABASE_URL
  transaction_stream_config:
    request_name_header: econia
    indexer_grpc_data_service_address: $GRPC_DATA_SERVICE_URL
    auth_token: $GRPC_AUTH_TOKEN
    starting_version: $STARTING_VERSION" > /app/config.yaml

/usr/local/bin/processor -c /app/config.yaml
