# Validator image based on Aptos Core docker file.
FROM debian:bookworm-slim

# Install build dependencies.
RUN apt-get update && apt-get --no-install-recommends install -y \
        ca-certificates \
        curl \
        gdb \
        libpq-dev \
        libssl-dev \
        linux-perf \
        procps \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Symlink perf as specified in Aptos Core dockerfile.
RUN ln -sf /usr/bin/perf_* /usr/bin/perf

# Add groups and users specified in Aptos Core Dockerfile.
RUN addgroup --system --gid 6180 aptos
RUN adduser --system --ingroup aptos --no-create-home --uid 6180 aptos

# Make directory specified in Aptos Core dockerfile.
RUN mkdir -p /opt/aptos/etc

# Copy over relevant binaries.
COPY --from=aptos-builder /aptos-node /usr/local/bin/
COPY --from=aptos-builder /aptos-db-tool /usr/local/bin/
COPY --from=aptos-builder /aptos-db-bootstrapper /usr/local/bin/

# Admission control.
EXPOSE 8000
# Validator network.
EXPOSE 6180
# Metrics.
EXPOSE 9101
# Backup.
EXPOSE 6186

# Capture backtrace on error.
ENV RUST_BACKTRACE 1
# Specify logging format.
ENV RUST_LOG_FORMAT=json