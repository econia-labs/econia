#!/bin/bash

dockerd &

sleep 10

poetry run python indexer_grpc_local.py start

# Deploy contract here

# So that the container doesn't stop
tail -f /dev/null
