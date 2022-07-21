# System integration

## Friend-like capabilities

As described in the [`Econia::Caps` module documentation](../../../src/move/econia/build/Econia/docs/Caps.md), Econia uses friend-like capabilities to circumvent testing difficulties that may arise when attempting to declare a friend modules.
Basically this is to allow for coverage testing on certain modules when it is possible to implement them without using `aptos_framework` functionality, pending the resolution of [aforementioned pull requests](philosophy.md#Testing).
Moreover, friend-like capabilities provide extensible access control that can be used to avoid dependency cycles, for example like that which was detected between `Econia::Match` and `Econia::User` during development.
Friend-like capabilities can only be administered by Econia modules to other Econia modules, at least as of the time of this writing.

## Version number

As described in the [`Econia::Version` module documentation](../../../src/move/econia/build/Econia/docs/Version.md), Econia implements a mock version number getter, pending a resolution to `aptos-core` [#1975](https://github.com/aptos-labs/aptos-core/issues/1975).

## Sequence number

Each user has a sequence number counter [`Econia::User::SC`](../../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_SC) that tracks the sequence number of their last monitored Econia transaction.
When users submit certain transactions like a limit order, the value in their counter is compared with the current sequence number, and the transaction aborts if the current sequence number is not larger than the counter value (per [`Econia::User::update_s_c()`](../../../src/move/econia/build/Econia/docs/User.md#0xc0deb00c_User_update_s_c))
This is to prevent users from submitting orders on multiple markets within a single transaction, an operation that could potentially break parallelism.
In future versions, this constraint may be lifted it cross-market transaction collisions can be prevented by other means.

## Core resource initialization

Before trades can be placed, Econia's core account resources must be initialized per [`Econia::Init::init_econia()`](../../../src/move/econia/build/Econia/docs/Init.md#0xc0deb00c_Init_init_econia).