FROM jiangydev/aptos-cli:v1.0.7 as genesis
WORKDIR /root
COPY ./src/move/ .

WORKDIR /root/chain
RUN aptos node run-local-testnet --with-faucet & sleep 30

WORKDIR /root/faucet
RUN aptos init \
      --profile econia_faucet_deploy \
      --private-key-file ./dev_key \
      --network local
RUN aptos move publish \
      --named-addresses econia_faucet=$(cat ./dev_key.acc) \
      --profile econia_faucet_deploy \
      --assume-yes

WORKDIR /root/econia
RUN aptos init \
      --profile econia_exchange_deploy \
      --private-key-file ./dev_key \
      --network local
RUN aptos move publish \
      --override-size-check \
      --included-artifacts none \
      --named-addresses econia=$(cat ./dev_key.acc) \
      --profile econia_exchange_deploy \
      --assume-yes