module econia::registry {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_framework::account;
    use aptos_framework::event::EventHandle;
    use econia::tablist::{Self, Tablist};
    use std::option::Option;
    use std::string::String;

    use econia::incentives;
    fun use_friend() {incentives::calculate_max_quote_match(false, 0, 0);}

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Custodian capability required to approve order placement, order
    /// cancellation, and coin withdrawals. Administered to third-party
    /// registrants who may store it as they wish.
    struct CustodianCapability has store {
        /// Serial ID, 1-indexed, generated upon registration as a
        /// custodian.
        custodian_id: u64
    }

    /// Emitted when a capability is registered.
    struct CapabilityRegistrationEvent has drop, store {
        /// Either `CUSTODIAN` or `UNDERWRITER`, the capability type
        /// just registered.
        capability_type: bool,
        /// ID of capability just registered.
        capability_id: u64
    }

    /// Type flag for generic asset. Must be passed as base asset type
    /// argument for generic market operations.
    struct GenericAsset has key {}

    /// Information about a market.
    struct MarketInfo has copy, drop, store {
        /// Base asset type name. When base asset is an
        /// `aptos_framework::coin::Coin`, corresponds to the phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`), and
        /// `underwriter_id` is none. Otherwise can be any value, and
        /// `underwriter` is some.
        base_type: String,
        /// Quote asset coin type name. Corresponds to a phantom
        /// `CoinType` (`address:module::MyCoin` rather than
        /// `aptos_framework::coin::Coin<address:module::MyCoin>`).
        quote_type: String,
        /// Number of base units exchanged per lot (when base asset is
        /// a coin, corresponds to `aptos_framework::coin::Coin.value`).
        lot_size: u64,
        /// Number of quote coin units exchanged per tick (corresponds
        /// to `aptos_framework::coin::Coin.value`).
        tick_size: u64,
        /// ID of underwriter capability required to verify generic
        /// asset amounts. A market-wide ID that only applies to markets
        /// having a generic base asset. None when base and quote types
        /// are both coins.
        underwriter_id: Option<u64>
    }

    /// Emitted when a market is registered.
    struct MarketRegistrationEvent has drop, store {
        /// Market ID of the market just registered.
        market_id: u64,
        /// Base asset type name.
        base_type: String,
        /// Quote asset type name.
        quote_type: String,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// ID of `UnderwriterCapability` required to verify generic
        /// asset amounts. None when base and quote types are both
        /// coins.
        underwriter_id: Option<u64>,
    }

    /// Emitted when a recognized market is added, removed, or updated.
    struct RecognizedMarketEvent has drop, store {
        /// The associated trading pair.
        trading_pair: TradingPair,
        /// The recognized market info for the given trading pair after
        /// an addition or update. None if a removal.
        recognized_market_info: Option<RecognizedMarketInfo>,
    }

    /// Recognized market info for a given trading pair.
    struct RecognizedMarketInfo has drop, store {
        /// Market ID of recognized market.
        market_id: u64,
        /// Number of base units exchanged per lot.
        lot_size: u64,
        /// Number of quote units exchanged per tick.
        tick_size: u64,
        /// ID of underwriter capability required to verify generic
        /// asset amounts. A market-wide ID that only applies to
        /// markets having a generic base asset. None when base and
        /// quote types are both coins.
        underwriter_id: Option<u64>,
    }

    /// Recognized markets for specific trading pairs.
    struct RecognizedMarkets has key {
        /// Map from trading pair info to market information for the
        /// recognized market, if any, for given trading pair.
        map: Tablist<TradingPair, RecognizedMarketInfo>,
        /// Event handle for recognized market events.
        recognized_market_event: EventHandle<RecognizedMarketEvent>
    }

    /// Global registration information.
    struct Registry has key {
        /// Map from market info to corresponding market ID, enabling
        /// duplicate checks and iterated indexing.
        markets: Tablist<MarketInfo, u64>,
        /// The number of registered custodians.
        n_custodians: u64,
        /// The number of registered underwriters.
        n_underwriters: u64,
        /// Event handle for market registration events.
        market_registration_events: EventHandle<MarketRegistrationEvent>,
        /// Event handle for capability registration events.
        capability_registration_events:
            EventHandle<CapabilityRegistrationEvent>
    }

    /// A combination of a base asset and a quote asset.
    struct TradingPair has copy, drop, store {
        /// Base type name.
        base_type: String,
        /// Quote type name.
        quote_type: String
    }

    /// Underwriter capability required to verify generic asset
    /// amounts. Administered to third-party registrants who may store
    /// it as they wish.
    struct UnderwriterCapability has store {
        /// Serial ID, 1-indexed, generated upon registration as an
        /// underwriter.
        custodian_id: u64
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Flag for custodian capability.
    const CUSTODIAN: bool = true;
    /// Flag for underwriter capability.
    const UNDERWRITER: bool = false;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Initialize the Econia registry upon module publication.
    fun init_module(
        econia: &signer
    ) {
        move_to(econia, Registry{
            markets: tablist::new(),
            n_custodians: 0,
            n_underwriters: 0,
            market_registration_events:
                account::new_event_handle<MarketRegistrationEvent>(econia),
            capability_registration_events:
                account::new_event_handle<CapabilityRegistrationEvent>(econia)
        });
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Initialize registry for testing.
    public fun init_test() {
        // Get signer for Econia account.
        let econia = account::create_signer_with_capability(
            &account::create_test_signer_cap(@econia));
        init_module(&econia); // Init registry.
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}