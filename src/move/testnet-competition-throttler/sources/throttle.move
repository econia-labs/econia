module throttler::throttle {

    // Constants for trading competition rules. >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Maximum amount of 🚀 that can change hands in a single trade.
    const MAX_TRADE_VOLUME_ROCKET: u64 =  500;
    /// Maximum amount of 🚀 that can be deposited/minted at a time.
    const MAX_TRANSFER_ROCKET: u64 =  100;
    /// Maximum amount of 💩 that can be deposited/minted at a time.
    const MAX_TRANSFER_POOP: u64 =  600;
    /// The market ID that activity is throttled on.
    const THROTTLED_MARKET_ID: u64 = 3;
    /// How long user must wait between faucet mints or market account
    /// deposits for a given asset.
    const WAIT_TIME_IN_SECONDS: u64 = 10;

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

    const SUBUNIT_CONVERSION_FACTOR_ROCKET: u64 = 100000000;
    const SUBUNIT_CONVERSION_FACTOR_POOP: u64 = 1000000;

    /// You do not have permission to modify the throttler.
    const E_NOT_ADMIN: u64 = 3;
    /// This function is deprecated. Use `get_config_parameters()`.
    const E_DEPRECATED_CONFIG_PARAMETERS: u64 = 4;

    public fun config_parameters(): ConfigView {
        assert!(false, E_DEPRECATED_CONFIG_PARAMETERS);
        ConfigView {
            max_trade_volume_rocket: 0,
            max_transfer_rocket: 0,
            max_transfer_poop: 0,
            throttled_market_id: 0,
            wait_time_in_minutes: 0,
        }
    }

    #[view]
    public fun get_config_parameters(): ConfigViewV2 {
        ConfigViewV2 {
            max_trade_volume_rocket: MAX_TRADE_VOLUME_ROCKET,
            max_transfer_rocket: MAX_TRANSFER_ROCKET,
            max_transfer_poop: MAX_TRANSFER_POOP,
            throttled_market_id: THROTTLED_MARKET_ID,
            wait_time_in_seconds: WAIT_TIME_IN_SECONDS,
        }
    }

    #[view]
    public fun is_active(): bool acquires Throttler {
        borrow_global<Throttler>(@throttler).is_active
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
        max_trade_volume_rocket: u64,
        max_transfer_rocket: u64,
        max_transfer_poop: u64,
        throttled_market_id: u64,
        wait_time_in_minutes: u64,
    }

    struct ConfigViewV2 has copy, drop, store {
        max_trade_volume_rocket: u64,
        max_transfer_rocket: u64,
        max_transfer_poop: u64,
        throttled_market_id: u64,
        wait_time_in_seconds: u64,
    }

    struct Throttler has key {
        is_active: bool,
        exempt_accounts: vector<address>,
        throttled_accounts: SmartTable<address, ThrottledAccount>,
    }

    /// All times in seconds.
    struct ThrottledAccount has copy, drop, store {
        account_address: address,
        last_mint_time_rocket: u64,
        last_mint_time_poop: u64,
        last_deposit_time_rocket: u64,
        last_deposit_time_poop: u64,
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
        is_rocket: bool,
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
                last_mint_time_rocket: 0,
                last_mint_time_poop: 0,
                last_deposit_time_rocket: 0,
                last_deposit_time_poop: 0,
            }
        );
        let account_ref_mut = smart_table::borrow_mut(
            throttled_accounts_ref_mut,
            account
        );
        let last_time_ref_mut = if (is_mint) {
            if (is_rocket) &mut account_ref_mut.last_mint_time_rocket else
            &mut account_ref_mut.last_mint_time_poop
        } else {
            if (is_rocket) &mut account_ref_mut.last_deposit_time_rocket else
            &mut account_ref_mut.last_deposit_time_poop
        };
        let now = timestamp::now_seconds();
        let eligible = (now - *last_time_ref_mut) > (WAIT_TIME_IN_SECONDS);
        assert!(eligible, E_WAIT_TIME);
        let (conversion_factor, max_nominal) = if (is_rocket)
            (SUBUNIT_CONVERSION_FACTOR_ROCKET , MAX_TRANSFER_ROCKET ) else
            (SUBUNIT_CONVERSION_FACTOR_POOP, MAX_TRANSFER_POOP);
        assert!(
            amount_in_subunits <= max_nominal * conversion_factor,
            E_TRANSFER_AMOUNT
        );
        *last_time_ref_mut = now;
    }

    public fun throttle_trade(
        market_id: u64,
        taker: address,
        rocket_trade_amount_in_octas: u64,
    ) acquires Throttler {
        if (market_id != THROTTLED_MARKET_ID) return;
        let throttler_ref = borrow_global<Throttler>(@throttler);
        if (!throttler_ref.is_active) return;
        if (vector::contains(&throttler_ref.exempt_accounts, &taker)) return;
        let max_volume_octas =
            MAX_TRADE_VOLUME_ROCKET * SUBUNIT_CONVERSION_FACTOR_ROCKET;
        assert!(rocket_trade_amount_in_octas <= max_volume_octas, E_TRADE_AMOUNT);
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
