# Indexer gRPC image based on Aptos Core docker file.
FROM debian:bookworm-slim

# Install build dependencies.
RUN apt-get update && apt-get --no-install-recommends install -y \
        ca-certificates \
        curl \
        iproute2 \
        libpq-dev \
        libssl1.1 \
        net-tools \
        netcat \
        tcpdump \
    && rm -rf /var/lib/apt/lists/*

# Copy over relevant binaries.
COPY --from=aptos-builder /aptos-indexer-grpc-cache-worker /usr/local/bin/
COPY --from=aptos-builder /aptos-indexer-grpc-file-store /usr/local/bin/
COPY --from=aptos-builder /aptos-indexer-grpc-data-service /usr/local/bin/
COPY --from=aptos-builder /aptos-indexer-grpc-post-processor /usr/local/bin/

# The health check port.
EXPOSE 8080
# The gRPC non-TLS port.
EXPOSE 50051
# The gRPC TLS port.
EXPOSE 50052

# Specify logging format.
ENV RUST_LOG_FORMAT=json