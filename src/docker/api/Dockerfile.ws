FROM haskell:9.2.6-slim as builder

# Install System Dependencies
RUN apt-get update \
    && apt-get install -y \
        libpq-dev \
        wget \
        git \
        build-essential \
        libffi-dev \
        libgmp-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone the Repository
WORKDIR /app
RUN git clone https://github.com/diogob/postgres-websockets.git

# Build the Project from source using the resolver it specifies
# https://github.com/diogob/postgres-websockets/tree/master#building-from-source
# https://github.com/diogob/postgres-websockets/blob/master/stack.yaml
WORKDIR /app/postgres-websockets
RUN stack setup
RUN stack install --resolver lts-20.12

# Lightweight Final Image
FROM debian:bullseye-slim

# Install Runtime Dependencies
RUN apt-get update \
    && apt-get install -y \
        libpq-dev \
        libgmp-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the Binary from the Builder
COPY --from=builder /root/.local/bin/postgres-websockets /usr/local/bin/postgres-websockets

# Set the Entry Point
ENTRYPOINT ["postgres-websockets"]