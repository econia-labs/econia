# Testnet competition throttler

This Move package defines a throttler for the Econia testnet trading competition.

It provides public functions that can be added to Econia and to the Econia faucet through an on-chain upgrade, then reverted with a subsequent on-chain upgrade.

The `SCREAMING_SNAKE_CASE` constants referenced below are defined at the top of `sources/throttle.move`.

## Applicability

- Throttling only applies to `THROTTLED_MARKET_ID`.
- Throttling does not apply to exempt accounts.
- Throttling only applies when the throttler is active.
- An admin has exclusive permission to deactivate/reactivate the throttler, and to add/remove accounts from the exempt accounts list.

## Minting

- A user must wait `WAIT_TIME_IN_SECONDS` between each `eAPT` mint.
- A user must wait `WAIT_TIME_IN_SECONDS` between each `eUSDC` mint.
- A user may only mint up to `MAX_TRANSFER_APT` at each `eAPT` mint.
- A user may only mint up to `MAX_TRANSFER_USDC` at each `eUSDC` mint.

## Depositing (optional)

- A user must wait `WAIT_TIME_IN_SECONDS` between each `eAPT` deposit into their Econia market account.
- A user must wait `WAIT_TIME_IN_SECONDS` between each `eUSDC` deposit into their Econia market account.
- A user may only deposit up to `MAX_TRANSFER_APT` at each `eAPT` deposit.
- A user may only deposit up to `MAX_TRANSFER_USDC` at each `eUSDC` deposit.

## Trading

- A user may only trade up to `MAX_TRADE_VOLUME_APT` in a single trade.

## Errors

If a user violates a mint, deposit, or trading rule, the throttler will respond with one of the error codes defined at the top of `sources/throttle.move`.

## View functions

- Assorted view functions can be accessed via https://explorer.aptoslabs.com/account/0xd000000d7cfcb4964a12ed895d2ecb2d57615f28047d4edec9fc61490eb775ce/modules/view/throttle/?network=testnet.
- These view functions can be accessed from directly inside the explorer UI.
