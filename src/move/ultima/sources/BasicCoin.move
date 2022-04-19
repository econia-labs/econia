/*
Adapted from official Move tutorial:
https://github.com/move-language/move/tree/main/language/documentation/tutorial
From step 6 onward

Defines a minimal and generic Coin with Balance
*/
module Ultima::BasicCoin {
    use Std::Errors;
    use Std::Signer;

    // Error codes
    const E_NOT_MODULE_OWNER: u64 = 0;
    const E_INSUFFICIENT_BALANCE: u64 = 1;
    const E_ALREADY_HAS_BALANCE: u64 = 2;

    struct Coin<phantom CoinType> has store {
        value: u64
    }

    struct Balance<phantom CoinType> has key {
        coin: Coin<CoinType>
    }

    /*
    Pubish an empty balance resrouce under `account`'s address. Must be
    called before minting/transferring to the account
    */
    public fun publish_balance<CoinType>(account: &signer) {
        let empty_coin = Coin<CoinType> { value: 0 };
        assert!(
            !exists<Balance<CoinType>>(Signer::address_of(account)),
            Errors::already_published(E_ALREADY_HAS_BALANCE)
        );
        move_to(account, Balance<CoinType> { coin: empty_coin });
    }

    /*
    Mint `amount` tokens to `mint_addr`. Requires witness with
    `CoinType` so that modules that owns `CoinType` can decide minting
    policy
    */
    public fun mint<CoinType: drop>(
        mint_addr: address, amount: u64, _witness: CoinType) acquires
        Balance {
        deposit(mint_addr, Coin<CoinType> { value: amount });
    }

    public fun balance_of<CoinType>(owner: address): u64 acquires Balance {
        borrow_global<Balance<CoinType>>(owner).coin.value
    }

    /*
    Transfers `amount` of tokens from `from` to `to`. Requires a witness
    with `CoinType` so that module that owns `CoinType` can decide
    transfer policy
    */
    public fun transfer<CoinType: drop>(
        from: &signer,
        to: address,
        amount: u64,
        _witness: CoinType
    ) acquires Balance {
        let check = withdraw<CoinType>(Signer::address_of(from), amount);
        deposit<CoinType>(to, check);
    }

    fun withdraw<CoinType>(
        addr: address,
        amount: u64
    ): Coin<CoinType>
    acquires Balance {
        let balance = balance_of<CoinType>(addr);
        assert!(balance >= amount, E_INSUFFICIENT_BALANCE);
        let balance_ref =
            &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin<CoinType> { value: amount }
    }

    fun deposit<CoinType>(
        addr: address,
        check: Coin<CoinType>
    ) acquires Balance {
        let balance = balance_of<CoinType>(addr);
        let balance_ref =
            &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        let Coin { value } = check;
        *balance_ref = balance + value;
    }
}