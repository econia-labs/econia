module Econia::Market {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use AptosFramework::Coin::{
        Coin as C,
    };

    use AptosFramework::Table::{
        Table as T
    };

    use AptosFramework::TypeInfo::{
        TypeInfo as TI
    };

    use Econia::CritBit::{
        CB
    };

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use AptosFramework::Coin::{
        BurnCapability as CBC,
        initialize as c_i,
        MintCapability as CMC
    };

    #[test_only]
    use AptosFramework::TypeInfo::{
        account_address as ti_a_a,
        module_name as ti_m_n,
        struct_name as ti_s_n,
        type_of as ti_t_o
    };

    #[test_only]
    use Std::ASCII::{
        string as a_s
    };

    #[test_only]
    use Std::Signer::{
        address_of as s_a_o
    };

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // # Scale types
    struct S0{}
    struct S1{}
    struct S2{}
    struct S3{}
    struct S4{}
    struct S5{}
    struct S6{}
    struct S7{}
    struct S8{}
    struct S9{}
    struct S10{}
    struct S11{}
    struct S12{}
    struct S13{}
    struct S14{}
    struct S15{}
    struct S16{}
    struct S17{}
    struct S18{}
    struct S19{}

    /// Market container
    struct MC<phantom B, phantom Q, phantom S> has key {
        /// Order book
        ob: OB<B, Q, S>
    }

    /// Market info
    struct MI has copy, drop {
        /// Base CoinType TypeInfo
        b: TI,
        /// Quote CoinType TypeInfo
        q: TI,
        /// Scale
        s: u8
    }

    /// Market registry
    struct MR has key {
        /// Table from `MI` to address hosting the corresponding `MC`
        t: T<MI, address>
    }

    /// Order book
    struct OB<phantom B, phantom Q, phantom S> has store {
        /// Asks
        a: CB<P>,
        /// Bids
        b: CB<P>,
        /// Scale
        s: u8
    }

    /// Open orders on a user's account
    struct OO<phantom B, phantom Q, phantom S> has key {
        /// Asks
        a: CB<u64>,
        /// Bids
        b: CB<u64>,
        /// Base coins
        b_c: C<B>,
        /// Base coins available to withdraw
        b_a: u64,
        /// Quote coins
        q_c: C<Q>,
        /// Quote coins available to withdraw
        q_a: u64,
    }

    /// Position in an order book
    struct P has store {
        /// Size of position, in base coin subunits. Corresponds to
        /// `AptosFramework::Coin::Coin.value`
        s: u64,
        /// Address
        a: address
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Base coin type
    struct BCT{}

    #[test_only]
    /// Base coin capabilities
    struct BCC has key {
        /// Mint capability
        m: CMC<BCT>,
        /// Burn capability
        b: CBC<BCT>
    }

    #[test_only]
    /// Quote coin type
    struct QCT{}

    #[test_only]
    /// Quote coin capabilities
    struct QCC has key {
        /// Mint capability
        m: CMC<QCT>,
        /// Burn capability
        b: CBC<QCT>
    }

    // Test-only structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    #[test_only]
    /// Initialize base and quote coin types under Econia account
    fun init_coin_types(
        econia: &signer
    ) {
        // Assert initializing coin types under Econia account
        assert!(s_a_o(econia) == @Econia, 0);
        // Initialize base coin type, storing mint/burn capabilities
        let(m, b) = c_i<BCT>(econia, a_s(b"Base"), a_s(b"BC"), 4, false);
        // Save capabilities in global storage
        move_to(econia, BCC{m, b});
        // Initialize quote coin type, storing mint/burn capabilities
        let(m, b) = c_i<QCT>(econia, a_s(b"Quote"), a_s(b"Q"), 8, false);
        // Save capabilities in global storage
        move_to(econia, QCC{m, b});
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Pack market info and verify fields
    fun pack_market_info() {
        // Pack market info for test coin types
        let m_i = MI{b: ti_t_o<BCT>(), q: ti_t_o<QCT>(), s: 2};
        // Assert address, module, struct name for both coin types
        assert!(ti_a_a(&m_i.b) == @Econia   && ti_a_a(&m_i.q) == @Econia  , 0);
        assert!(ti_m_n(&m_i.b) == b"Market" && ti_m_n(&m_i.q) == b"Market", 1);
        assert!(ti_s_n(&m_i.b) == b"BCT"    && ti_s_n(&m_i.q) == b"QCT"   , 2);
        assert!(m_i.s == 2, 3); // Assert scale stored correctly
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}