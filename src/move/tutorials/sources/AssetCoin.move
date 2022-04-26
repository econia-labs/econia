/*
Adapted from official Move tutorial:
https://github.com/move-language/move/tree/main/language/documentation/tutorial
Follows steps 1 through 5, substituting `AssetCoin` for `Coin`
*/

module Ultima::AssetCoin {
    use Std::Errors;
    use Std::Signer;

    // Module owner address
    const MODULE_OWNER: address = @Ultima;

    // Error codes
    const E_NOT_MODULE_OWNER: u64 = 0;
    const E_INSUFFICIENT_BALANCE: u64 = 1;
    const E_ALREADY_HAS_BALANCE: u64 = 2;

    struct AssetCoin has store {
        value: u64
    }

    // Represents balance of each address
    struct Balance has key {
        asset_coin: AssetCoin
    }

    // Publish empty balance resource under `account`'s address
    // Must be called before minting/transferring to the account
    public fun publish_balance(account: &signer) {
        let empty_coin = AssetCoin { value: 0 };
        move_to(account, Balance { asset_coin: empty_coin });
    }

    // Initialize this module
    public fun mint(module_owner: &signer, mint_addr: address, amount: u64)
        acquires Balance {
        // Only the module owner can initialize the module
        assert!(
            Signer::address_of(module_owner) == MODULE_OWNER,
            Errors::requires_address(E_NOT_MODULE_OWNER)
        );
        // Deposit `amount` of tokens to `mint_addr`'s balance
        deposit(mint_addr, AssetCoin { value: amount });
    }

    // Return balance of `owner`
    public fun balance_of(owner: address): u64 acquires Balance {
        borrow_global<Balance>(owner).asset_coin.value
    }

    // Transfer `amount` of tokens from `from` to `to`
    public fun transfer(from: &signer, to: address, amount: u64) acquires
        Balance {
        let check = withdraw(Signer::address_of(from), amount);
        deposit(to, check)
    }

    // Withdraw `amount` of tokens from `addr`'s balance
    fun withdraw(addr: address, amount: u64) : AssetCoin acquires Balance {
        let balance = balance_of(addr);
        // Balance must exceed/equal withdraw amount
        assert!(
            balance >= amount,
            Errors::limit_exceeded(E_INSUFFICIENT_BALANCE)
        );
        let balance_ref =
            &mut borrow_global_mut<Balance>(addr).asset_coin.value;
        *balance_ref = balance - amount;
        AssetCoin { value: amount }
    }

    // Deposit `amount` of tokens to `addr`
    fun deposit(addr: address, check: AssetCoin) acquires Balance {
        let balance = balance_of(addr);
        let balance_ref =
            &mut borrow_global_mut<Balance>(addr).asset_coin.value;
        let AssetCoin { value } = check;
        *balance_ref = balance + value;
    }

    #[test(account = @0x1)] // Create signer for `account` argument
    #[expected_failure] // Test should abort
    fun mint_non_owner(account: signer) acquires Balance {
        // Make sure address isn't module owner address
        publish_balance(&account);
        assert!(Signer::address_of(&account) != MODULE_OWNER, 0);
        mint(&account, @0x1, 10);
    }

    #[test(account = @Ultima)] // Create signer for `account`
    fun mint_check_balance(account: signer) acquires Balance {
        let addr = Signer::address_of(&account);
        publish_balance(&account);
        mint(&account, @Ultima, 100);
        assert!(balance_of(addr) == 100, 0);
    }

    #[test(account = @0x1)]
    fun publish_balance_has_zero(account: signer) acquires Balance {
        let addr = Signer::address_of(&account);
        publish_balance(&account);
        assert!(balance_of(addr) == 0, 0);
    }

    #[test(account = @0x1)]
    #[expected_failure]
    fun publish_balance_already_exists(account: signer) {
        publish_balance(&account);
        publish_balance(&account);
    }

    #[test]
    #[expected_failure]
    fun balance_of_dne() acquires Balance {
        balance_of(@0x1);
    }

    #[test]
    #[expected_failure]
    fun withdraw_dne() acquires Balance {
        // Need to unpack since `AssetCoin` is a resource
        AssetCoin { value: _ } = withdraw(@0x1, 0);
    }

    #[test(account = @0x1)]
    #[expected_failure]
    fun withdraw_too_much(account: signer) acquires Balance {
        let addr = Signer::address_of(&account);
        publish_balance(&account);
        AssetCoin { value: _ } = withdraw(addr, 1);
    }

    #[test(account = @Ultima)]
    fun can_withdraw_amount(account: signer) acquires Balance {
        publish_balance(&account);
        let amount = 1000;
        let addr = Signer::address_of(&account);
        mint(&account, addr, amount);
        let AssetCoin { value } = withdraw(addr, amount);
        assert!(value == amount, 0);
    }

}