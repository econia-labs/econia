# Faucet image based on Aptos Core docker file.
FROM debian:bookworm-slim

# Install build dependencies.
RUN apt-get update && apt-get --no-install-recommends install -y \
        ca-certificates \
        iproute2 \
        libssl-dev \
        nano \
        net-tools \
        netcat-traditional \
        tcpdump \
        procps \
    && rm -rf /var/lib/apt/lists/*

# Make directory specified in Aptos Core Dockerfile.
RUN mkdir -p /aptos/client/data/wallet/

# Copy over compiled binary.
COPY --from=aptos-builder /aptos-faucet-service /usr/local/bin/

# Mint proxy listening address.
EXPOSE 8000

# Specify logging format.
ENV RUST_LOG_FORMAT=json