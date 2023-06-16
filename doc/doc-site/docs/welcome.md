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

The [Econia repo] uses branches to track the Move package source code published across Aptos Mainnet, Testnet, and Devnet:

| Chain     | Account address                                                      | Multisig? |
| --------- | -------------------------------------------------------------------- | --------- |
| [mainnet] | [0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c] | Yes       |
| [testnet] | [0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135] | No        |
| [devnet]  | [0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74] | Yes       |

If you would like to use Econia as a dependency in your Move package, use the corresponding branch name in your package's `Move.toml`:

```toml
[dependencies.Econia]
git = "https://github.com/econia-labs/econia"
subdir = "src/move/econia"
rev = "mainnet"
```

:::caution
The Econia Testnet account will soon be migrated from a single-signer account to a multisig (with a different address), to ensure similar conditions to mainnet.
:::

:::tip
Aptos Devnet resets about once weekly, and there may be a slight delay between a weekly reset and the re-publication of Econia.
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
[devnet]: https://github.com/econia-labs/econia/tree/devnet
[discord]: https://discord.gg/econia
[econia repo]: https://github.com/econia-labs/econia
[github]: https://github.com/econia-labs/econia
[mainnet]: https://github.com/econia-labs/econia/tree/mainnet
[medium]: https://medium.com/econialabs
[teach yourself move on aptos]: https://github.com/econia-labs/teach-yourself-move
[testnet]: https://github.com/econia-labs/econia/tree/testnet
[three independent audits]: security
[twitter]: https://twitter.com/econialabs
