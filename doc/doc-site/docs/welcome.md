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
    <img width={240} src="/img/CodeIllustration.svg" />
</div>

<div className="welcome-heading-mobile">
    <div style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "flex-start",
    }}>
        <h2 style={{ marginBottom: "40px" }}>Welcome</h2>
        <img width={94} src="/img/CodeIllustration.svg" />
    </div>
    <img height={68} width={432} src="/img/EconiaBanner.svg" />
    <p style={{ marginTop: "20px" }}>e·co·ni·a | /ə'känēə/</p>
</div>

Welcome to the developer documentation site for Econia, a hyper-parallelized on-chain order book for the [Aptos] blockchain.

If you haven't already, consider checking out Econia Labs' [Teach yourself Move on Aptos] guide for some helpful background information!

## What is Econia?

Econia is a protocol that lets anyone in the world trade a digital asset with anyone else in the world, at whatever price they want.
More specifically, Econia is an order book, a fundamental financial tool utilized by financial institutions like stock markets, except unlike the New York Stock Exchange or the NASDAQ, Econia is decentralized, open-source, and permissionless.

## Econia v4 is audited

Econia has completed [three independent audits].

## Testnet account

As of 2023-04-21, Econia is initialized on the Aptos Testnet as follows:

| Field      | Value                                                                |
| ---------- | -------------------------------------------------------------------- |
| Account    | [0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135] |
| Public key | `0x91a50d9a266133c1921bb3be982af33eae1c661a1ae80fafde8f46d1fddcd2d2` |

## Mainnet account

As of 2023-06-05, Econia is initialized on the Aptos Mainnet as follows:

| Field   | Value                                                                |
| ------- | -------------------------------------------------------------------- |
| Account | [0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c] |

Since Econia is deployed on mainnet under an [Aptos multisig v2] account, it does not have a public key.

If you would like to use the Econia mainnet deployment as a dependency in your Move package, use the [`mainnet-dependency` branch] in your package's `Move.toml`:

```toml
[dependencies.Econia]
git = "https://github.com/econia-labs/econia"
subdir = "src/move/econia"
rev = "mainnet-dependency"
```

## External resources

- [Discord]
- [GitHub]
- [Medium]
- [Twitter]

[0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135]: https://explorer.aptoslabs.com/account/0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135?network=testnet
[0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c]: https://aptos-explorer.netlify.app/account/0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c/transactions?network=mainnet
[aptos]: https://aptos.dev
[aptos multisig v2]: https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-framework/sources/multisig_account.move
[discord]: https://discord.gg/econia
[github]: https://github.com/econia-labs/econia
[medium]: https://medium.com/econialabs
[teach yourself move on aptos]: https://github.com/econia-labs/teach-yourself-move
[three independent audits]: security
[twitter]: https://twitter.com/econialabs
[`mainnet-dependency` branch]: https://github.com/econia-labs/econia/tree/mainnet-dependency
