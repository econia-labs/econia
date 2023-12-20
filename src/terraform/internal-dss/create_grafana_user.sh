#!/bin/bash

# Create a PostgreSQL data source
curl "http://admin:$ADMIN_PASSWORD@$GRAFANA_HOST:$GRAFANA_PORT/api/datasources" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    --data "{\"name\":\"DSS Database\",\"type\":\"postgres\",\"url\":\"$DATABASE_HOST:$DATABASE_PORT\",\"access\":\"proxy\",\"user\":\"$DATABASE_USER\",\"password\":\"$DATABASE_PASSWORD\",\"jsonData\": {\"database\":\"$DATABASE_DB\",\"sslmode\":\"disable\",\"postgresVersion\":1500}}"

# Create a public user
curl "http://admin:$ADMIN_PASSWORD@$GRAFANA_HOST:$GRAFANA_PORT/api/admin/users" \
    -X POST \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    --data "{\"name\":\"public\",\"email\":\"$PUBLIC_USER_EMAIL\",\"login\":\"public\",\"password\":\"$PUBLIC_USER_PASSWORD\",\"OrgId\":1}"
