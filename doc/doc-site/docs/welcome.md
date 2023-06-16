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

## Account addresses

| Chain   | Account address                                                      | Multisig? | Commit (tag)                     |
| ------- | -------------------------------------------------------------------- | --------- | -------------------------------- |
| Mainnet | [0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c] | Yes       | [`8148afe`] ([`v4.0.2-audited`]) |
| Testnet | [0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135] | No        | [`c79e58e`]                      |
| Devnet  | [0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74] | Yes       | [`647c3d4a`]                     |

If you would like to use the Econia Mainnet deployment as a dependency in your Move package, use the [`mainnet-dependency` branch] in your package's `Move.toml`:

```toml
[dependencies.Econia]
git = "https://github.com/econia-labs/econia"
subdir = "src/move/econia"
rev = "mainnet-dependency"
```

:::tip
Aptos Devnet resets about once weekly, and there may be a slight delay between a weekly reset and the re-publication of Econia.
:::

:::caution
The Econia Testnet account will soon be migrated from a single-signer account to a multisig (with a different address), to ensure similar conditions to mainnet.
:::

## External resources

- [Discord]
- [GitHub]
- [Medium]
- [Twitter]

[0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135]: https://explorer.aptoslabs.com/account/0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135?network=testnet
[0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74]: https://explorer.aptoslabs.com/account/0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74?network=devnet
[0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c]: https://aptos-explorer.netlify.app/account/0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c/transactions?network=mainnet
[aptos]: https://aptos.dev
[discord]: https://discord.gg/econia
[github]: https://github.com/econia-labs/econia
[medium]: https://medium.com/econialabs
[teach yourself move on aptos]: https://github.com/econia-labs/teach-yourself-move
[three independent audits]: security
[twitter]: https://twitter.com/econialabs
[`647c3d4a`]: https://github.com/econia-labs/econia/commit/647c3d4a
[`8148afe`]: https://github.com/econia-labs/econia/commit/8148afe8c2fe4a298ef6fa2990d10b813ff0cd54
[`c79e58e`]: https://github.com/econia-labs/econia/commit/c79e58e
[`mainnet-dependency` branch]: https://github.com/econia-labs/econia/tree/mainnet-dependency
[`v4.0.2-audited`]: https://github.com/econia-labs/econia/releases/tag/v4.0.2-audited
