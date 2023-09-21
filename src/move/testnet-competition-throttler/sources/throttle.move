module throttler::throttle {

    // Constants for trading competition rules. >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Maximum amount of APT that can change hands in a single trade.
    const MAX_TRADE_VOLUME_APT: u64 =  200;
    /// Maximum amount of APT that can be deposited/minted at a time.
    const MAX_TRANSFER_APT: u64 =  20;
    /// Maximum amount of USDC that can be deposited/minted at a time.
    const MAX_TRANSFER_USDC: u64 =  100;
    /// The market ID that activity is throttled on.
    const THROTTLED_MARKET_ID: u64 = 3;
    /// How long user must wait between faucet mints or market account
    /// deposits for a given asset.
    const WAIT_TIME_IN_MINUTES: u64 = 5;

    // Constants for trading competition rules. <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Trading competition participant error codes. >>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// You have not waited long enough between a deposit or mint.
    const E_WAIT_TIME: u64 = 0;
    /// You have tried to mint or deposit too much.
    const E_TRANSFER_AMOUNT: u64 = 1;
    /// You have tried to trade too much during a single trade.
    const E_TRADE_AMOUNT: u64 = 2;

    // Trading competition participant error codes. <<<<<<<<<<<<<<<<<<<<<<<<<<<

    use aptos_framework::timestamp;
    use aptos_std::simple_map;
    use aptos_std::smart_table::{Self, SmartTable};
    use std::signer;
    use std::vector;

    const SECONDS_PER_MINUTE: u64 = 60;
    const SUBUNIT_CONVERSION_FACTOR_APT: u64 = 100000000;
    const SUBUNIT_CONVERSION_FACTOR_USDC: u64 = 1000000;

    /// You do not have permission to modify the throttler.
    const E_NOT_ADMIN: u64 = 3;

    #[view]
    public fun config_parameters(): ConfigView {
        ConfigView {
            max_trade_volume_apt: MAX_TRADE_VOLUME_APT,
            max_transfer_apt: MAX_TRANSFER_APT,
            max_transfer_usdc: MAX_TRANSFER_USDC,
            throttled_market_id: THROTTLED_MARKET_ID,
            wait_time_in_minutes: WAIT_TIME_IN_MINUTES,
        }
    }

    #[view]
    public fun exempt_accounts(): vector<address> acquires Throttler {
        borrow_global<Throttler>(@throttler).exempt_accounts
    }

    #[view]
    public fun n_throttled_accounts(): u64 acquires Throttler {
        let throttled_accounts_ref =
            &borrow_global<Throttler>(@throttler).throttled_accounts;
        smart_table::length(throttled_accounts_ref)
    }

    #[view]
    public fun throttled_accounts():
    vector<ThrottledAccount>
    acquires Throttler {
        let throttled_accounts_ref =
            &borrow_global<Throttler>(@throttler).throttled_accounts;
        let simple_map = smart_table::to_simple_map(throttled_accounts_ref);
        simple_map::values(&simple_map)
    }

    struct ConfigView has copy, drop, store {
        max_trade_volume_apt: u64,
        max_transfer_apt: u64,
        max_transfer_usdc: u64,
        throttled_market_id: u64,
        wait_time_in_minutes: u64,
    }

    struct Throttler has key {
        is_active: bool,
        exempt_accounts: vector<address>,
        throttled_accounts: SmartTable<address, ThrottledAccount>,
    }

    /// All times in seconds.
    struct ThrottledAccount has copy, drop, store {
        account_address: address,
        last_mint_time_apt: u64,
        last_mint_time_usdc: u64,
        last_deposit_time_apt: u64,
        last_deposit_time_usdc: u64,
    }

    fun init_module(throttler: &signer) {
        move_to(throttler, Throttler {
            is_active: true,
            exempt_accounts: vector[],
            throttled_accounts: smart_table::new(),
        })
    }

    public fun throttle_transfer(
        market_id: u64,
        account: address,
        is_mint: bool,
        is_apt: bool,
        amount_in_subunits: u64,
    ) acquires Throttler {
        if (!is_mint && market_id != THROTTLED_MARKET_ID) return;
        let throttler_ref_mut = borrow_global_mut<Throttler>(@throttler);
        if (!throttler_ref_mut.is_active) return;
        if (vector::contains(&throttler_ref_mut.exempt_accounts, &account))
            return;
        let throttled_accounts_ref_mut =
            &mut throttler_ref_mut.throttled_accounts;
        let new_account =
            !smart_table::contains(throttled_accounts_ref_mut, account);
        if (new_account) smart_table::add(
            throttled_accounts_ref_mut,
            account,
            ThrottledAccount {
                account_address: account,
                last_mint_time_apt: 0,
                last_mint_time_usdc: 0,
                last_deposit_time_apt: 0,
                last_deposit_time_usdc: 0,
            }
        );
        let account_ref_mut = smart_table::borrow_mut(
            throttled_accounts_ref_mut,
            account
        );
        let last_time_ref_mut = if (is_mint) {
            if (is_apt) &mut account_ref_mut.last_mint_time_apt else
            &mut account_ref_mut.last_mint_time_usdc
        } else {
            if (is_apt) &mut account_ref_mut.last_deposit_time_apt else
            &mut account_ref_mut.last_deposit_time_usdc
        };
        let now = timestamp::now_seconds();
        let eligible = (now - *last_time_ref_mut) >
            (WAIT_TIME_IN_MINUTES * SECONDS_PER_MINUTE);
        assert!(eligible, E_WAIT_TIME);
        let (conversion_factor, max_nominal) = if (is_apt)
            (SUBUNIT_CONVERSION_FACTOR_APT , MAX_TRANSFER_APT ) else
            (SUBUNIT_CONVERSION_FACTOR_USDC, MAX_TRANSFER_USDC);
        assert!(
            amount_in_subunits * conversion_factor <= max_nominal,
            E_TRANSFER_AMOUNT
        );
        *last_time_ref_mut = now;
    }

    public fun throttle_trade(
        market_id: u64,
        taker: address,
        apt_trade_amount_in_octas: u64,
    ) acquires Throttler {
        if (market_id != THROTTLED_MARKET_ID) return;
        let throttler_ref = borrow_global<Throttler>(@throttler);
        if (!throttler_ref.is_active) return;
        if (vector::contains(&throttler_ref.exempt_accounts, &taker)) return;
        let trade_amount_nominal =
            apt_trade_amount_in_octas * SUBUNIT_CONVERSION_FACTOR_APT;
        assert!(trade_amount_nominal < MAX_TRADE_VOLUME_APT, E_TRADE_AMOUNT);
    }

    public entry fun deactivate(admin: &signer) acquires Throttler {
        assert!(signer::address_of(admin) == @admin, E_NOT_ADMIN);
        borrow_global_mut<Throttler>(@throttler).is_active = false;
    }

    public entry fun reactivate(admin: &signer) acquires Throttler {
        assert!(signer::address_of(admin) == @admin, E_NOT_ADMIN);
        borrow_global_mut<Throttler>(@throttler).is_active = true;
    }

    public entry fun add_exempt_account(
        admin: &signer,
        account: address,
    ) acquires Throttler {
        assert!(signer::address_of(admin) == @admin, E_NOT_ADMIN);
        let throttler_ref_mut = borrow_global_mut<Throttler>(@throttler);
        let accounts_ref_mut = &mut throttler_ref_mut.exempt_accounts;
        if (!vector::contains(accounts_ref_mut, &account))
            vector::push_back(accounts_ref_mut, account);
    }

    public entry fun remove_exempt_account(
        admin: &signer,
        account: address,
    ) acquires Throttler {
        assert!(signer::address_of(admin) == @admin, E_NOT_ADMIN);
        let throttler_ref_mut = borrow_global_mut<Throttler>(@throttler);
        let accounts_ref_mut = &mut throttler_ref_mut.exempt_accounts;
        let (found, index) = vector::index_of(accounts_ref_mut, &account);
        if (found) {vector::remove(accounts_ref_mut, index);};
    }

}