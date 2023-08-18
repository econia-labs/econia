# About

This Dockerfile uses `brew` to install the `aptos` CLI in a simple image.
Once you've built the image, you can use it to run a container with a fresh local testnet.

# Build image

```bash
docker build --tag aptos-cli .
```

# Run container

```bash
docker run \
    --name local-testnet \
    --publish 8080:8080 \
    --publish 8081:8081 \
    aptos-cli
```

# Connect to the testnet

Once the testnet and faucet have started up, you can access the testnet REST API on port 8080 and the faucet on port 8081:

```bash
aptos init --profile local --rest-url http://localhost:8080 --faucet-url http://localhost:8081
```

# Stop the local testnet

```bash
docker stop local-testnet
```
