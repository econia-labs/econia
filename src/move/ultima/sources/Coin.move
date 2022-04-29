// APT and USD coin minting/transfer functionality
module Ultima::Coin {
    use Std::Signer;

    // Errors
    const E_ALREADY_HAS_BALANCE: u64 = 0;
    const E_INVALID_AIRDROP: u64 = 1;

    // Coin type specifiers
    struct APT {}
    struct USD {}

    // Scale for converting subunits to decimal (base-10 exponent)
    // With a scale of 3, for example, 1 subunit = 0.001 base unit
    const APT_SCALE: u8 = 6;
    const USD_SCALE: u8 = 6;

    // Generic coin type
    struct UltimaCoin<phantom CoinType> has store {
        subunits: u64 // Indivisible subunits (e.g. Satoshi for BTC)
    }

    // Represents balance of each address
    struct Balance<phantom CoinType> has key {
        coin: UltimaCoin<CoinType>
    }

    // Publish empty balance resource under signer's account
    // Must be called before minting/transferring to the account
    public(script) fun publish_balance<CoinType>(
        account: &signer
    ) {
        let empty_coin = UltimaCoin<CoinType>{subunits: 0};
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
        coin: UltimaCoin<CoinType>
    ) acquires Balance {
        let balance_ref =
            &mut borrow_global_mut<Balance<CoinType>>(addr).coin.subunits;
        let balance = *balance_ref;
        // Destruct moved coin amount
        let UltimaCoin{subunits} = coin;
        *balance_ref = balance + subunits;
    }

    // Mint amount of given coin, in subunits, to address
    fun mint<CoinType>(
        addr: address,
        subunits: u64
    ) acquires Balance {
        deposit<CoinType>(addr, UltimaCoin<CoinType>{subunits});
    }

    // Mint APT and USD UltimaCoin to a given address
    // May only be invoked by Ultima account
    public(script) fun airdrop(
        account: &signer,
        addr: address,
        apt_subunits: u64,
        usd_subunits: u64
    ) acquires Balance {
        assert!(Signer::address_of(account) == @Ultima, E_INVALID_AIRDROP);
        mint<APT>(addr, apt_subunits);
        mint<USD>(addr, usd_subunits);
    }
}