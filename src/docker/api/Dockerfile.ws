FROM debian:stable-slim

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

ENV PATH="/root/.local/bin:$PATH"
WORKDIR /app
RUN wget -qO- https://get.haskellstack.org/ | sh
RUN git clone https://github.com/diogob/postgres-websockets.git
WORKDIR /app/postgres-websockets
RUN stack setup
RUN stack install
ENTRYPOINT ["postgres-websockets"]
