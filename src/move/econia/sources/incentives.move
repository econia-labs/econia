/// Incentive-associated parameters and data structures.
module econia::incentives {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::coin::{Self, Coin};
    use aptos_std::type_info;
    use econia::table_list::{TableList};
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
        utility_coin_type_info: type_info::TypeInfo,
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
        utility_coins: Coin<CoinType>
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

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Index of fee share in vectorized representation of an
    /// `IntegratorFeeStoreTierParameters`.
    const FEE_SHARE_DIVISOR_INDEX: u64 = 0;
    /// `u64` bitmask with all bits set
    const HI_64: u64 = 0xffffffffffffffff;
    /// Minimum possible divisor for avoiding divide-by-zero error.
    const MIN_DIVISOR: u64 = 1;
    /// Minimum possible flat fee, required to disincentivize excessive
    /// bogus transactions.
    const MIN_FEE: u64 = 1;
    /// Number of fields in an `IntegratorFeeStoreTierParameters`
    const N_TIER_FIELDS: u64 = 3;
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

    /// Return fee share divisor for tier indicated by `tier_ref`.
    public fun get_fee_share_divisor(
        tier_ref: &u64
    ): u64
    acquires IncentiveParameters {
        vector::borrow(&borrow_global<IncentiveParameters>(@econia).
            integrator_fee_store_tiers, *tier_ref).fee_share_divisor
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
        tier_ref: &u64
    ): u64
    acquires IncentiveParameters {
        vector::borrow(&borrow_global<IncentiveParameters>(@econia).
            integrator_fee_store_tiers, *tier_ref).tier_activation_fee
    }

    /// Return withdrawal fee for tier indicated by `tier_ref`.
    public fun get_withdrawal_fee(
        tier_ref: &u64
    ): u64
    acquires IncentiveParameters {
        vector::borrow(&borrow_global<IncentiveParameters>(@econia).
            integrator_fee_store_tiers, *tier_ref).withdrawal_fee
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

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public entry functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

    // Public entry functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public friend functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

    // Public friend functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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
    /// # Abort conditions
    /// * If `econia` does not indicate the Econia account.
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
    /// # Abort conditions
    /// * If `CoinType` does not correspond to an initialized
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
                utility_coins: coin::zero<CoinType>()});
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
        // Get fee account signer: if not updating previously-set
        // values, initialize a fee account, storing generated signer.
        let fee_account = if (!*updating_ref) init_fee_account(econia) else
            // Otherwise get fee account signer from stored capability.
            account::create_signer_with_capability(
                &borrow_global<FeeAccountSignerCapabilityStore>(@econia).
                    fee_account_signer_capability);
        // Initialize a utility coin store under the fee acount (aborts
        // if not an initialized coin type).
        init_utility_coin_store<UtilityCoinType>(&fee_account);
        if (!*updating_ref) { // If not updating previously-set values:
            // Initialize one with range-checked inputs and empty
            // tiers vector.
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
        if (*updating_ref) { // If updating previously-set values
            // Set utility coin type.
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
        // Parse in integrator fee store tiers (aborts for invalid
        // values).
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
    /// # Abort conditions
    /// * If an indicated inner vector from
    ///   `integrator_fee_store_tiers_ref` is the wrong length.
    /// * If fee share divisor does not decrease with tier number.
    /// * If a fee share divisor is less than taker fee divisor.
    /// * If tier activation fee does not increase with tier number.
    /// * If there is no tier activation fee for the first tier.
    /// * If withdrawal fee does not decrease with tier number.
    /// * If the withdrawal fee for a given tier does not meet minimum
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
    /// # Abort conditions
    /// * If `econia` is not Econia account.
    /// * If `market_registration_fee_ref` indicates fee that does not
    ///   meet minimum threshold.
    /// * If `custodian_registration_fee_ref` indicates fee that does
    ///   not meet minimum threshold.
    /// * If `taker_fee_divisor_ref` indicates divisor that does not
    ///   meet minimum threshold.
    /// * If `integrator_fee_store_tiers_ref` indicates an empty vector.
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
    const TIER_ACTIVATION_FEE_0: u64 = 150;
    #[test_only]
    const WITHDRAWAL_FEE_0: u64 = 10;

    // Test-only constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Initialize incentives using test-only constants.
    fun init_incentives_test()
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
        let integrator_fee_store_tiers = vector::singleton(tier_0);
        // Initialize incentives.
        init_incentives<UC>(&econia, &MARKET_REGISTRATION_FEE,
            &CUSTODIAN_REGISTRATION_FEE, &TAKER_FEE_DIVISOR,
            &integrator_fee_store_tiers);
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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
        // Assert state.
        verify_utility_coin_type<UC>();
        assert!(!is_utility_coin_type<QC>(), 0);
        assert!(get_market_registration_fee() == market_registration_fee, 0);
        assert!(get_custodian_registration_fee() ==
            custodian_registration_fee, 0);
        assert!(get_taker_fee_divisor() == taker_fee_divisor, 0);
        assert!(get_n_fee_store_tiers() == 2, 0);
        assert!(get_fee_share_divisor(&0) == fee_share_divisor_0, 0);
        assert!(get_tier_activation_fee(&0) == tier_activation_fee_0, 0);
        assert!(get_withdrawal_fee(&0) == withdrawal_fee_0, 0);
        assert!(get_fee_share_divisor(&1) == fee_share_divisor_1, 0);
        assert!(get_tier_activation_fee(&1) == tier_activation_fee_1, 0);
        assert!(get_withdrawal_fee(&1) == withdrawal_fee_1, 0);
        // Update incentive parameters, now with just 1 tier.
        market_registration_fee = market_registration_fee + 5;
        custodian_registration_fee = custodian_registration_fee + 5;
        taker_fee_divisor = taker_fee_divisor + 5;
        fee_share_divisor_0 = fee_share_divisor_0 + 5;
        tier_activation_fee_0 = tier_activation_fee_0 + 5;
        withdrawal_fee_0 = tier_activation_fee_0 + 5;
        // Vectorize fee store tier parameters.
        tier_0 = vector::singleton(fee_share_divisor_0);
        vector::push_back(&mut tier_0, tier_activation_fee_0);
        vector::push_back(&mut tier_0, withdrawal_fee_0);
        integrator_fee_store_tiers = vector::singleton(tier_0);
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
        assert!(get_n_fee_store_tiers() == 1, 0);
        assert!(get_fee_share_divisor(&0) == fee_share_divisor_0, 0);
        assert!(get_tier_activation_fee(&0) == tier_activation_fee_0, 0);
        assert!(get_withdrawal_fee(&0) == withdrawal_fee_0, 0);
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
    #[expected_failure(abort_code = 2)]
    /// Verify failure for empty fee store tiers
    fun test_set_incentive_parameters_range_check_inputs_empty_vector(
        econia: &signer
    ) {
        // Attempt invalid invocation.
        set_incentive_parameters_range_check_inputs(econia, &1, &1, &1,
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

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}