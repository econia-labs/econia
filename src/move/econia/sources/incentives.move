/// Incentive-associated parameters and data structures.
module econia::incentives {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::coin::{Self, Coin};
    use aptos_std::type_info::{Self, TypeInfo};
    use econia::table_list::{Self, TableList};
    use std::signer::address_of;
    use std::vector;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use econia::assets::{Self, QC, UC};

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Portion of taker fees not claimed by an integrator, which are
    /// reserved for Econia.
    struct EconiaFeeStore<phantom QuoteCoinType> has key {
        /// Map from market ID to fees collected for given market,
        /// enabling duplicate checks and interable indexing.
        map: TableList<u64, Coin<QuoteCoinType>>
    }

    /// Stores a signing capability for the resource account where
    /// fees, collected by Econia, are stored.
    struct FeeAccountSignerCapabilityStore has key {
        /// Signing capability for fee collection resource account.
        fee_account_signer_capability: SignerCapability
    }

    /// Incentive parameters for assorted operations.
    struct IncentiveParameters has key {
        /// Utility coin type info. Corresponds to the phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`) of
        /// the coin required for utility purposes. Set to `APT` at
        /// mainnet launch, later the Econia coin.
        utility_coin_type_info: TypeInfo,
        /// `Coin.value` required to register a market.
        market_registration_fee: u64,
        /// `Coin.value` required to register as a custodian.
        custodian_registration_fee: u64,
        /// Nominal amount divisor for quote coin fee charged to takers.
        /// For example, if a transaction involves a quote coin fill of
        /// 1000000 units and the taker fee divisor is 2000, takers pay
        /// 1/2000th (0.05%) of the nominal amount (500 quote coin
        /// units) in fees. Instituted as a divisor for optimized
        /// calculations.
        taker_fee_divisor: u64,
        /// 0-indexed list from tier number to corresponding parameters.
        integrator_fee_store_tiers: vector<IntegratorFeeStoreTierParameters>
    }

    /// Fee store for a given integrator, on a given market.
    struct IntegratorFeeStore<phantom QuoteCoinType> has store {
        /// Activation tier, incremented by paying utility coins.
        tier: u8,
        /// Collected fees, in quote coins for given market.
        coins: Coin<QuoteCoinType>
    }

    /// All of an integrator's `IntregratorFeeStore`s for given
    /// `QuoteCoinType`.
    struct IntegratorFeeStores<phantom QuoteCoinType> has key {
        /// Map from market ID to `IntegratorFeeStore`, enabling
        /// duplicate checks and iterable indexing.
        map: TableList<u64, IntegratorFeeStore<QuoteCoinType>>
    }

    /// Integrator fee store tier parameters for a given tier.
    struct IntegratorFeeStoreTierParameters has drop, store {
        /// Nominal amount divisor for taker quote coin fee reserved for
        /// integrators having activated their fee store to the given
        /// tier. For example, if a transaction involves a quote coin
        /// fill of 1000000 units and the fee share divisor at the given
        /// tier is 4000, integrators get 1/4000th (0.025%) of the
        /// nominal amount (250 quote coin units) in fees at the given
        /// tier. Instituted as a divisor for optimized calculations.
        /// May not be larger than the
        /// `IncentiveParameters.taker_fee_divisor`, since the
        /// integrator fee share is deducted from the taker fee (with
        /// the remaining proceeds going to an `EconiaFeeStore` for the
        /// given market).
        fee_share_divisor: u64,
        /// Cumulative cost, in utility coin units, to activate to the
        /// current tier. For example, if an integrator has already
        /// activated to tier 3, which has a tier activation fee of 1000
        /// units, and tier 4 has a tier activation fee of 10000 units,
        /// the integrator only has to pay 9000 units to activate to
        /// tier 4.
        tier_activation_fee: u64,
        /// Cost, in utility coin units, to withdraw from an integrator
        /// fee store. Shall never be nonzero, since a disincentive is
        /// required to prevent excessively-frequent withdrawals and
        /// thus transaction collisions with the matching engine.
        withdrawal_fee: u64
    }

    /// Container for utility coin fees collected by Econia.
    struct UtilityCoinStore<phantom CoinType> has key {
        /// Coins collected as utility fees.
        coins: Coin<CoinType>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When caller is not Econia, but should be.
    const E_NOT_ECONIA: u64 = 0;
    /// When type does not correspond to an initialized coin.
    const E_NOT_COIN: u64 = 1;
    /// When passed fee store tiers vector is empty.
    const E_EMPTY_FEE_STORE_TIERS: u64 = 2;
    /// When indicated fee share divisor for given tier is too big.
    const E_FEE_SHARE_DIVISOR_TOO_BIG: u64 = 3;
    /// When the indicated fee share divisor for a given tier is less
    /// than the indicated taker fee divisor.
    const E_FEE_SHARE_DIVISOR_TOO_SMALL: u64 = 4;
    /// When market registration fee is less than the minimum.
    const E_MARKET_REGISTRATION_FEE_LESS_THAN_MIN: u64 = 5;
    /// When custodian registration fee is less than the minimum.
    const E_CUSTODIAN_REGISTRATION_FEE_LESS_THAN_MIN: u64 = 6;
    /// When taker fee divisor is less than the minimum.
    const E_TAKER_DIVISOR_LESS_THAN_MIN: u64 = 7;
    /// When the wrong number of fields are passed for a given tier.
    const E_TIER_FIELDS_WRONG_LENGTH: u64 = 8;
    /// When the indicated tier activation fee is too small.
    const E_ACTIVATION_FEE_TOO_SMALL: u64 = 9;
    /// When the indicated withdrawal fee is too big.
    const E_WITHDRAWAL_FEE_TOO_BIG: u64 = 10;
    /// When the indicated withdrawal fee is too small.
    const E_WITHDRAWAL_FEE_TOO_SMALL: u64 = 11;
    /// When type is not the utility coin type.
    const E_INVALID_UTILITY_COIN_TYPE: u64 = 12;
    /// When not enough utility coins provided.
    const E_NOT_ENOUGH_UTILITY_COINS: u64 = 13;
    /// When too many integrater fee store tiers indicated.
    const E_TOO_MANY_TIERS: u64 = 14;
    /// When indicated tier is not higher than existing tier.
    const E_NOT_AN_UPGRADE: u64 = 15;
    /// When an update to the incentive parameters set indicates a
    /// reduction in fee store tiers.
    const E_FEWER_TIERS: u64 = 16;
    /// When maximum amount of quote coins to match overflows a `u64`.
    const E_MAX_QUOTE_MATCH_OVERFLOW: u64 = 17;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Buy direction flag.
    const BUY: bool = true;
    /// Index of fee share in vectorized representation of an
    /// `IntegratorFeeStoreTierParameters`.
    const FEE_SHARE_DIVISOR_INDEX: u64 = 0;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// Maximum number of integrator fee store tiers is largest number
    /// that can fit in a `u8`.
    const MAX_INTEGRATOR_FEE_STORE_TIERS: u64 = 0xff;
    /// Minimum possible divisor for avoiding divide-by-zero error.
    const MIN_DIVISOR: u64 = 1;
    /// Minimum possible flat fee, required to disincentivize excessive
    /// bogus transactions.
    const MIN_FEE: u64 = 1;
    /// Number of fields in an `IntegratorFeeStoreTierParameters`
    const N_TIER_FIELDS: u64 = 3;
    /// Sell direction flag.
    const SELL: bool = false;
    /// Index of tier activation fee in vectorized representation of an
    /// `IntegratorFeeStoreTierParameters`.
    const TIER_ACTIVATION_FEE_INDEX: u64 = 1;
    /// Index of withdrawal fee in vectorized representation of an
    /// `IntegratorFeeStoreTierParameters`.
    const WITHDRAWAL_FEE_INDEX: u64 = 2;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return custodian registration fee.
    public fun get_custodian_registration_fee():
    u64
    acquires IncentiveParameters {
        borrow_global<IncentiveParameters>(@econia).custodian_registration_fee
    }

    /// Return fee account address.
    public fun get_fee_account_address():
    address
    acquires FeeAccountSignerCapabilityStore {
        account::get_signer_capability_address(
            &borrow_global<FeeAccountSignerCapabilityStore>(@econia).
                fee_account_signer_capability)
    }

    /// Return fee share divisor for tier indicated by `tier_ref`.
    public fun get_fee_share_divisor(
        tier_ref: &u8
    ): u64
    acquires IncentiveParameters {
        vector::borrow(&borrow_global<IncentiveParameters>(@econia).
            integrator_fee_store_tiers, (*tier_ref as u64)).fee_share_divisor
    }

    /// Return market registration fee.
    public fun get_market_registration_fee():
    u64
    acquires IncentiveParameters {
        borrow_global<IncentiveParameters>(@econia).market_registration_fee
    }

    /// Return number of fee store tiers.
    public fun get_n_fee_store_tiers():
    u64
    acquires IncentiveParameters {
        vector::length(&borrow_global<IncentiveParameters>(@econia).
            integrator_fee_store_tiers)
    }
    /// Return taker fee divisor.
    public fun get_taker_fee_divisor():
    u64
    acquires IncentiveParameters {
        borrow_global<IncentiveParameters>(@econia).taker_fee_divisor
    }

    /// Return tier activation fee for tier indicated by `tier_ref`.
    public fun get_tier_activation_fee(
        tier_ref: &u8
    ): u64
    acquires IncentiveParameters {
        vector::borrow(&borrow_global<IncentiveParameters>(@econia).
            integrator_fee_store_tiers, (*tier_ref as u64)).tier_activation_fee
    }

    /// Return withdrawal fee for tier indicated by `tier_ref`.
    public fun get_withdrawal_fee(
        tier_ref: &u8
    ): u64
    acquires IncentiveParameters {
        vector::borrow(&borrow_global<IncentiveParameters>(@econia).
            integrator_fee_store_tiers, (*tier_ref as u64)).withdrawal_fee
    }

    /// Return `true` if `T` is the utility coin type.
    public fun is_utility_coin_type<T>():
    bool
    acquires IncentiveParameters {
        type_info::type_of<T>() ==
            borrow_global<IncentiveParameters>(@econia).utility_coin_type_info
    }

    /// Assert `T` is utility coin type.
    public fun verify_utility_coin_type<T>()
    acquires IncentiveParameters {
        assert!(is_utility_coin_type<T>(), E_INVALID_UTILITY_COIN_TYPE);
    }

    /// Withdraw specified amount of fees from an `EconiaFeeStore`.
    ///
    /// # Type parameters
    /// * `QuoteCoinType`: Quote coin type for market.
    ///
    /// # Parameters
    /// * `account`: The Econia account.
    /// * `market_id_ref`: Immutable reference to market ID.
    /// * `amount_ref`: Immutable reference to amount to withdraw.
    ///
    /// # Aborts if
    /// * `account` is not Econia.
    public fun withdraw_econia_fees<QuoteCoinType>(
        account: &signer,
        market_id_ref: &u64,
        amount_ref: &u64
    ): coin::Coin<QuoteCoinType>
    acquires
        FeeAccountSignerCapabilityStore,
        EconiaFeeStore
    {
        // Assert account is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        coin::extract( // Extract indicated amount of coins.
            table_list::borrow_mut(
                &mut borrow_global_mut<EconiaFeeStore<QuoteCoinType>>(
                get_fee_account_address()).map,
                *market_id_ref
            ),
            *amount_ref
        )
    }

    /// Withdraw all fees from an `EconiaFeeStore`.
    ///
    /// # Type parameters
    /// * `QuoteCoinType`: Quote coin type for market.
    ///
    /// # Parameters
    /// * `account`: The Econia account.
    /// * `market_id_ref`: Immutable reference to market ID.
    ///
    /// # Aborts if
    /// * `account` is not Econia.
    public fun withdraw_econia_fees_all<QuoteCoinType>(
        account: &signer,
        market_id_ref: &u64,
    ): coin::Coin<QuoteCoinType>
    acquires
        FeeAccountSignerCapabilityStore,
        EconiaFeeStore
    {
        // Assert account is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        coin::extract_all( // Extract all coins.
            table_list::borrow_mut(
                &mut borrow_global_mut<EconiaFeeStore<QuoteCoinType>>(
                get_fee_account_address()).map,
                *market_id_ref
            )
        )
    }

    /// Withdraw all fees from an `IntegratorFeeStore`.
    ///
    /// # Type parameters
    /// * `QuoteCoinType`: The quote coin type for market.
    /// * `UtilityCoinType`: The utility coin type.
    ///
    /// # Parameters
    /// * `integrator`: Integrator account.
    /// * `market_id`: Market ID of corresponding market.
    /// * `utility_coins`: Utility coins paid in order to make
    ///   withdrawal, required to disincentivize excessively frequent
    ///   withdrawals and thus transaction collisions with the matching
    ///   engine.
    ///
    /// # Returns
    /// * `coin::Coin<QuoteCoinType>`: Quote coin fees for given market.
    public fun withdraw_integrator_fees<
        QuoteCoinType,
        UtilityCoinType
    >(
        integrator: &signer,
        market_id: u64,
        utility_coins: coin::Coin<UtilityCoinType>
    ): coin::Coin<QuoteCoinType>
    acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        IntegratorFeeStores,
        UtilityCoinStore
    {
        // Borrow mutable reference to integrator fee stores map for
        // quote coin type.
        let integrator_fee_stores_map_ref_mut = &mut borrow_global_mut<
            IntegratorFeeStores<QuoteCoinType>>(address_of(integrator)).map;
        // Borrow mutable reference to corresponding integrator fee
        // store.
        let integrator_fee_store_ref_mut = table_list::borrow_mut(
            integrator_fee_stores_map_ref_mut, market_id);
        // Deposit verified amount and type of utility coins.
        deposit_utility_coins_verified(utility_coins,
            &get_withdrawal_fee(&integrator_fee_store_ref_mut.tier));
        // Extract and return all coins in integrator fee store.
        coin::extract_all(&mut integrator_fee_store_ref_mut.coins)
    }

    /// Withdraw `amount` of utility coins from the `UtilityCoinStore`,
    /// aborting if `account` is not Econia.
    public fun withdraw_utility_coins<UtilityCoinType>(
        account: &signer,
        amount: u64
    ): coin::Coin<UtilityCoinType>
    acquires
        FeeAccountSignerCapabilityStore,
        UtilityCoinStore
    {
        // Assert account is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        coin::extract( // Extract indicated amount of coins.
            &mut borrow_global_mut<UtilityCoinStore<UtilityCoinType>>(
                get_fee_account_address()).coins, amount)
    }

    /// Withdraw all utility coins from the `UtilityCoinStore`, aborting
    /// if `account` is not Econia.
    public fun withdraw_utility_coins_all<UtilityCoinType>(
        account: &signer
    ): coin::Coin<UtilityCoinType>
    acquires
        FeeAccountSignerCapabilityStore,
        UtilityCoinStore
    {
        // Assert account is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        coin::extract_all( // Extract all coins.
            &mut borrow_global_mut<UtilityCoinStore<UtilityCoinType>>(
                get_fee_account_address()).coins)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[cmd]
    /// Wrapped call to `set_incentives()`, when calling after
    /// initialization.
    ///
    /// Accepts same arguments as `set_incentives()`, but pass-by-value
    /// instead of pass-by-reference.
    public entry fun update_incentives<UtilityCoinType>(
        econia: &signer,
        market_registration_fee: u64,
        custodian_registration_fee: u64,
        taker_fee_divisor: u64,
        integrator_fee_store_tiers: vector<vector<u64>>
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters
    {
        set_incentive_parameters<UtilityCoinType>(econia,
            &market_registration_fee, &custodian_registration_fee,
            &taker_fee_divisor, &integrator_fee_store_tiers, &true);
    }

    #[cmd]
    /// Upgrade `IntegratorFeeStore` to a higher tier.
    ///
    /// # Type parameters
    /// * `QuoteCoinType`: The quote coin type for market.
    /// * `UtilityCoinType`: The utility coin type.
    ///
    /// # Parameters
    /// * `integrator`: Integrator account.
    /// * `market_id`: Market ID of corresponding market.
    /// * `new_tier`: Tier to upgrade to.
    /// * `utility_coins`: Utility coins required to upgrade, calculated
    ///   as the difference between the cumulative activation cost for
    ///   each tier. For example, if it costs 1000 to activate to tier
    ///   3 and 100 to activate to tier 1, it costs 900 to upgrade from
    ///   tier 1 to tier 3.
    ///
    /// # Aborts if
    /// * `new_tier` is not higher than existing tier.
    public entry fun upgrade_integrator_fee_store<
        QuoteCoinType,
        UtilityCoinType
    >(
        integrator: &signer,
        market_id: u64,
        new_tier: u8,
        utility_coins: coin::Coin<UtilityCoinType>
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        IntegratorFeeStores,
        UtilityCoinStore
    {
        // Borrow mutable reference to integrator fee store for given
        // quote coin type and market ID.
        let integrator_fee_store_ref_mut = table_list::borrow_mut(
                &mut borrow_global_mut<IntegratorFeeStores<QuoteCoinType>>(
                    address_of(integrator)).map, market_id);
        // Get current tier number.
        let current_tier = integrator_fee_store_ref_mut.tier;
        // Assert actually attempting to upgrade to new tier.
        assert!(new_tier > current_tier, E_NOT_AN_UPGRADE);
        // Calculate difference in cumulative cost to upgrade.
        let cost_to_upgrade = get_tier_activation_fee(&new_tier) -
            get_tier_activation_fee(&current_tier);
        // Deposit verified amount and type of utility coins.
        deposit_utility_coins_verified<UtilityCoinType>(utility_coins,
            &cost_to_upgrade);
        integrator_fee_store_ref_mut.tier = new_tier; // Set new tier.
    }

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Assess fees after a taker fill.
    ///
    /// First attempts to assess an integrator's share of fees, then
    /// provides Econia with the remaining share. If the integrator
    /// address indicated by `integrator_address_ref` does not have an
    /// `IntegratorFeeStore` for the given market ID and quote coin
    /// type, all taker fees are passed on to Econia. Otherwise the
    /// integrator's fee share is determined based on their tier for the
    /// given market.
    ///
    /// # Type parameters
    /// * `QuoteCoinType`: Quote coin type for market.
    ///
    /// # Parameters
    /// * `market_id_ref`: Immutable reference to market ID.
    /// * `integrator_address_ref`: Immutable reference to integrator's
    ///   address. May be intentionally marked an address known not to
    ///   be an integrator, for example `@0x0` or `@econia`, in the
    ///   service of diverting all fees to Econia.
    /// * `quote_fill_ref`: Quote coins filled during a taker match.
    /// * `quote_coins_ref_mut`: Quote coins to withdraw fees from.
    public(friend) fun assess_fees<QuoteCoinType>(
        market_id_ref: &u64,
        integrator_address_ref: &address,
        quote_fill_ref: &u64,
        quote_coins_ref_mut: &mut coin::Coin<QuoteCoinType>
    ) acquires
        EconiaFeeStore,
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        IntegratorFeeStores
    {
        // Declare tracker for amount of fees collected by integrator.
        let integrator_fee_share = 0;
        // If integrator fee stores map for quote coin type exists at
        // indicated integrator address:
        if (exists<IntegratorFeeStores<QuoteCoinType>>(
            *integrator_address_ref)) {
            // Borrow mutable reference to integrator fee stores map.
            let integrator_fee_stores_map_ref_mut =
                &mut borrow_global_mut<IntegratorFeeStores<QuoteCoinType>>(
                    *integrator_address_ref).map;
            // If fee stores map contains an entry for given market ID:
            if (table_list::contains(integrator_fee_stores_map_ref_mut,
                *market_id_ref)) {
                // Borrow mutable reference to corresponding fee store.
                let integrator_fee_store_ref_mut = table_list::borrow_mut(
                    integrator_fee_stores_map_ref_mut, *market_id_ref);
                // Calculate integrator fee share for corresponding
                // divisor.
                integrator_fee_share = *quote_fill_ref /
                    get_fee_share_divisor(&integrator_fee_store_ref_mut.tier);
                // Merge into the fee store the corresponding fee share.
                coin::merge(&mut integrator_fee_store_ref_mut.coins,
                    coin::extract(quote_coins_ref_mut, integrator_fee_share));
            }
        }; // Integrator fee share has been assessed.
        // Fee share remaining for Econia is the total taker fee amount
        // less the integrator fee share.
        let econia_fee_share = *quote_fill_ref / get_taker_fee_divisor() -
            integrator_fee_share;
        // Merge the corresponding fee share into the Econia fee store
        // for the corresponding market ID and quote coin type.
        coin::merge(
            table_list::borrow_mut(
                &mut borrow_global_mut<EconiaFeeStore<QuoteCoinType>>(
                    get_fee_account_address()).map,
                *market_id_ref
            ),
            coin::extract(quote_coins_ref_mut, econia_fee_share)
        );
    }

    /// Deposit `coins` of `UtilityCoinType`, verifying that the proper
    /// amount is supplied for custodian registration.
    public(friend) fun deposit_custodian_registration_utility_coins<
        UtilityCoinType
    >(
        coins: coin::Coin<UtilityCoinType>
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        UtilityCoinStore
    {
        deposit_utility_coins_verified<UtilityCoinType>(coins,
            &get_custodian_registration_fee());
    }

    /// Deposit `coins` of `UtilityCoinType`, verifying that the proper
    /// amount is supplied for market registration.
    public(friend) fun deposit_market_registration_utility_coins<
        UtilityCoinType
    >(
        coins: coin::Coin<UtilityCoinType>
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        UtilityCoinStore
    {
        deposit_utility_coins_verified<UtilityCoinType>(coins,
            &get_market_registration_fee());
    }

    /// Wrapped call to `set_incentives()`, when calling for the first
    /// time.
    public(friend) fun init_incentives<UtilityCoinType>(
        econia: &signer,
        market_registration_fee_ref: &u64,
        custodian_registration_fee_ref: &u64,
        taker_fee_divisor_ref: &u64,
        integrator_fee_store_tiers_ref: &vector<vector<u64>>
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters
    {
        set_incentive_parameters<UtilityCoinType>(econia,
            market_registration_fee_ref, custodian_registration_fee_ref,
            taker_fee_divisor_ref, integrator_fee_store_tiers_ref, &false);
    }

    /// Register an `EconiaFeeStore` entry for market ID indicated by
    /// `market_id_ref`, for given `QuoteCoinType`.
    public(friend) fun register_econia_fee_store_entry<QuoteCoinType>(
        market_id_ref: &u64
    ) acquires
        EconiaFeeStore,
        FeeAccountSignerCapabilityStore
    {
        let fee_account = get_fee_account(); // Get fee account signer.
        // If an Econia fee store for the quote coin type has already
        // been initialized at the fee account:
        if (exists<EconiaFeeStore<QuoteCoinType>>(address_of(&fee_account))) {
            // Add to the fee store's underlying map an entry having the
            // market ID as the key, and zero coins as the value.
            table_list::add(
                &mut borrow_global_mut<EconiaFeeStore<QuoteCoinType>>(
                    address_of(&fee_account)).map, *market_id_ref,
                        coin::zero<QuoteCoinType>());
        // If an Econia fee store for quote coin type has not been
        // initialized at the fee account:
        } else {
            // Move to the fee account an Econia fee store for the quote
            // coin type, initializing the underlying map with a
            // singleton table list having the market ID as the key, and
            // zero coins as the value.
            move_to<EconiaFeeStore<QuoteCoinType>>(&fee_account,
                EconiaFeeStore{map: table_list::singleton(*market_id_ref,
                    coin::zero<QuoteCoinType>())});
        };
    }

    /// Register an `IntegratorFeeStore` entry at `account`.
    ///
    /// # Type parameters
    /// * `QuoteCoinType`: The quote coin type for market.
    /// * `UtilityCoinType`: The utility coin type.
    ///
    /// # Parameters
    /// * `account`: Integrator account.
    /// * `market_id_ref`: Immutable reference to market ID of
    ///    corresponding market.
    /// * `tier_ref`: Immutable reference to the fee store tier to
    ///   activate to.
    /// * `utility_coins`: Utility coins paid to activate to given tier.
    public(friend) fun register_integrator_fee_store<
        QuoteCoinType,
        UtilityCoinType
    >(
        account: &signer,
        market_id_ref: &u64,
        tier_ref: &u8,
        utility_coins: coin::Coin<UtilityCoinType>
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        IntegratorFeeStores,
        UtilityCoinStore
    {
        // Deposit verified amount and type of utility coins.
        deposit_utility_coins_verified(utility_coins,
            &get_tier_activation_fee(tier_ref));
        // Declare integrator fee store for given tier, with no coins.
        let integrator_fee_store = IntegratorFeeStore{tier: *tier_ref, coins:
            coin::zero<QuoteCoinType>()};
        // If an integrator fee stores map for quote coin type exists at
        // the given account:
        if (exists<IntegratorFeeStores<QuoteCoinType>>(address_of(account))) {
            // Add to the map an entry having the market ID as the key,
            // and the integrator fee store as the value.
            table_list::add(
                &mut borrow_global_mut<IntegratorFeeStores<QuoteCoinType>>(
                    address_of(account)).map, *market_id_ref,
                        integrator_fee_store);
        // If an integrator fee stores maps for quote coin type does not
        // exist at given account:
        } else {
            // Move to the account an integrator fee stores map for the
            // quote coin type, initializing it with a singleton table
            // list having the market ID as the key, and the integrator
            // fee store as the value.
            move_to<IntegratorFeeStores<QuoteCoinType>>(account,
                IntegratorFeeStores{map: table_list::singleton(*market_id_ref,
                    integrator_fee_store)});
        }
    }

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Get max quote coin match amount, per user input and fee divisor.
    ///
    /// # User input
    /// Whether a taker buy or sell, users specify a maximum quote coin
    /// amount when initiating the transaction. This amount indicates
    /// the maximum amount of quote coins they are willing to spend in
    /// the case of a taker buy, and the maximum amount of quote coins
    /// they are willing to receive in the case of a taker sell.
    ///
    /// # Matching
    /// The user-specified amount is inclusive of fees, however, and the
    /// matching engine does not manage fees. Instead it accepts a
    /// maximum amount of quote coins to match (or more specifically,
    /// ticks), with fees assessed after matching concludes:
    ///
    /// ## Example buy
    /// * Taker is willing to spend 105 quote coins.
    /// * Fee is 5% (divisor of 20).
    /// * Max match is thus 100 quote coins.
    /// * Matching engine returns after 100 quote coins filled.
    /// * 5% fee then assessed, withdrawn from takers's quote coins.
    /// * Taker has spent 105 quote coins.
    ///
    /// ## Example sell
    /// * Taker is willing to receive 100 quote coins.
    /// * Fee is 4% (divisor of 25).
    /// * Max match is thus 104 quote coins.
    /// * Matching engine returns after 104 quote coins filled.
    /// * 4% fee then assessed, withdrawn from quote coins received.
    /// * Taker has received 100 quote coins.
    ///
    /// # Variables
    /// Hence, the relationship between user-indicated maxmum quote coin
    /// amount, taker fee divisor, and the amount of quote coins matched
    /// can be described with the following variables:
    /// * $\Delta_t$: Change in quote coins seen by taker.
    /// * $d_t$: Taker fee divisor.
    /// * $q_m$: Quote coins matched.
    /// * $f = \frac{q_m}{d_t}$: Fees assessed.
    ///
    /// # Equations
    ///
    /// ## Buy
    ///
    /// $$q_m = \Delta_t - f = \Delta_t - \frac{q_m}{d_t}$$
    ///
    /// $$\Delta_t = q_m + \frac{q_m}{d_t} = q_m(1 + \frac{1}{d_t})$$
    ///
    /// $$ q_m = \frac{\Delta_t}{1 + \frac{1}{d_t}} $$
    ///
    /// $$ q_m = \frac{d_t \Delta_t}{d_t + 1}$$
    ///
    /// ## Sell
    ///
    /// $$q_m = \Delta_t + f = \Delta_t + \frac{q_m}{d_t}$$
    ///
    /// $$\Delta_t = q_m - \frac{q_m}{d_t} = q_m(1 - \frac{1}{d_t})$$
    ///
    /// $$ q_m = \frac{\Delta_t}{1 - \frac{1}{d_t}} $$
    ///
    /// $$ q_m = \frac{d_t \Delta_t}{d_t - 1}$$
    ///
    /// # Parameters
    /// * `direction_ref`: `&BUY` or `&SELL`.
    /// * `taker_fee_divisor_ref`: Immutable reference to taker fee
    ///   divisor.
    /// * `max_quote_delta_user_ref`: Immutable reference to maximum
    ///   change in quote coins seen by user: spent if a `BUY` and
    ///   received if a `SELL`.
    /// * `max_quote_to_match_ref_mut`: Mutable reference to maximum
    ///   amount of quote coins to match.
    ///
    /// # Assumptions
    /// * Taker fee divisor is greater than 1.
    ///
    /// # Aborts if
    /// * Maximum amount to match does not fit in a `u64`, which should
    ///   only be possible in the case of a `SELL`.
    fun calculate_max_quote_match(
        direction_bool: &bool,
        taker_fee_divisor_ref: &u64,
        max_quote_delta_user_ref: &u64,
        max_quote_match_ref_mut: &mut u64
    ) {
        // Calculate numerator for both buy and sell equations.
        let numerator = (*taker_fee_divisor_ref as u128) *
            (*max_quote_delta_user_ref as u128);
        // Calculate denominator based on direction.
        let denominator = if (*direction_bool == BUY)
            (*taker_fee_divisor_ref + 1 as u128) else
            (*taker_fee_divisor_ref - 1 as u128);
        // Calculate maximum quote coins to match.
        let max_quote_match = numerator / denominator;
        // Assert maximum quote to match fits in a u64.
        assert!(max_quote_match <= (HI_64 as u128),
            E_MAX_QUOTE_MATCH_OVERFLOW);
        // Cast and reassign maximum quote match value.
        *max_quote_match_ref_mut = (max_quote_match as u64);
    }

    /// Deposit `coins` to a `UtilityCoinStore`.
    fun deposit_utility_coins<UtilityCoinType>(
        coins: coin::Coin<UtilityCoinType>
    ) acquires
        FeeAccountSignerCapabilityStore,
        UtilityCoinStore
    {
        coin::merge(&mut borrow_global_mut<UtilityCoinStore<UtilityCoinType>>(
            get_fee_account_address()).coins, coins);
    }

    /// Verify that `UtilityCoinType` is the utility coin type and that
    /// `coins` has at least the amount indicated by `min_amount_ref`,
    /// then deposit all utility coins to `UtilityCoinStore`.
    fun deposit_utility_coins_verified<UtilityCoinType>(
        coins: coin::Coin<UtilityCoinType>,
        min_amount_ref: &u64
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        UtilityCoinStore
    {
        // Verify utility coin type.
        verify_utility_coin_type<UtilityCoinType>();
        // Assert sufficient utility coins provided.
        assert!(coin::value(&coins) >= *min_amount_ref,
            E_NOT_ENOUGH_UTILITY_COINS);
        // Deposit all utility coins to utility coin store.
        deposit_utility_coins(coins);
    }

    /// Return fee account signer generated from stored capability.
    fun get_fee_account():
    signer
    acquires FeeAccountSignerCapabilityStore {
        account::create_signer_with_capability(
            &borrow_global<FeeAccountSignerCapabilityStore>(@econia).
                fee_account_signer_capability)
    }

    /// Initialize the resource account where fees, collected by Econia,
    /// are stored.
    ///
    /// # Parameters
    /// * `econia`: The Econia account `signer`.
    ///
    /// # Returns
    /// * `signer`: The resource account `signer`.
    ///
    /// # Seed considerations
    /// * Resource account creation seed supplied as an empty vector,
    ///   pending the acceptance of `aptos-core` PR #4173. If PR is not
    ///   accepted by version release, will be updated to accept a seed
    ///   as a function argument.
    ///
    /// # Aborts if
    /// * `econia` does not indicate the Econia account.
    fun init_fee_account(
        econia: &signer
    ): signer {
        // Assert signer is from Econia account.
        assert!(address_of(econia) == @econia, E_NOT_ECONIA);
        // Create resource account, storing signing capability.
        let (fee_account, fee_account_signer_capability) = account::
            create_resource_account(econia, b"");
        // Store fee account signer capability under Econia account.
        move_to(econia, FeeAccountSignerCapabilityStore{
            fee_account_signer_capability});
        fee_account // Return fee account signer.
    }

    /// Initialize a `UtilityCoinStore` under the Econia fee account.
    ///
    /// Returns without initializing if a `UtilityCoinStore` already
    /// exists for given `CoinType`.
    ///
    /// # Type Parameters
    /// * `CoinType`: Utility coin phantom type.
    ///
    /// # Parameters
    /// * `fee_account`: Econia fee account `signer`.
    ///
    /// # Aborts if
    /// * `CoinType` does not correspond to an initialized
    ///   `aptos_framework::coin::Coin`.
    fun init_utility_coin_store<CoinType>(
        fee_account: &signer
    ) {
        // Assert coin type corresponds to initialized coin.
        assert!(coin::is_coin_initialized<CoinType>(), E_NOT_COIN);
        // If a utility coin store does not already exist at account,
        if(!exists<UtilityCoinStore<CoinType>>(address_of(fee_account)))
            // Initialize one and move it to the account.
            move_to<UtilityCoinStore<CoinType>>(fee_account, UtilityCoinStore{
                coins: coin::zero<CoinType>()});
    }

    /// Set all fields for `IncentiveParameters` under Econia account.
    ///
    /// Rather than pass-by-value a
    /// `vector<IntegratorFeeStoreTierParameters>`, mutably reassigns
    /// the values of `IncentiveParameters.integrator_fee_store_tiers`
    /// via `set_incentive_parameters_parse_tiers_vector()`.
    ///
    /// # Type Parameters
    /// * `UtilityCoinType`: Utility coin phantom type.
    ///
    /// # Parameters
    /// * `econia`: Econia account `signer`.
    /// * `market_registration_fee_ref`: Immutable reference to market
    ///   registration fee to set.
    /// * `custodian_registration_fee_ref`: Immutable reference to
    ///   custodian registration fee to set.
    /// * `taker_fee_divisor_ref`: Immutable reference to
    ///   taker fee divisor to set.
    /// * `integrator_fee_store_tiers_ref`: Immutable reference to
    ///   0-indexed vector of 3-element vectors, with each 3-element
    ///   vector containing fields for a corresponding
    ///   `IntegratorFeeStoreTierParameters`.
    /// * `updating_ref`: `&true` if updating incentive parameters that
    ///   have already beeen set, `&false` if setting parameters for the
    ///   first time.
    ///
    /// # Assumptions
    /// * If `updating_ref` is `&true`, an `IncentiveParameters` and a
    ///   `FeeAccountSignerCapabilityStore` already exist at the Econia
    ///   account.
    /// * If `updating_ref` is `&false`, neither an
    ///   `IncentiveParameters` nor a `FeeAccountSignerCapabilityStore`
    ///   exist at the Econia account.
    ///
    /// # Aborts if
    /// * `updating_ref` is `&true` and the new parameter set indicates
    ///   a reduction in the number of fee store activation tiers, which
    ///   would mean that integrators who had previously upgraded to the
    ///   highest tier would become subject to undefined behavior.
    fun set_incentive_parameters<UtilityCoinType>(
        econia: &signer,
        market_registration_fee_ref: &u64,
        custodian_registration_fee_ref: &u64,
        taker_fee_divisor_ref: &u64,
        integrator_fee_store_tiers_ref: &vector<vector<u64>>,
        updating_ref: &bool
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters
    {
        // Range check inputs.
        set_incentive_parameters_range_check_inputs(econia,
            market_registration_fee_ref, custodian_registration_fee_ref,
            taker_fee_divisor_ref, integrator_fee_store_tiers_ref);
        // Get fee account signer: if updating previously-set values,
        // get it from the stored capability.
        let fee_account = if (*updating_ref) get_fee_account() else
            // Else get fee account signer by initializing the account.
            init_fee_account(econia);
        // Initialize a utility coin store under the fee acount (aborts
        // if not an initialized coin type).
        init_utility_coin_store<UtilityCoinType>(&fee_account);
        if (*updating_ref) { // If updating previously-set values:
            // Assert new parameters set indicates at least as many fee
            // store tiers as the set from before the upgrade.
            assert!(vector::length(integrator_fee_store_tiers_ref) >=
                get_n_fee_store_tiers(), E_FEWER_TIERS);
        } else { // If initializing parameter set:
            // Initialize an incentive parameters resource with
            // range-checked inputs and empty tiers vector.
            move_to<IncentiveParameters>(econia, IncentiveParameters{
                utility_coin_type_info: type_info::type_of<UtilityCoinType>(),
                market_registration_fee: *market_registration_fee_ref,
                custodian_registration_fee: *custodian_registration_fee_ref,
                taker_fee_divisor: *taker_fee_divisor_ref,
                integrator_fee_store_tiers: vector::empty()
            });
        };
        // Borrow a mutable reference to the incentive parameters
        // resource at the Econia account.
        let incentive_parameters_ref_mut =
            borrow_global_mut<IncentiveParameters>(@econia);
        // Parse in integrator fee store tiers (aborts for invalid
        // values).
        if (*updating_ref) { // If updating previously-set values:
            incentive_parameters_ref_mut.utility_coin_type_info =
                type_info::type_of<UtilityCoinType>();
            // Set market registration fee.
            incentive_parameters_ref_mut.market_registration_fee =
                *market_registration_fee_ref;
            // Set custodian registration fee.
            incentive_parameters_ref_mut.custodian_registration_fee =
                *custodian_registration_fee_ref;
            // Set taker fee divisor.
            incentive_parameters_ref_mut.taker_fee_divisor =
                *taker_fee_divisor_ref;
            // Set integrator fee stores to empty vector.
            incentive_parameters_ref_mut.integrator_fee_store_tiers =
                vector::empty();
        };
        set_incentive_parameters_parse_tiers_vector(
            taker_fee_divisor_ref, integrator_fee_store_tiers_ref,
            &mut incentive_parameters_ref_mut.integrator_fee_store_tiers);
    }

    /// Parse vectorized fee store tier parameters passed to
    /// `set_incentive_parameters()`.
    ///
    /// * `taker_fee_divisor_ref`: Immutable reference to
    ///   taker fee divisor to compare against.
    /// * `integrator_fee_store_tiers_ref`: Immutable reference to
    ///   0-indexed vector of 3-element vectors, with each 3-element
    ///   vector containing fields for a corresponding
    ///   `IntegratorFeeStoreTierParameters`.
    /// * `integrator_fee_store_tiers_target_ref_mut`: Mutable reference
    ///   to the `IncentiveParameters.integrator_fee_store_tiers` field
    ///   to parse into.
    ///
    /// # Aborts if
    /// * An indicated inner vector from
    ///   `integrator_fee_store_tiers_ref` is the wrong length.
    /// * Fee share divisor does not decrease with tier number.
    /// * A fee share divisor is less than taker fee divisor.
    /// * Tier activation fee does not increase with tier number.
    /// * There is no tier activation fee for the first tier.
    /// * Withdrawal fee does not decrease with tier number.
    /// * The withdrawal fee for a given tier does not meet minimum
    ///   threshold.
    ///
    /// # Assumptions
    /// * `taker_fee_divisor_ref` indicates a value that has already
    ///   been range-checked.
    /// * An `IncentiveParameters` exists at the Econia account.
    /// * `integrator_fee_store_tiers_ref` does not indicate an empty
    ///   vector.
    /// * `integrator_fee_store_tiers_target_ref_mut` indicates an empty
    ///   vector.
    fun set_incentive_parameters_parse_tiers_vector(
        taker_fee_divisor_ref: &u64,
        integrator_fee_store_tiers_ref: &vector<vector<u64>>,
        integrator_fee_store_tiers_target_ref_mut:
            &mut vector<IntegratorFeeStoreTierParameters>
    ) {
        // Initialize tracker variables for the fee store parameters of
        // the last parsed tier. Flagged such that activation fee must
        // be nonzero even for the first tier.
        let (divisor_last, activation_fee_last, withdrawal_fee_last) = (
                    HI_64,                   0,               HI_64);
        // Get number of specified integrator fee store tiers.
        let n_tiers = vector::length(integrator_fee_store_tiers_ref);
        let i = 0; // Declare counter for loop variable.
        while (i < n_tiers) { // Loop over all specified tiers
            // Borrow immutable reference to fields for given tier.
            let tier_fields_ref =
                vector::borrow(integrator_fee_store_tiers_ref, i);
            // Assert containing vector is correct length.
            assert!(vector::length(tier_fields_ref) == N_TIER_FIELDS,
                E_TIER_FIELDS_WRONG_LENGTH);
            // Borrow immutable reference to fee share divisor.
            let fee_share_divisor_ref =
                vector::borrow(tier_fields_ref, FEE_SHARE_DIVISOR_INDEX);
            // Assert indicated fee share divisor is less than divisor
            // from last tier.
            assert!(*fee_share_divisor_ref < divisor_last,
                E_FEE_SHARE_DIVISOR_TOO_BIG);
            // Assert indicated fee share divisor is greater than or
            // equal to taker fee divisor.
            assert!(*fee_share_divisor_ref >= *taker_fee_divisor_ref,
                E_FEE_SHARE_DIVISOR_TOO_SMALL);
            // Borrow immutable reference to tier activation fee.
            let tier_activation_fee_ref =
                vector::borrow(tier_fields_ref, TIER_ACTIVATION_FEE_INDEX);
            // Assert activation fee is greater than that of last tier.
            assert!(*tier_activation_fee_ref > activation_fee_last,
                E_ACTIVATION_FEE_TOO_SMALL);
            // Borrow immutable reference to withdrawal fee.
            let withdrawal_fee_ref =
                vector::borrow(tier_fields_ref, WITHDRAWAL_FEE_INDEX);
            // Assert withdrawal fee is less than that of last tier.
            assert!(*withdrawal_fee_ref < withdrawal_fee_last,
                E_WITHDRAWAL_FEE_TOO_BIG);
            // Assert withdrawal fee is above minimum threshold.
            assert!(*withdrawal_fee_ref > MIN_FEE, E_WITHDRAWAL_FEE_TOO_SMALL);
            // Mark indicated tier in target tiers vector.
            vector::push_back(integrator_fee_store_tiers_target_ref_mut,
                IntegratorFeeStoreTierParameters{
                    fee_share_divisor: *fee_share_divisor_ref,
                    tier_activation_fee: *tier_activation_fee_ref,
                    withdrawal_fee: *withdrawal_fee_ref});
            // Store divisor for comparison during next iteration.
            divisor_last = *fee_share_divisor_ref;
            // Store activation fee to compare during next iteration.
            activation_fee_last = *tier_activation_fee_ref;
            // Store withdrawal fee to compare during next iteration.
            withdrawal_fee_last = *withdrawal_fee_ref;
            i = i + 1; // Increment loop counter
        };
    }

    /// Range check inputs for `set_incentive_parameters()`.
    ///
    /// # Parameters
    /// * `econia`: Econia account `signer`.
    /// * `market_registration_fee_ref`: Immutable reference to market
    ///   registration fee to set.
    /// * `custodian_registration_fee_ref`: Immutable reference to
    ///   custodian registration fee to set.
    /// * `taker_fee_divisor_ref`: Immutable reference to
    ///   taker fee divisor to set.
    /// * `integrator_fee_store_tiers_ref`: Immutable reference to
    ///   0-indexed vector of 3-element vectors, with each 3-element
    ///   vector containing fields for a corresponding
    ///   `IntegratorFeeStoreTierParameters`.
    ///
    /// # Aborts if
    /// * `econia` is not Econia account.
    /// * `market_registration_fee_ref` indicates fee that does not
    ///   meet minimum threshold.
    /// * `custodian_registration_fee_ref` indicates fee that does
    ///   not meet minimum threshold.
    /// * `taker_fee_divisor_ref` indicates divisor that does not
    ///   meet minimum threshold.
    /// * `integrator_fee_store_tiers_ref` indicates an empty vector.
    /// * `integrator_fee_store_tiers_ref` indicates a vector that is
    ///   too long.
    fun set_incentive_parameters_range_check_inputs(
        econia: &signer,
        market_registration_fee_ref: &u64,
        custodian_registration_fee_ref: &u64,
        taker_fee_divisor_ref: &u64,
        integrator_fee_store_tiers_ref: &vector<vector<u64>>
    ) {
        // Assert signer is from Econia account.
        assert!(address_of(econia) == @econia, E_NOT_ECONIA);
        // Assert market registration fee meets minimum threshold.
        assert!(*market_registration_fee_ref >= MIN_FEE,
            E_MARKET_REGISTRATION_FEE_LESS_THAN_MIN);
        // Assert custodian registration fee meets minimum threshold.
        assert!(*custodian_registration_fee_ref >= MIN_FEE,
            E_CUSTODIAN_REGISTRATION_FEE_LESS_THAN_MIN);
        // Assert taker fee divisor is meets minimum threshold.
        assert!(*taker_fee_divisor_ref >= MIN_DIVISOR,
            E_TAKER_DIVISOR_LESS_THAN_MIN);
        // Assert integrator fee store parameters vector not empty.
        assert!(!vector::is_empty(integrator_fee_store_tiers_ref),
            E_EMPTY_FEE_STORE_TIERS);
        // Assert integrator fee store parameters vector not too long.
        assert!(vector::length(integrator_fee_store_tiers_ref) <=
            MAX_INTEGRATOR_FEE_STORE_TIERS, E_TOO_MANY_TIERS);
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    const MARKET_REGISTRATION_FEE: u64 = 1000;
    #[test_only]
    const CUSTODIAN_REGISTRATION_FEE: u64 = 100;
    #[test_only]
    const TAKER_FEE_DIVISOR: u64 = 2000;
    #[test_only]
    const FEE_SHARE_DIVISOR_0: u64 = 4000;
    #[test_only]
    const FEE_SHARE_DIVISOR_1: u64 = 3000;
    #[test_only]
    const TIER_ACTIVATION_FEE_0: u64 = 150;
    #[test_only]
    const TIER_ACTIVATION_FEE_1: u64 = 225;
    #[test_only]
    const WITHDRAWAL_FEE_0: u64 = 10;
    #[test_only]
    const WITHDRAWAL_FEE_1: u64 = 5;

    // Test-only constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return amount of quote coins in `EconiaFeeStore` for given
    /// `QuoteCoinType` and `market_id`.
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions.
    public fun get_econia_fee_store_balance_test<QuoteCoinType>(
        market_id: u64
    ): u64
    acquires
        EconiaFeeStore,
        FeeAccountSignerCapabilityStore
    {
        coin::value(table_list::borrow(
            &borrow_global<EconiaFeeStore<QuoteCoinType>>(
                    get_fee_account_address()).map, market_id))
    }

    #[test_only]
    /// Return amount of quote coins in `IntegratorFeeStore` for given
    /// `QuoteCoinType` and `market_id`.
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions.
    public fun get_integrator_fee_store_balance_test<QuoteCoinType>(
        integrator: address,
        market_id: u64
    ): u64
    acquires
        IntegratorFeeStores
    {
        coin::value(&table_list::borrow(
            &borrow_global<IntegratorFeeStores<QuoteCoinType>>(integrator).map,
                market_id).coins)
    }

    #[test_only]
    /// Return activation tier of `IntegratorFeeStore` for given
    /// `QuoteCoinType` and `market_id`.
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions.
    public fun get_integrator_fee_store_tier_test<QuoteCoinType>(
        integrator: address,
        market_id: u64
    ): u8
    acquires
        IntegratorFeeStores
    {
        table_list::borrow(&borrow_global<IntegratorFeeStores<QuoteCoinType>>(
            integrator).map, market_id).tier
    }

    #[test_only]
    /// Return amount of utility coins in `UtilityCoinStore` for utility
    /// coin type `UC`.
    ///
    /// # Restrictions
    /// * Restricted to test-only to prevent excessive public queries
    ///   and thus transaction collisions.
    public fun get_utility_coin_store_balance_test():
    u64
    acquires
        FeeAccountSignerCapabilityStore,
        UtilityCoinStore
    {
        coin::value(&borrow_global<UtilityCoinStore<UC>>(
                get_fee_account_address()).coins)
    }

    #[test_only]
    /// Initialize incentives using test-only constants.
    public fun init_incentives_test()
    acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters
    {
        assets::init_coin_types_test(); // Initialize coin types.
        // Get signer for Econia account.
        let econia = account::create_signer_with_capability(
            &account::create_test_signer_cap(@econia));
        // Vectorize fee store tier parameters.
        let tier_0 = vector::singleton(FEE_SHARE_DIVISOR_0);
        vector::push_back(&mut tier_0, TIER_ACTIVATION_FEE_0);
        vector::push_back(&mut tier_0, WITHDRAWAL_FEE_0);
        let tier_1 = vector::singleton(FEE_SHARE_DIVISOR_1);
        vector::push_back(&mut tier_1, TIER_ACTIVATION_FEE_1);
        vector::push_back(&mut tier_1, WITHDRAWAL_FEE_1);
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        vector::push_back(&mut integrator_fee_store_tiers, tier_1);
        // Initialize incentives.
        init_incentives<UC>(&econia, &MARKET_REGISTRATION_FEE,
            &CUSTODIAN_REGISTRATION_FEE, &TAKER_FEE_DIVISOR,
            &integrator_fee_store_tiers);
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify max quote match amounts.
    fun test_calculate_max_quote_match() {
        // Declare matching parameters.
        let direction = BUY;
        let taker_fee_divisor = 20;
        let max_quote_delta_user = 105;
        let max_quote_match = 0;
        let max_quote_match_expected = 100;
        // Reassign max quote match value.
        calculate_max_quote_match(&direction, &taker_fee_divisor,
            &max_quote_delta_user, &mut max_quote_match);
        // Assert calculated amount.
        assert!(max_quote_match == max_quote_match_expected, 0);
        // Repeat for a sell.
        direction = SELL;
        taker_fee_divisor = 25;
        max_quote_delta_user = 100;
        max_quote_match = 0;
        max_quote_match_expected = 104;
        // Reassign max quote match value.
        calculate_max_quote_match(&direction, &taker_fee_divisor,
            &max_quote_delta_user, &mut max_quote_match);
        // Assert calculated amount.
        assert!(max_quote_match == max_quote_match_expected, 0);
    }

    #[test]
    #[expected_failure(abort_code = 17)]
    /// Verify failure for overflowing quote match amount.
    fun test_calculate_max_quote_match_overflow() {
        // Declare matching parameters.
        let direction = SELL;
        let taker_fee_divisor = 20;
        let max_quote_delta_user = HI_64;
        let max_quote_match = 0;
        // Attempt invalid invocation.
        calculate_max_quote_match(&direction, &taker_fee_divisor,
            &max_quote_delta_user, &mut max_quote_match);
    }

    #[test]
    /// Verify deposits for mixed registration fees.
    fun test_deposit_registration_fees_mixed()
    acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        UtilityCoinStore
    {
        init_incentives_test(); // Initialize incentives.
        // Get registration fees.
        let (custodian_registration_fee      , market_registration_fee      ) =
            (get_custodian_registration_fee(), get_market_registration_fee());
        // Deposit fees.
        deposit_custodian_registration_utility_coins<UC>(assets::mint_test(
            custodian_registration_fee));
        deposit_market_registration_utility_coins<UC>(assets::mint_test(
            market_registration_fee));
        // Assert total amount.
        assert!(get_utility_coin_store_balance_test() ==
            custodian_registration_fee + market_registration_fee, 0);
    }

    #[test]
    #[expected_failure(abort_code = 13)]
    /// Verify failure for not enough utility coins.
    fun test_deposit_utility_coins_verified_not_enough()
    acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        UtilityCoinStore
    {
        init_incentives_test(); // Init incentives.
        // Attempt invalid invocation.
        deposit_utility_coins_verified(coin::zero<UC>(), &1);
    }

    #[test(econia = @econia)]
    /// Verify deposit and withdrawal of utility coins.
    fun test_deposit_withdraw_utility_coins(
        econia: &signer
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        UtilityCoinStore
    {
        init_incentives_test(); // Initialize incentives.
        // Deposit utility coins.
        deposit_utility_coins(assets::mint_test<UC>(100));
        // Withdraw some utility coins.
        let coins = withdraw_utility_coins<UC>(econia, 40);
        assert!(coin::value(&coins) == 40, 0); // Assert value.
        assets::burn(coins); // Burn coins
        // Withdraw all utility coins
        coins = withdraw_utility_coins_all<UC>(econia);
        assert!(coin::value(&coins) == 60, 0); // Assert value.
        assets::burn(coins); // Burn coins
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for non-Econia caller.
    fun test_init_fee_account_not_econia(
        account: &signer
    ) {
        init_fee_account(account); // Attempt invalid invocation.
    }

    #[test(econia = @econia)]
    /// Verify initializing, updating, and getting incentive parameters.
    fun test_init_update_get_incentives(
        econia: &signer
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters
    {
        assets::init_coin_types_test(); // Init coin types.
        // Declare incentive parameters.
        let market_registration_fee = 123;
        let custodian_registration_fee = 456;
        let taker_fee_divisor = 789;
        let fee_share_divisor_0 = 1234;
        let tier_activation_fee_0 = 2345;
        let withdrawal_fee_0 = 3456;
        // Vectorize fee store tier parameters.
        let tier_0 = vector::singleton(fee_share_divisor_0);
        vector::push_back(&mut tier_0, tier_activation_fee_0);
        vector::push_back(&mut tier_0, withdrawal_fee_0);
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        // Initialize incentives.
        init_incentives<UC>(econia, &market_registration_fee,
            &custodian_registration_fee, &taker_fee_divisor,
            &integrator_fee_store_tiers);
        // Assert state.
        verify_utility_coin_type<UC>();
        assert!(!is_utility_coin_type<QC>(), 0);
        assert!(get_market_registration_fee() == market_registration_fee, 0);
        assert!(get_custodian_registration_fee() ==
            custodian_registration_fee, 0);
        assert!(get_taker_fee_divisor() == taker_fee_divisor, 0);
        assert!(get_n_fee_store_tiers() == 1, 0);
        assert!(get_fee_share_divisor(&(0 as u8)) == fee_share_divisor_0, 0);
        assert!(get_tier_activation_fee(&(0 as u8)) ==
            tier_activation_fee_0, 0);
        assert!(get_withdrawal_fee(&(0 as u8)) == withdrawal_fee_0, 0);
        assert!(exists<UtilityCoinStore<UC>>(get_fee_account_address()), 0);
        // Update incentive parameters, now with 2 tiers.
        market_registration_fee = market_registration_fee + 5;
        custodian_registration_fee = custodian_registration_fee + 5;
        taker_fee_divisor = taker_fee_divisor + 5;
        fee_share_divisor_0 = fee_share_divisor_0 + 5;
        tier_activation_fee_0 = tier_activation_fee_0 + 5;
        withdrawal_fee_0 = tier_activation_fee_0 + 5;
        let fee_share_divisor_1 = fee_share_divisor_0 - 1;
        let tier_activation_fee_1 = tier_activation_fee_0 + 1;
        let withdrawal_fee_1 = tier_activation_fee_0 - 1;
        // Vectorize fee store tier parameters.
        tier_0 = vector::singleton(fee_share_divisor_0);
        vector::push_back(&mut tier_0, tier_activation_fee_0);
        vector::push_back(&mut tier_0, withdrawal_fee_0);
        let tier_1 = vector::singleton(fee_share_divisor_1);
        vector::push_back(&mut tier_1, tier_activation_fee_1);
        vector::push_back(&mut tier_1, withdrawal_fee_1);
        integrator_fee_store_tiers = vector::singleton(tier_0);
        vector::push_back(&mut integrator_fee_store_tiers, tier_1);
        // Update incentives.
        update_incentives<QC>(econia, market_registration_fee,
            custodian_registration_fee, taker_fee_divisor,
            integrator_fee_store_tiers);
        // Assert state.
        verify_utility_coin_type<QC>();
        assert!(!is_utility_coin_type<UC>(), 0);
        assert!(get_market_registration_fee() == market_registration_fee, 0);
        assert!(get_custodian_registration_fee() ==
            custodian_registration_fee, 0);
        assert!(get_taker_fee_divisor() == taker_fee_divisor, 0);
        assert!(get_n_fee_store_tiers() == 2, 0);
        assert!(get_fee_share_divisor(&(0 as u8)) == fee_share_divisor_0, 0);
        assert!(get_tier_activation_fee(&(0 as u8)) ==
            tier_activation_fee_0, 0);
        assert!(get_withdrawal_fee(&(0 as u8)) == withdrawal_fee_0, 0);
        assert!(get_fee_share_divisor(&(1 as u8)) == fee_share_divisor_1, 0);
        assert!(get_tier_activation_fee(&(1 as u8)) ==
            tier_activation_fee_1, 0);
        assert!(get_withdrawal_fee(&(1 as u8)) == withdrawal_fee_1, 0);
        assert!(exists<UtilityCoinStore<QC>>(get_fee_account_address()), 0);
    }

    #[test(econia = @econia)]
    /// Verify successful `UtilityCoinStore` initialization.
    fun test_init_utility_coin_store(
        econia: &signer
    ) {
        assets::init_coin_types_test(); // Init coin types.
        let fee_account = init_fee_account(econia); // Init fee account.
        // Init utility coin store under fee account.
        init_utility_coin_store<QC>(&fee_account);
        // Verify can call re-init for when already initialized.
        init_utility_coin_store<QC>(&fee_account);
        // Assert a utility coin store exists under fee account.
        assert!(exists<UtilityCoinStore<QC>>(address_of(&fee_account)), 0);
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for attempting to initialize with non-coin type.
    fun test_init_utility_coin_store_not_coin(
        account: &signer
    ) {
        // Attempt invalid invocation.
        init_utility_coin_store<IncentiveParameters>(account);
    }

    #[test(
        econia = @econia,
        integrator = @user
    )]
    /// Verify registration of assorted coin stores, fee assessment, and
    /// withdrawal scenarios.
    fun test_register_assess_withdraw(
        econia: &signer,
        integrator: &signer
    ) acquires
        EconiaFeeStore,
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        IntegratorFeeStores,
        UtilityCoinStore
    {
        init_incentives_test(); // Init incentives.
        // Declare market IDs.
        let (market_id_0, market_id_1, market_id_2) = (0, 1, 2); // Declare market IDs.
        // Declare integrator fee store tiers.
        let (tier_0, tier_1) = (0, 1);
        // Declare utility coin balance after integrator registration.
        let utility_coin_balance_0 = get_tier_activation_fee(&tier_0) +
            get_tier_activation_fee(&tier_1);
        // Declare utility coin balance after integrator fee withdrawal.
        let utility_coin_balance_1 = utility_coin_balance_0 +
            get_withdrawal_fee(&tier_0);
        let quote_fill_0 = 12345; // Declare quote fill amount, fill 0.
        // Calculate integrator fee share for fill 0.
        let integrator_fees_0 = quote_fill_0 / get_fee_share_divisor(&tier_0);
        // Calculate taker fees assessed on fill 0.
        let taker_fees_0 = quote_fill_0 / get_taker_fee_divisor();
        // Calculate Econia fees assessed on fill 0.
        let econia_fees_0 = taker_fees_0 - integrator_fees_0;
        let quote_fill_1 = 54321; // Declare quote fill amount, fill 1.
        // Declare Econia fees for fill 1, where integrator does not
        // have a fee stores map for given quote coin types
        let econia_fees_1 = quote_fill_1 / get_taker_fee_divisor();
        let quote_fill_2 = 23456; // Declare quote fill amount, fill 2.
        // Declare Econia fees for fill 2, where integrator does not
        // have a fee store for given market ID.
        let econia_fees_2 = quote_fill_2 / get_taker_fee_divisor();
        // Register an Econia fee store for all markets.
        register_econia_fee_store_entry<QC>(&market_id_0);
        register_econia_fee_store_entry<QC>(&market_id_1);
        register_econia_fee_store_entry<QC>(&market_id_2);
        // Register an integrator fee store for first two markets.
        register_integrator_fee_store<QC, UC>(integrator, &market_id_0,
            &tier_0, assets::mint_test(get_tier_activation_fee(&tier_0)));
        register_integrator_fee_store<QC, UC>(integrator, &market_id_1,
            &tier_1, assets::mint_test(get_tier_activation_fee(&tier_1)));
        // Assert tiers.
        assert!(get_integrator_fee_store_tier_test<QC>(@user, market_id_0) ==
            tier_0, 0);
        assert!(get_integrator_fee_store_tier_test<QC>(@user, market_id_1) ==
            tier_1, 0);
        // Assert utility coins deposited.
        assert!(get_utility_coin_store_balance_test() ==
            utility_coin_balance_0, 0);
        // Mint enough quote coins to cover taker fees for fill 0.
        let quote_coins = assets::mint_test(taker_fees_0);
        // Assess fees on fill 0.
        assess_fees<QC>(&market_id_0, &@user, &quote_fill_0, &mut quote_coins);
        // Destroy empty coins, asserting that all taker fees assessed.
        coin::destroy_zero(quote_coins);
        assert!(get_econia_fee_store_balance_test<QC>(market_id_0) ==
            econia_fees_0, 0); // Assert Econia fee share.
        assert!(get_integrator_fee_store_balance_test<QC>(@user, market_id_0)
            == integrator_fees_0, 0); // Assert integrator fee share.
        // Mint enough quote coins to cover taker fees for fill 1.
        quote_coins = assets::mint_test(econia_fees_1);
        // Assess fees on fill 1.
        assess_fees<QC>(&market_id_1, &@econia, &quote_fill_1,
            &mut quote_coins);
        // Destroy empty coins, asserting that all taker fees assessed.
        coin::destroy_zero(quote_coins);
        assert!(get_econia_fee_store_balance_test<QC>(market_id_1) ==
            econia_fees_1, 0); // Assert Econia fee share.
        // Mint enough quote coins to cover taker fees for fill 2.
        quote_coins = assets::mint_test(econia_fees_2);
        // Assess fees on fill 2.
        assess_fees<QC>(&market_id_2, &@user, &quote_fill_2, &mut quote_coins);
        // Destroy empty coins, asserting that all taker fees assessed.
        coin::destroy_zero(quote_coins);
        assert!(get_econia_fee_store_balance_test<QC>(market_id_2) ==
            econia_fees_2, 0); // Assert Econia fee share.
        // Have integrator withdraw all fees for market id 0.
        quote_coins = withdraw_integrator_fees<QC, UC>(integrator, market_id_0,
            assets::mint_test<UC>(get_withdrawal_fee(&tier_0)));
        // Assert integrator got all coins.
        assert!(coin::value(&quote_coins) == integrator_fees_0, 0);
        assets::burn(quote_coins); // Burn coins.
        // Assert utility coins deposited.
        assert!(get_utility_coin_store_balance_test() ==
            utility_coin_balance_1, 0);
        // Have Econia withdraw 1 coin for market ID 0.
        quote_coins = withdraw_econia_fees<QC>(econia, &market_id_0, &1);
        // Assert 1 coin withdrawn.
        assert!(coin::value(&quote_coins) == 1, 0);
        assets::burn(quote_coins); // Burn coins.
        // Have Econia withdraw all coins for market ID 0.
        quote_coins = withdraw_econia_fees_all<QC>(econia, &market_id_0);
        // Assert remaining coins withdrawn.
        assert!(coin::value(&quote_coins) == econia_fees_0 - 1, 0);
        assets::burn(quote_coins); // Burn coins.
        // Have Econia withdraw 1 utility coin.
        let utility_coins = withdraw_utility_coins<UC>(econia, 1);
        // Assert 1 coin withdrawn.
        assert!(coin::value(&utility_coins) == 1, 0);
        assets::burn(utility_coins); // Burn coins.
        // Have Econia withdraw all utility coins.
        utility_coins = withdraw_utility_coins_all<UC>(econia);
        // Assert remaining coins withdrawn.
        assert!(coin::value(&utility_coins) == utility_coin_balance_1 - 1, 0);
        assets::burn(utility_coins); // Burn coins.
    }

    #[test]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for activation fee too small on 0th tier.
    fun test_sent_incentive_parameters_parse_tiers_vector_activation_0() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        // Divisor.
        let tier_0 = vector::singleton(taker_fee_divisor + 1);
        vector::push_back(&mut tier_0, 0); // Activation fee.
        vector::push_back(&mut tier_0, HI_64 - 1); // Withdrawal fee.
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test]
    #[expected_failure(abort_code = 9)]
    /// Verify failure for activation fee too small on 1st tier.
    fun test_sent_incentive_parameters_parse_tiers_vector_activation_1() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        // Divisor.
        let tier_0 = vector::singleton(taker_fee_divisor + 2);
        vector::push_back(&mut tier_0, 1); // Activation fee.
        vector::push_back(&mut tier_0, HI_64 - 1); // Withdrawal fee.
        // Divisor.
        let tier_1 = vector::singleton(taker_fee_divisor + 1);
        vector::push_back(&mut tier_1, 1); // Activation fee.
        vector::push_back(&mut tier_1, HI_64 - 2); // Withdrawal fee.
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        vector::push_back(&mut integrator_fee_store_tiers, tier_1);
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for fee share divisor too big on 0th tier.
    fun test_sent_incentive_parameters_parse_tiers_vector_divisor_big_0() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        let tier_0 = vector::singleton(HI_64); // Divisor.
        vector::push_back(&mut tier_0, 0); // Activation fee.
        vector::push_back(&mut tier_0, 0); // Withdrawal fee.
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for fee share divisor too big on 1st tier.
    fun test_sent_incentive_parameters_parse_tiers_vector_divisor_big_1() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        // Divisor.
        let tier_0 = vector::singleton(taker_fee_divisor + 1);
        vector::push_back(&mut tier_0, 1); // Activation fee.
        vector::push_back(&mut tier_0, HI_64 - 1); // Withdrawal fee.
        // Divisor.
        let tier_1 = vector::singleton(taker_fee_divisor + 1);
        vector::push_back(&mut tier_1, 2); // Activation fee.
        vector::push_back(&mut tier_1, HI_64 - 2); // Withdrawal fee.
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        vector::push_back(&mut integrator_fee_store_tiers, tier_1);
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for fee share divisor too small.
    fun test_sent_incentive_parameters_parse_tiers_vector_divisor_small() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        // Divisor.
        let tier_0 = vector::singleton(taker_fee_divisor - 1);
        vector::push_back(&mut tier_0, 0); // Activation fee.
        vector::push_back(&mut tier_0, 0); // Withdrawal fee.
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for withdrawal fee too big on 0th tier.
    fun test_sent_incentive_parameters_parse_tiers_vector_withdraw_big_0() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        // Divisor.
        let tier_0 = vector::singleton(taker_fee_divisor + 2);
        vector::push_back(&mut tier_0, 1); // Activation fee.
        vector::push_back(&mut tier_0, HI_64); // Withdrawal fee.
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test]
    #[expected_failure(abort_code = 10)]
    /// Verify failure for withdrawal fee too big on 1st tier.
    fun test_sent_incentive_parameters_parse_tiers_vector_withdraw_big_1() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        // Divisor.
        let tier_0 = vector::singleton(taker_fee_divisor + 2);
        vector::push_back(&mut tier_0, 1); // Activation fee.
        vector::push_back(&mut tier_0, HI_64 - 1); // Withdrawal fee.
        // Divisor.
        let tier_1 = vector::singleton(taker_fee_divisor + 1);
        vector::push_back(&mut tier_1, 2); // Activation fee.
        vector::push_back(&mut tier_1, HI_64 - 1); // Withdrawal fee.
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        vector::push_back(&mut integrator_fee_store_tiers, tier_1);
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test]
    #[expected_failure(abort_code = 11)]
    /// Verify failure for withdrawal fee too small.
    fun test_sent_incentive_parameters_parse_tiers_vector_withdraw_small() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        // Divisor.
        let tier_0 = vector::singleton(taker_fee_divisor + 1);
        vector::push_back(&mut tier_0, 1); // Activation fee.
        vector::push_back(&mut tier_0, 0); // Withdrawal fee.
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify failure for wrong length of inner vector.
    fun test_sent_incentive_parameters_parse_tiers_vector_wrong_length() {
        // Declare mock inputs.
        let taker_fee_divisor = 2345;
        let integrator_fee_store_tiers = vector::singleton(vector::empty());
        let integrator_fee_store_tiers_target = vector::empty();
        set_incentive_parameters_parse_tiers_vector(
            &taker_fee_divisor, &integrator_fee_store_tiers,
            &mut integrator_fee_store_tiers_target);
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 6)]
    /// Verify failure for custodian registration fee too low.
    fun test_set_incentive_parameters_range_check_inputs_custodian_fee(
        econia: &signer
    ) {
        // Attempt invalid invocation.
        set_incentive_parameters_range_check_inputs(econia, &1, &0, &0,
            &vector::empty());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 7)]
    /// Verify failure for divisor too low.
    fun test_set_incentive_parameters_range_check_inputs_divisor(
        econia: &signer
    ) {
        // Attempt invalid invocation.
        set_incentive_parameters_range_check_inputs(econia, &1, &1, &0,
            &vector::empty());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for market registration fee too low.
    fun test_set_incentive_parameters_range_check_inputs_market_fee(
        econia: &signer
    ) {
        // Attempt invalid invocation.
        set_incentive_parameters_range_check_inputs(econia, &0, &0, &0,
            &vector::empty());
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for not Econia account.
    fun test_set_incentive_parameters_range_check_inputs_not_econia(
        account: &signer
    ) {
        // Attempt invalid invocation.
        set_incentive_parameters_range_check_inputs(account, &0, &0, &0,
            &vector::empty());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 2)]
    /// Verify failure for empty fee store tiers.
    fun test_set_incentive_parameters_range_check_inputs_vector_empty(
        econia: &signer
    ) {
        // Attempt invalid invocation.
        set_incentive_parameters_range_check_inputs(econia, &1, &1, &1,
            &vector::empty());
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 14)]
    /// Verify failure for too many elements in fee store tiers vector.
    fun test_set_incentive_parameters_range_check_inputs_vector_long(
        econia: &signer
    ) {
        // Declare empty integrator fee store tiers vector.
        let integrator_fee_store_tiers = vector::empty();
        let i = 0; // Declare loop counter.
        // For one iteration more than the number of max tiers:
        while (i < MAX_INTEGRATOR_FEE_STORE_TIERS + 1) {
            // Push back an empty vector onto fee store tiers vector.
            vector::push_back(&mut integrator_fee_store_tiers,
                vector::empty());
            i = i + 1; // Increment loop counter.
        };
        // Attempt invalid invocation.
        set_incentive_parameters_range_check_inputs(econia, &1, &1, &1,
            &integrator_fee_store_tiers);
    }

    #[test(integrator = @user)]
    /// Verify upgrade deposits.
    fun test_upgrade_integrator_fee_store(
        integrator: &signer
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        IntegratorFeeStores,
        UtilityCoinStore
    {
        init_incentives_test(); // Init incentives.
        // Declare market ID, tier.
        let (market_id, tier_start, tier_upgrade) = (0, 0, 1);
        // Declare activation fee for start and upgrade tiers.
        let (fee_start, fee_upgrade) = (get_tier_activation_fee(&tier_start),
            get_tier_activation_fee(&tier_upgrade));
        // Register to start tier.
        register_integrator_fee_store<QC, UC>(integrator, &market_id,
            &tier_start, assets::mint_test(fee_start));
        // Assert start tier.
        assert!(get_integrator_fee_store_tier_test<QC>(@user, market_id) ==
            tier_start, 0);
        // Upgrade to upgrade tier.
        upgrade_integrator_fee_store<QC, UC>(integrator, market_id,
            tier_upgrade, assets::mint_test(fee_upgrade - fee_start));
        // Assert fees assessed for cumulative amount required to
        // activate to upgrade tier.
        assert!(get_utility_coin_store_balance_test() == fee_upgrade, 0);
        // Assert upgrade tier.
        assert!(get_integrator_fee_store_tier_test<QC>(@user, market_id) ==
            tier_upgrade, 0);
    }

    #[test(integrator = @user)]
    #[expected_failure(abort_code = 15)]
    /// Verify expected failure for not an upgrade.
    fun test_upgrade_integrator_fee_store_not_upgrade(
        integrator: &signer
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters,
        IntegratorFeeStores,
        UtilityCoinStore
    {
        init_incentives_test(); // Init incentives.
        let (market_id, tier) = (0, 0); // Declare market ID, tier.
        // Register to given tier.
        register_integrator_fee_store<QC, UC>(integrator, &market_id, &tier,
            assets::mint_test(get_tier_activation_fee(&tier)));
        // Attempt invalid upgrade.
        upgrade_integrator_fee_store<QC, UC>(integrator, market_id, tier,
            coin::zero());
    }

    #[test]
    #[expected_failure(abort_code = 12)]
    /// Verify failure for wrong type.
    fun test_verify_utility_coin_type()
    acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters
    {
        init_incentives_test(); // Initialize incentives for testing.
        verify_utility_coin_type<QC>(); // Attempt invalid invocation.
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for account is not Econia.
    fun test_withdraw_econia_fees_all_not_econia(
        account: &signer
    ) acquires
        FeeAccountSignerCapabilityStore,
        EconiaFeeStore
    {
        // Attempt invalid invocation.
        let fees = withdraw_econia_fees_all<UC>(account, &0);
        assets::burn(fees); // Burn fees.
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for account is not Econia.
    fun test_withdraw_econia_fees_not_econia(
        account: &signer
    ) acquires
        FeeAccountSignerCapabilityStore,
        EconiaFeeStore
    {
        // Attempt invalid invocation.
        let fees = withdraw_econia_fees<UC>(account, &0, &0);
        assets::burn(fees); // Burn fees.
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for account is not Econia.
    fun test_withdraw_utility_coins_all_not_econia(
        account: &signer
    ): coin::Coin<UC>
    acquires
        FeeAccountSignerCapabilityStore,
        UtilityCoinStore
    {
        // Attempt invalid invocation.
        withdraw_utility_coins_all<UC>(account)
    }

    #[test(account = @user)]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for account is not Econia.
    fun test_withdraw_utility_coins_not_econia(
        account: &signer
    ): coin::Coin<UC>
    acquires
        FeeAccountSignerCapabilityStore,
        UtilityCoinStore
    {
        // Attempt invalid invocation.
        withdraw_utility_coins<UC>(account, 1234)
    }

    #[test(econia = @econia)]
    #[expected_failure(abort_code = 16)]
    /// Verify failure for attempting to update incentive parameters
    /// with fewer integrator fee store tiers than before.
    fun update_incentives_fewer_tiers(
        econia: &signer
    ) acquires
        FeeAccountSignerCapabilityStore,
        IncentiveParameters
    {
        assets::init_coin_types_test(); // Init coin types.
        // Declare incentive parameters.
        let market_registration_fee = 123;
        let custodian_registration_fee = 456;
        let taker_fee_divisor = 789;
        let fee_share_divisor_0 = 1234;
        let tier_activation_fee_0 = 2345;
        let withdrawal_fee_0 = 3456;
        let fee_share_divisor_1 = fee_share_divisor_0 - 1;
        let tier_activation_fee_1 = tier_activation_fee_0 + 1;
        let withdrawal_fee_1 = tier_activation_fee_0 - 1;
        // Vectorize fee store tier parameters.
        let tier_0 = vector::singleton(fee_share_divisor_0);
        vector::push_back(&mut tier_0, tier_activation_fee_0);
        vector::push_back(&mut tier_0, withdrawal_fee_0);
        let tier_1 = vector::singleton(fee_share_divisor_1);
        vector::push_back(&mut tier_1, tier_activation_fee_1);
        vector::push_back(&mut tier_1, withdrawal_fee_1);
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        vector::push_back(&mut integrator_fee_store_tiers, tier_1);
        // Initialize incentives.
        init_incentives<UC>(econia, &market_registration_fee,
            &custodian_registration_fee, &taker_fee_divisor,
            &integrator_fee_store_tiers);
        // Update fee store tiers vector to smaller length.
        integrator_fee_store_tiers = vector::singleton(tier_0);
        // Attempt invalid update to incentive parameter set.
        update_incentives<QC>(econia, market_registration_fee,
            custodian_registration_fee, taker_fee_divisor,
            integrator_fee_store_tiers);
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}