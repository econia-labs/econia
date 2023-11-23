---
slug: /
title: Welcome
hide_title: true
description: Documentation for the Econia Protocol
---

<div className="welcome-heading">
    <div>
        <h2 style={{ marginBottom: "40px" }}>Welcome</h2>
        <img height={68} width={432} src="/img/EconiaBanner.svg" />
        <p style={{ marginTop: "20px" }}>e·co·ni·a | /ə'känēə/</p>
    </div>
    <img width={240} src="/img/CodeIllustration.png" />
</div>

<div className="welcome-heading-mobile">
    <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "flex-start",
    }}>
        <h2 style={{ marginBottom: "40px" }}>Welcome</h2>
        <img width={94} src="/img/CodeIllustration.png" />
    </div>
    <img height={68} width={432} src="/img/EconiaBanner.svg" />
    <p style={{ marginTop: "20px" }}>e·co·ni·a | /ə'känēə/</p>
</div>

Welcome to the developer documentation site for Econia, a hyper-parallelized on-chain order book for the [Aptos] blockchain.

If you haven't already, consider checking out Econia Labs' [Teach yourself Move on Aptos] guide for some helpful background information!

## What is Econia?

Econia is a protocol that lets anyone in the world trade a digital asset with anyone else in the world, at whatever price they want.
More specifically, Econia is an order book, a fundamental financial tool utilized by financial institutions like stock markets, except unlike the New York Stock Exchange or the NASDAQ, Econia is open-source, permissionless, and fully on-chain.

## Econia v4 is audited

Econia has completed multiple [independent audits].

## Account addresses

The Econia Move package is persisted indefinitely on both Aptos mainnet and testnet at the following multisig addresses:

| Chain     | Account address                                                      |
| --------- | -------------------------------------------------------------------- |
| [mainnet] | [0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c] |
| [testnet] | [0xc0de11113b427d35ece1d8991865a941c0578b0f349acabbe9753863c24109ff] |

:::tip

The testnet account also contains a [permissionless faucet] for example assets `eAPT` and `eUSDC`.

:::

If you would like to use Econia as a dependency in your Move package, use the corresponding branch name in your package's `Move.toml`:

```toml
[dependencies.Econia]
git = "https://github.com/econia-labs/econia"
subdir = "src/move/econia"
rev = "mainnet"
```

## External resources

- [Discord]
- [GitHub]
- [Medium]
- [Twitter]

[0xc0de11113b427d35ece1d8991865a941c0578b0f349acabbe9753863c24109ff]: https://explorer.aptoslabs.com/account/0xc0de11113b427d35ece1d8991865a941c0578b0f349acabbe9753863c24109ff?network=testnet
[0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c]: https://explorer.aptoslabs.com/account/0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c?network=mainnet
[aptos]: https://aptos.dev
[discord]: https://discord.gg/econia
[github]: https://github.com/econia-labs/econia
[independent audits]: security
[mainnet]: https://github.com/econia-labs/econia/tree/mainnet
[medium]: https://medium.com/econialabs
[permissionless faucet]: https://github.com/econia-labs/econia/tree/v4.1.0-audited/src/move/faucet/sources
[teach yourself move on aptos]: https://github.com/econia-labs/teach-yourself-move
[testnet]: https://github.com/econia-labs/econia/tree/testnet
[twitter]: https://twitter.com/econialabs
