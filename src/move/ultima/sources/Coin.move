// APT and USD coin minting/transfer functionality
module Ultima::Coin {
    use Std::Signer;

    // Errors
    const E_ALREADY_HAS_BALANCE: u64 = 0;
    const E_INVALID_AIRDROP: u64 = 1;
    const E_APT_NOT_PUBLISH_0: u64 = 2;
    const E_USD_NOT_PUBLISH_0: u64 = 3;
    const E_APT_AIRDROP_VAL: u64 = 4;
    const E_USD_AIRDROP_VAL: u64 = 5;

    // Coin type specifiers
    struct APT {}
    struct USD {}

    // Scale for converting subunits to decimal (base-10 exponent)
    // With a scale of 3, for example, 1 subunit = 0.001 base unit
    const APT_SCALE: u8 = 6;
    const USD_SCALE: u8 = 6;

    // Generic coin type
    struct Coin<phantom CoinType> has store {
        subunits: u64 // Indivisible subunits (e.g. Satoshi for BTC)
    }

    // Represents balance of given Coin Type
    struct Balance<phantom CoinType> has key {
        coin: Coin<CoinType>
    }

    // Publish empty balance resource under signer's account
    // Must be called before minting/transferring to the account
    public(script) fun publish_balance<CoinType>(
        account: &signer
    ) {
        let empty_coin = Coin<CoinType>{subunits: 0};
        assert!(
            !exists<Balance<CoinType>>(Signer::address_of(account)),
            E_ALREADY_HAS_BALANCE
        );
        move_to(account, Balance<CoinType>{coin: empty_coin});
    }

    // Publish both APT and USD balances under the signer's account
    public(script) fun publish_balances(
        account: &signer
    ) {
        publish_balance<APT>(account);
        publish_balance<USD>(account);
    }

    // Get balance of given coin type, in subunits, at an address
    public fun balance_of<CoinType>(
        addr: address
    ): u64
    acquires Balance {
        borrow_global<Balance<CoinType>>(addr).coin.subunits
    }

    // Deposit moved coin amount to a given address
    fun deposit<CoinType>(
        addr: address,
        coin: Coin<CoinType>
    ) acquires Balance {
        let balance_ref =
            &mut borrow_global_mut<Balance<CoinType>>(addr).coin.subunits;
        let balance = *balance_ref;
        // Destruct moved coin amount
        let Coin{subunits} = coin;
        *balance_ref = balance + subunits;
    }

    // Mint amount of given coin, in subunits, to address
    fun mint<CoinType>(
        addr: address,
        subunits: u64
    ) acquires Balance {
        deposit<CoinType>(addr, Coin<CoinType>{subunits});
    }

    // Mint APT and USD to a given address
    // May only be invoked by Ultima account
    public(script) fun airdrop(
        authority: &signer,
        addr: address,
        apt_subunits: u64,
        usd_subunits: u64
    ) acquires Balance {
        assert!(Signer::address_of(authority) == @Ultima, E_INVALID_AIRDROP);
        mint<APT>(addr, apt_subunits);
        mint<USD>(addr, usd_subunits);
    }

    // Verify airdrop deposits processed correctly
    #[test(
        user = @TestUser1,
        authority = @Ultima
    )]
    public(script) fun airdrop_deposit_amounts(
        user: signer,
        authority: signer,
    ) acquires Balance {
        publish_balances(&user);
        let user_addr = Signer::address_of(&user);
        airdrop(&authority, user_addr, 123, 456);
        assert!(balance_of<APT>(user_addr) == 123, E_APT_AIRDROP_VAL);
        assert!(balance_of<USD>(user_addr) == 456, E_USD_AIRDROP_VAL);
    }

    #[test(user = @TestUser1)]
    #[expected_failure(abort_code = 1)]
    public(script) fun airdrop_invalid_authority(
        user: signer
    ) acquires Balance {
        airdrop(&user, Signer::address_of(&user), 123, 456);
    }

    // Verify 0 holdings after publishing balance
    #[test(account = @TestUser1)]
    public(script) fun publish_balances_zero(
        account: signer
    ) acquires Balance {
        publish_balances(&account);
        let addr = Signer::address_of(&account);
        assert!(balance_of<APT>(addr) == 0, E_APT_NOT_PUBLISH_0);
        assert!(balance_of<USD>(addr) == 0, E_USD_NOT_PUBLISH_0);
    }

    // Verify abort for publishing balances twice
    #[test(account = @TestUser1)]
    #[expected_failure(abort_code = 0)]
    public(script) fun publish_twice_aborts(
        account: signer
    ) {
        publish_balance<APT>(&account);
        publish_balance<APT>(&account);
    }
}