/*
Adapted from official Move tutorial:
https://github.com/move-language/move/tree/main/language/documentation/tutorial
From step 6 onward

Implements odd coin, which only allows odd number of coins to be
transferred each time
*/
module Ultima::OddCoin {
    use Std::Signer;
    use Ultima::BasicCoin;

    struct OddCoin has drop {}

    const E_NOT_ODD: u64 = 0;

    public fun setup_and_mint(
        account: &signer,
        amount: u64
    ) {
        BasicCoin::publish_balance<OddCoin>(account);
        BasicCoin::mint<OddCoin>(
            Signer::address_of(account),
            amount,
            OddCoin {}
        );
    }

    public fun transfer(
        from: &signer,
        to: address,
        amount: u64
    ) {
        assert!(amount % 2 == 1, E_NOT_ODD);
        BasicCoin::transfer<OddCoin>(from, to, amount, OddCoin {});
    }

    #[test(from = @0xCAFE, to = @0xF00)]
    fun test_odd_success(
        from: signer,
        to: signer
    ) {
        setup_and_mint(&from, 42);
        setup_and_mint(&to, 10);

        // Transfer an odd number of coins, which should succeed
        transfer(&from, @0xF00, 7);

        assert!(BasicCoin::balance_of<OddCoin>(@0xCAFE) == 35, 0);
        assert!(BasicCoin::balance_of<OddCoin>(@0xF00) == 17, 0);
    }

    #[test(from = @0xCAFE, to = @0xF00)]
    #[expected_failure]
    fun test_not_odd_failure(
        from: signer,
        to: signer
    ) {
        setup_and_mint(&from, 42);
        setup_and_mint(&to, 10);

        // Transfer an even number of coins, which should fail
        transfer(&from, @0xF00, 8)
    }
}