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
    const E_INSUFFICIENT_BALANCE: u64 = 6;
    const E_FAILED_TRANSFER: u64 = 7;
    const E_NOT_EMPTY: u64 = 8;
    const E_INVALID_REPORT: u64 = 9;
    const E_MODIFIED_VALUE: u64 = 10;

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

    // Return coin with 0 subunits, useful for initialization elsewhere
    public fun get_empty_coin<CoinType>():
    Coin<CoinType> {
        Coin<CoinType>{subunits: 0}
    }

    // Mint amount of given coin, in subunits, to address
    fun mint<CoinType>(
        addr: address,
        subunits: u64
    ) acquires Balance {
        deposit<CoinType>(addr, Coin<CoinType>{subunits});
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

    // Report number of subunits inside a coin
    public fun report_subunits<CoinType>(
        coin_ref: &Coin<CoinType>
    ): u64 {
        coin_ref.subunits
    }

    // Transfer specified amount from sender to recipient
    public(script) fun transfer<CoinType>(
        sender: &signer,
        recipient: address,
        amount: u64
    ) acquires Balance {
        deposit<CoinType>(
            recipient,
            withdraw<CoinType>(Signer::address_of(sender), amount)
        );
    }

    // Wrapper to send both coin types in one transaction
    public(script) fun transfer_both_coins(
        sender: &signer,
        recipient: address,
        apt_subunits: u64,
        usd_subunits: u64,
    ) acquires Balance {
        transfer<APT>(sender, recipient, apt_subunits);
        transfer<USD>(sender, recipient, usd_subunits);
    }

    // Withdraw specified subunits of given coin type from address
    fun withdraw<CoinType>(
        addr: address,
        amount: u64
    ): Coin<CoinType>
    acquires Balance {
        let balance = balance_of<CoinType>(addr);
        assert!(amount <= balance, E_INSUFFICIENT_BALANCE);
        let balance_ref =
            &mut borrow_global_mut<Balance<CoinType>>(addr).coin.subunits;
        *balance_ref = balance - amount;
        Coin<CoinType>{subunits: amount}
    }

    // Verify airdrop deposits processed correctly
    #[test(
        user = @TestUser,
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

    // Verify airdrop fails when signer is not Ultima
    #[test(user = @TestUser)]
    #[expected_failure(abort_code = 1)]
    public(script) fun airdrop_invalid_authority(
        user: signer
    ) acquires Balance {
        airdrop(&user, Signer::address_of(&user), 123, 456);
    }

    // Verify balance can not be checked if Balance resource unpublished
    #[test]
    #[expected_failure]
    fun balance_of_dne<CoinType>()
    acquires Balance {
        balance_of<APT>(@TestUser);
    }

    // Verify can not deposit if Balance resource unpublished
    #[test]
    #[expected_failure]
    fun deposit_dne<CoinType>()
    acquires Balance {
        deposit(@TestUser, Coin<APT>{subunits: 1});
    }

    // Verify empty coin return value
    #[test]
    fun empty_coin_return() {
        let Coin<APT>{subunits} = get_empty_coin<APT>();
        assert!(subunits == 0, E_NOT_EMPTY);
    }

    // Verify 0 holdings after publishing balance
    #[test(account = @TestUser)]
    public(script) fun publish_balances_zero(
        account: signer
    ) acquires Balance {
        publish_balances(&account);
        let addr = Signer::address_of(&account);
        assert!(balance_of<APT>(addr) == 0, E_APT_NOT_PUBLISH_0);
        assert!(balance_of<USD>(addr) == 0, E_USD_NOT_PUBLISH_0);
    }

    // Verify abort for publishing balances twice
    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 0)]
    public(script) fun publish_twice_aborts(
        account: signer
    ) {
        publish_balance<APT>(&account);
        publish_balance<APT>(&account);
    }

    // Verify successful reporting of subunits, without modification
    #[test(account = @Ultima)]
    public(script) fun report_subunits_success(
        account: signer
    ) acquires Balance {
        publish_balance<APT>(&account);
        let addr = Signer::address_of(&account);
        mint<APT>(addr, 100); // Mint 100
        assert!( // Assert 100 subunits reported
            report_subunits<APT>(
                &borrow_global<Balance<APT>>(addr).coin) == 100,
            E_INVALID_REPORT
        );
        // Assert balance unmodified
        assert!(balance_of<APT>(addr) == 100, E_MODIFIED_VALUE);
    }

    // Verify successful transfer between accounts
    #[test(
        user = @TestUser,
        ultima = @Ultima
    )]
    public(script) fun transfer_success(
        user: signer,
        ultima: signer
    ) acquires Balance {
        // Get addresses
        let user_addr = Signer::address_of(&user);
        let ultima_addr = Signer::address_of(&ultima);

        // Initialize empty balances
        publish_balances(&ultima);
        publish_balances(&user);

        // Airdrop to user, then transfer to Ultima
        airdrop(&ultima, user_addr, 1500, 900);
        transfer_both_coins(&user, ultima_addr, 1000, 300);

        // Verify end balances
        assert!(balance_of<APT>(user_addr) == 500, E_FAILED_TRANSFER);
        assert!(balance_of<USD>(user_addr) == 600, E_FAILED_TRANSFER);
        assert!(balance_of<APT>(ultima_addr) == 1000, E_FAILED_TRANSFER);
        assert!(balance_of<USD>(ultima_addr) == 300, E_FAILED_TRANSFER);
    }

    // Verify error raised when withdrawing without balance
    #[test]
    #[expected_failure]
    fun withdraw_dne() acquires Balance {
        Coin<APT>{subunits: _} = withdraw(@TestUser, 0);
    }

    // Verify can properly withdraw
    #[test(account = @Ultima)]
    public(script) fun withdraw_success(
        account: signer
    ) acquires Balance {
        publish_balance<APT>(&account);
        let addr = Signer::address_of(&account);
        mint<APT>(addr, 1000);
        Coin<APT>{subunits: _} = withdraw(addr, 999);
        Coin<APT>{subunits: _} = withdraw(addr, 1);
    }

    // Verify error raised when withdrawing too much
    #[test(account = @TestUser)]
    #[expected_failure(abort_code = 6)]
    public(script) fun withdraw_too_much(
        account: signer
    ) acquires Balance {
        publish_balance<APT>(&account);
        Coin<APT>{subunits: _} = withdraw(Signer::address_of(&account), 1);
    }
}