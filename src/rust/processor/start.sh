#!/bin/sh

echo "health_check_port: 8084
server_config:
  postgres_config:
    connection_string: $DATABASE_URL
  transaction_stream_config:
    request_name_header: emojicoin
    indexer_grpc_data_service_address: $GRPC_DATA_SERVICE_URL
    auth_token: $GRPC_AUTH_TOKEN
    starting_version: $MINIMUM_STARTING_VERSION" > /app/config.yaml

psql "$DATABASE_URL" -c "SELECT * FROM processor_status" || ( echo "No database found, initializing." && psql "$DATABASE_URL" -f /db.sql )

/usr/local/bin/processor --config-path /app/config.yaml
