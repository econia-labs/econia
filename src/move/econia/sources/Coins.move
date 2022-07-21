// Test coin types for on-chain testing, adapted from `Econia::Registry`

module Econia::Coins {

    use aptos_framework::coin::{
        BurnCapability,
        deposit,
        initialize,
        MintCapability,
        mint
    };

    use std::string::{
        utf8
    };

    use std::signer::{
        address_of
    };

    /// Base coin type
    struct BCT{}

    /// Base coin capabilities
    struct BCC has key {
        /// Mint capability
        m: MintCapability<BCT>,
        /// Burn capability
        b: BurnCapability<BCT>
    }

    /// Quote coin type
    struct QCT{}

    /// Quote coin capabilities
    struct QCC has key {
        /// Mint capability
        m: MintCapability<QCT>,
        /// Burn capability
        b: BurnCapability<QCT>
    }

    /// Base coin type coin name
    const BCT_CN: vector<u8> = b"Base";
    /// Base coin type coin symbol
    const BCT_CS: vector<u8> = b"B";
    /// Base coin type decimal
    const BCT_D: u64 = 4;
    /// Base coin type type name
    const BCT_TN: vector<u8> = b"BCT";
    /// Quote coin type coin name
    const QCT_CN: vector<u8> = b"Quote";
    /// Quote coin type coin symbol
    const QCT_CS: vector<u8> = b"Q";
    /// Base coin type decimal
    const QCT_D: u64 = 8;
    /// Quote coin type type name
    const QCT_TN: vector<u8> = b"QCT";

    /// When access-controlled function called by non-Econia account
    const E_NOT_ECONIA: u64 = 0;

    /// Initialize base and quote coin types under Econia account
    public entry fun init_coin_types(
        econia: &signer
    ) {
        // Assert initializing coin types under Econia account
        assert!(address_of(econia) == @Econia, E_NOT_ECONIA);
        // Initialize base coin type, storing mint/burn capabilities
        let(m, b) = initialize<BCT>(
            econia, utf8(BCT_CN), utf8(BCT_CS), BCT_D, false);
        // Save capabilities in global storage
        move_to(econia, BCC{m, b});
        // Initialize quote coin type, storing mint/burn capabilities
        let(m, b) = initialize<QCT>(
            econia, utf8(QCT_CN), utf8(QCT_CS), QCT_D, false);
        // Save capabilities in global storage
        move_to(econia, QCC{m, b});
    }

    /// Mint `val_bct` of `BCT` and `val_qct` of `QCT` to `user`'s
    /// `aptos_framework::Coin::Coinstore`
    public entry fun mint_to(
        econia: &signer,
        user: address,
        val_bct: u64,
        val_qct: u64
    ) acquires BCC, QCC {
        // Assert called by Econia account
        assert!(address_of(econia) == @Econia, E_NOT_ECONIA);
        // Mint and deposit to user
        deposit<BCT>(user, mint<BCT>(val_bct, &borrow_global<BCC>(@Econia).m));
        // Mint and deposit to user
        deposit<QCT>(user, mint<QCT>(val_qct, &borrow_global<QCC>(@Econia).m));
    }
}