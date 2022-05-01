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
    const E_WITHDRAW_NOT_YIELD: u64 = 11;
    const E_WITHDRAW_WRONG_BALANCE: u64 = 12;
    const E_COIN_MERGE_FAILURE: u64 = 13;
    const E_NOT_ENOUGH_TO_SPLIT: u64 = 14;
    const E_SPLIT_FAILURE: u64 = 15;
    const E_MERGE_TO_TARGET_FAILURE: u64 = 16;
    const E_SPLIT_AMOUNT_TOO_HIGH: u64 = 17;
    const E_SPLIT_FROM_TARGET_FAILURE: u64 = 18;
    const E_DEPOSIT_COINS_FAILURE: u64 = 19;

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
        // Destruct moved coin amount
        let Coin{subunits} = coin;
        *balance_ref = *balance_ref + subunits;
    }

    // Deposit coins into balance
    public fun deposit_coins(
        addr: address,
        apt: Coin<APT>,
        usd: Coin<USD>,
    ) acquires Balance {
        deposit(addr, apt);
        deposit(addr, usd);
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

    // Merge two coin resources into one with appropriate balance
    public fun merge_coins<CoinType>(
        c1: Coin<CoinType>,
        c2: Coin<CoinType>
    ): Coin<CoinType> {
        let Coin<CoinType>{subunits: subs1} = c1;
        let Coin<CoinType>{subunits: subs2} = c2;
        Coin<CoinType>{subunits: subs1 + subs2}
    }

    // Merge inbound coin to a target coin at a mutable reference
    public fun merge_coin_to_target<CoinType>(
        inbound: Coin<CoinType>, // Inbound coin
        // Mutable reference to target coin
        target_coin_ref: &mut Coin<CoinType>
    ): (
        u64, // Inbound subunits
        u64, // Subunits in target coin pre-merge
        u64, // Subunits in target coin post-merge
    ) {
        let Coin<CoinType>{subunits: in} = inbound;
        let subunits_ref = &mut target_coin_ref.subunits;
        let pre = *subunits_ref;
        *subunits_ref = pre + in;
        (in, pre, *subunits_ref)
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

    // Split a coin resource into two, conserving total subunit count
    public fun split_coin<CoinType>(
        coin: Coin<CoinType>,
        amount: u64,
    ): (
        Coin<CoinType>, // Requested amount
        Coin<CoinType>, // Remainder
    ) {
        let Coin<CoinType>{subunits: available} = coin;
        assert!(amount <= available, E_NOT_ENOUGH_TO_SPLIT);
        let remainder = available - amount;
        (Coin<CoinType>{subunits: amount}, Coin<CoinType>{subunits: remainder})
    }

    // Split off coin resource from a target coin at a mutable reference
    public fun split_coin_from_target<CoinType>(
        amount: u64, // Amount to split off
        target_coin_ref: &mut Coin<CoinType>
    ): (
        Coin<CoinType>, // New coin resource containing requested amount
        u64, // Subunits in target coin pre-merge
        u64, // Subunits in target coin post-merge
    ) {
        let subunits_ref = &mut target_coin_ref.subunits;
        let pre = *subunits_ref;
        assert!(amount <= pre, E_SPLIT_AMOUNT_TOO_HIGH);
        let post = pre - amount;
        *subunits_ref = post;
        (
            Coin<CoinType>{subunits: amount},
            pre,
            post
        )
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

    // Withdraw specified subunits of given coin from address balance
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

    // Return coins withdrawn from balance
    public fun withdraw_coins(
        account: &signer,
        apt_subunits: u64,
        usd_subunits: u64
    ): (
        Coin<APT>,
        Coin<USD>
    ) acquires Balance {
        let addr = Signer::address_of(account);
        (withdraw<APT>(addr, apt_subunits), withdraw<USD>(addr, usd_subunits))
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

    // Verify depositing moved coins
    #[test(account = @TestUser)]
    public(script) fun deposit_coins_success(
        account: signer
    ) acquires Balance {
        let addr = Signer::address_of(&account);
        publish_balances(&account);
        deposit_coins(addr, Coin<APT>{subunits: 1}, Coin<USD>{subunits: 2});
        assert!(balance_of<APT>(addr) == 1, E_DEPOSIT_COINS_FAILURE);
        assert!(balance_of<USD>(addr) == 2, E_DEPOSIT_COINS_FAILURE);
    }

    // Verify empty coin return value
    #[test]
    fun empty_coin_return() {
        let Coin<APT>{subunits} = get_empty_coin<APT>();
        assert!(subunits == 0, E_NOT_EMPTY);
    }

    // Verify coins merge correctly
    #[test]
    fun merge_coins_success() {
        let Coin<APT>{subunits: result} =
            merge_coins(Coin<APT>{subunits: 1}, Coin<APT>{subunits: 2});
        assert!(result == 3, E_COIN_MERGE_FAILURE);
    }

    // Verify proper coin merge to target
    #[test]
    public fun merge_coin_to_target_success() {
        let target = Coin<APT>{subunits: 100};
        let (in, pre, post) =
           merge_coin_to_target(Coin<APT>{subunits: 50}, &mut target);
        let Coin<APT>{subunits: result} = target;
        assert!(result == 150, E_MERGE_TO_TARGET_FAILURE);
        assert!(in == 50, E_MERGE_TO_TARGET_FAILURE);
        assert!(pre == 100, E_MERGE_TO_TARGET_FAILURE);
        assert!(post == 150, E_MERGE_TO_TARGET_FAILURE);
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

    // Verify successful splitting of coin into two
    #[test]
    fun split_coin_success() {
        let (Coin<APT>{subunits: amount}, Coin<APT>{subunits: remainder}) =
            split_coin<APT>(Coin<APT>{subunits: 100}, 25);
        assert!(amount == 25, E_SPLIT_FAILURE);
        assert!(remainder == 75, E_SPLIT_FAILURE);
    }

    // Verify aborts when trying to split off too much from target
    #[test]
    #[expected_failure(abort_code = 17)]
    fun split_coin_from_target_failure() {
        let too_small = Coin<APT>{subunits: 1};
        let (Coin<APT>{subunits: _}, _, _) =
            split_coin_from_target(2, &mut too_small);
        let Coin<APT>{subunits: _} = too_small;
    }

    // Verify successful coin split from target
    #[test]
    fun split_coin_from_target_success() {
        // Init target coin and split off from it
        let target = Coin<APT>{subunits: 100};
        let (out, pre, post_reported) =
           split_coin_from_target(25, &mut target);

        // Destruct coins to test subunits in each
        let Coin<APT>{subunits: split} = out;
        let Coin<APT>{subunits: post_actual} = target;

        // Verify counts
        assert!(split == 25, E_SPLIT_FROM_TARGET_FAILURE);
        assert!(pre == 100, E_SPLIT_FROM_TARGET_FAILURE);
        assert!(post_reported == 75, E_SPLIT_FROM_TARGET_FAILURE);
        assert!(post_actual == 75, E_SPLIT_FROM_TARGET_FAILURE);
    }

    // Verify unable to split coin when too much requested
    #[test]
    #[expected_failure(abort_code = 14)]
    fun split_coin_failure() {
        let (Coin<USD>{subunits: _}, Coin<USD>{subunits: _}) =
            split_coin<USD>(Coin<USD>{subunits: 1}, 10);
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

    // Verify successful return of coins and post-withdraw balance
    #[test(account = @TestUser)]
    public(script) fun withdraw_coins_success(
        account: signer
    ) acquires Balance {

        // Initialize account
        let addr = Signer::address_of(&account);
        publish_balances(&account);
        mint<APT>(addr, 100);
        mint<USD>(addr, 1000);

        // Verify withdrawn coins returned correctly by destructing
        let (Coin<APT>{subunits: apt_subs}, Coin<USD>{subunits: usd_subs}) =
            withdraw_coins(&account, 2, 300);
        assert!(apt_subs == 2, E_WITHDRAW_NOT_YIELD);
        assert!(usd_subs == 300, E_WITHDRAW_NOT_YIELD);

        // Verify balance updated appropriately
        assert!(balance_of<APT>(addr) == 98, E_WITHDRAW_WRONG_BALANCE);
        assert!(balance_of<USD>(addr) == 700, E_WITHDRAW_WRONG_BALANCE);
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