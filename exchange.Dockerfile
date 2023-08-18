FROM jiangydev/aptos-cli:v1.0.7 as genesis
RUN aptos update
RUN apt-get update -y && apt-get install -y git

WORKDIR /root
COPY ./src/move/ .

WORKDIR /root/chain
WORKDIR /root/econia
RUN aptos node run-local-testnet --with-faucet --test-dir /root/chain \
    & sleep 30 \
    && aptos init \
      --profile econia_exchange_deploy \
      --private-key-file ./dev_key \
      --network local \
    && aptos move publish \
      --override-size-check \
      --included-artifacts none \
      --named-addresses econia=$(cat ./dev_key.acc) \
      --profile econia_exchange_deploy \
      --assume-yes

WORKDIR /root/faucet
RUN aptos node run-local-testnet --with-faucet --test-dir /root/chain \
    & sleep 30 \
    && aptos init \
      --profile econia_faucet_deploy \
      --private-key-file ./dev_key \
      --network local \
    && aptos move publish \
      --named-addresses econia_faucet=$(cat ./dev_key.acc) \
      --profile econia_faucet_deploy \
      --assume-yes

FROM genesis as runner
WORKDIR /root/chain
COPY --from=genesis /root/chain /root/chain

EXPOSE 8080
EXPOSE 8081
CMD aptos node run-local-testnet --with-faucet --test-dir /root/chain