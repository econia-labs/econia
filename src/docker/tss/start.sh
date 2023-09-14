#!/bin/bash

dockerd &

sleep 10

export DOCKER_DEFAULT_PLATFORM=linux/amd64

poetry run python indexer_grpc_local.py start

aptos init \
  --assume-yes \
  --network local \
  --private-key-file /app/accounts/econia.key \
  --profile econia

aptos move publish \
  --assume-yes \
  --included-artifacts none \
  --named-addresses econia=$(cat /app/accounts/econia.address) \
  --override-size-check \
  --package-dir /app/econia \
  --profile econia

aptos init \
  --assume-yes \
  --network local \
  --private-key-file /app/accounts/faucet.key \
  --profile faucet

aptos move publish \
  --assume-yes \
  --included-artifacts none \
  --named-addresses econia_faucet=$(cat /app/accounts/faucet.address) \
  --override-size-check \
  --package-dir /app/faucet \
  --profile faucet

# So that the container doesn't stop
tail -f /dev/null
