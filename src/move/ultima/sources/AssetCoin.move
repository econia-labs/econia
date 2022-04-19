module AssetCoin::AssetCoin {

    #[test_only]
    use Std::Signer;

    struct AssetCoin has key {
        value: u64,
    }

    public fun mint(account: signer, value: u64) {
        move_to(&account, AssetCoin { value } )
    }

    // Mint 10 to an account, then verify that they are there
    #[test(account = @0xC0FFEE)]
    fun test_mint_10(account: signer) acquires AssetCoin {
        let addr = Signer::address_of(&account);
        mint(account, 10);
        assert!(borrow_global<AssetCoin>(addr).value == 10, 0);
    }
}