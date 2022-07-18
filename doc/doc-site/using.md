# Using Econia

## Core initialization

Before anyone can trade on Econia, it must first be initialized ([`Econia::Init::init_econia()`](../../src/move/econia/build/Econia/docs/Init.md#0xc0deb00c_Init_init_econia)) by the account that published its bytecode to the Aptos blockchain.
For now this will be taking place on the Aptos devnet (which is reset about once weekly), so monitor the [welcome page](welcome.md#Devnet-account) for the most up-to-date Econia devnet account.
After Econia has been initialized, users may interact with it through the following public script functions:

## Public script functions

Don't forget to read the [system overview](https://econia.dev/design-overview) for a quick explanation of how Econia works!

### User initialization

[`Econia::User::init_user()`](../../src/move/econia/build/Econia/docs/Init.md#0xc0deb00c_User_init_user) sets up a user for trading on Econia

### Market registration

[`Econia::Registry::register_market()`](../../src/move/econia/build/Econia/docs/Init.md#0xc0deb00c_Registry_register_market) registers a market in the Econia registry, if it has not already been registered, and moves an order book to the account of the host who registered it