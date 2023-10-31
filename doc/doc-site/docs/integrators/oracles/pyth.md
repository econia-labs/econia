# Pyth Network

## Consume Pyth Network prices on Aptos

Aptos contracts can update and fetch Pyth prices using the Pyth Aptos package, which has been deployed on Mainnet.
The documented source code can be found [here](https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/aptos/contracts/sources/pyth.move).

## Use cases for Pyth with Econia

The core variable utilized by decentralized derivative exchanges, traditionally perpetual futures, is the oracle index price, which powers the exchange’s funding rate mechanism and liquidation engine.
Without a reliable and secure oracle provider, innovative on-chain platforms of this nature cannot be built.

By leveraging Pyth’s price data feeds to build these exchange components, and combining them with Econia’s hyper-parallelized order book to match and settle trades, developers can build a high performance perpetual derivatives trading platform.

### Perps components using Econia and Pyth

![](/img/pyth-econia-perps.png)

## Updating price feeds

The mechanism by which Pyth price feeds are updated on Aptos is explained [here](https://docs.pyth.network/documentation/pythnet-price-feeds).
The [pyth-aptos-js](https://github.com/pyth-network/pyth-crosschain/tree/main/target_chains/aptos/sdk/js) package can be used to fetch price feed update data, which can then be passed to the `pyth::update_price` on-chain function.

## Examples

- [Minimal on-chain contract](https://github.com/pyth-network/pyth-crosschain/blob/main/target_chains/aptos/examples/fetch_btc_price/sources/example.move) which updates and returns the Pyth BTC/USD price.
- [Full-stack React app and on-chain contract](https://github.com/pyth-network/pyth-crosschain/tree/main/target_chains/aptos/examples/mint_nft) which uses the `pyth-aptos-js` package to update the price used by the contract.
- [In-depth explanation](https://youtu.be/0b0RXi41pN0) of how Pyth works on Aptos and how to integrate Pyth data in your application.

## Networks

Pyth is currently deployed on Aptos Mainnet and Testnet.

## Addresses

When deploying contracts using Pyth, the [named addresses](https://move-language.github.io/move/address.html) `pyth`, `wormhole` and `deployer` need to be defined at compile time. These addresses are the same across both Testnet and Mainnet.

| Named Address | Value                                                                |
| ------------- | -------------------------------------------------------------------- |
| `pyth`        | `0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387` |
| `wormhole`    | `0x5bc11445584a763c1fa7ed39081f1b920954da14e04b32440cba863d03e19625` |
| `deployer`    | `0xb31e712b26fd295357355f6845e77c888298636609e93bc9b05f0f604049f434` |

`deployer` and `wormhole` are implementation details of the Pyth contract: you will not need to interact with these.

## Price feeds

| Network       | Available price Feeds                                                                                                        |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Aptos Testnet | [https://pyth.network/developers/price-feed-ids#aptos-testnet](https://pyth.network/developers/price-feed-ids#aptos-testnet) |
| Aptos Mainnet | [https://pyth.network/developers/price-feed-ids#aptos-mainnet](https://pyth.network/developers/price-feed-ids#aptos-mainnet) |

## Notable price feeds (testnet)

| Pair       | Price feed ID                                                        |
| ---------- | -------------------------------------------------------------------- |
| APT / USD  | `0x44a93dddd8effa54ea51076c4e851b6cbbfd938e82eb90197de38fe8876bb66e` |
| BTC / USD  | `0xf9c0172ba10dfa4d19088d94f5bf61d3b54d5bd7483a322a982e1373ee8ea31b` |
| ETH / USD  | `0xca80ba6dc32e08d06f1aa886011eed1d77c77be9eb761cc10d72b7d0a2fd57a6` |
| USDC / USD | `0x41f3625971ca2ed2263e78573fe5ce23e13d2558ed3f2e47ab0f84fb9e7ae722` |
| USDT / USD | `0x1fc18861232290221461220bd4e2acd1dcdfbc89c84092c93c18bdc7756c1588` |

## Links to Pyth docs

<div className="link-card-container">
    <a
        className="link-card"
        href="https://docs.pyth.network/documentation/how-pyth-works"
        target="_blank"
        rel="noopener noreferrer"
    >
        <span className="link-card-title">How Pyth works</span>
        <span className="link-card-description">Pyth is a protocol that allows market participan..</span>
    </a>
    <a
        className="link-card"
        href="https://docs.pyth.network/documentation/pythnet-price-feeds/aptos"
        target="_blank"
        rel="noopener noreferrer"
    >
        <span className="link-card-title">Pyth on Aptos</span>
        <span className="link-card-description">Consume Pyth Network prices in applications on A..</span>
    </a>
    <a
        className="link-card"
        href="https://docs.pyth.network/documentation/benchmarks"
        target="_blank"
        rel="noopener noreferrer"
    >
        <span className="link-card-title">Benchmarks on Pyth</span>
        <span className="link-card-description">Use historical Pyth price data in your applicati..</span>
    </a>
    <a
        className="link-card"
        href="https://docs.pyth.network/guides/how-to-create-tradingview-charts"
        target="_blank"
        rel="noopener noreferrer"
    >
        <span className="link-card-title">TradingView Integration</span>
        <span className="link-card-description">Integrate Pyth price feeds on your applicati...</span>
    </a>
</div>
