module aptos_faucet::test_coin {
    use aptos_std::coin::{
        Self,
        BurnCapability,
        FreezeCapability,
        MintCapability,
    };
    use aptos_std::string;
    use aptos_std::type_info;
    use std::signer::{address_of};

    struct CapStore<phantom CoinType> has key {
        burn_cap: BurnCapability<CoinType>,
        freeze_cap: FreezeCapability<CoinType>,
        mint_cap: MintCapability<CoinType>,
    }

    public entry fun initialize<CoinType>(
        account: &signer,
        name: string::String,
        symbol: string::String,
        decimals: u8,
        monitor_supply: bool,
    ) {
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<CoinType>(
            account,
            name,
            symbol,
            decimals,
            monitor_supply
        );
        move_to(account, CapStore<CoinType> {
            burn_cap,
            freeze_cap,
            mint_cap,
        });
    }

    public entry fun mint<CoinType>(
        account: &signer,
        amount: u64,
    ) acquires CapStore {
        let account_addr = address_of(account);
        if (!coin::is_account_registered<CoinType>(account_addr)) {
            coin::register<CoinType>(account)
        };
        let cap_store = borrow_global_mut<CapStore<CoinType>>(
            coin_address<CoinType>(),
        );
        coin::deposit(
            account_addr,
            coin::mint(amount, &cap_store.mint_cap),
        );
    }

    /// A helper function that returns the address of CoinType.
    fun coin_address<CoinType>(): address {
        let type_info = type_info::type_of<CoinType>();
        type_info::account_address(&type_info)
    }
}