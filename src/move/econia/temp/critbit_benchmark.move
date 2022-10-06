/// Wrappers for on-chain `CritBitTree` benchmarking.
module econia::critbit_benchmark {

    use aptos_std::table_with_length::{Self, TableWithLength};
    use econia::critbit::{Self, CritBitTree};
    use std::signer::address_of;

    /// When not called by Econia.
    const E_NOT_ECONIA: u64 = 0;

    /// Stores a `CritBitTree` in a table, so it can be effectively
    /// emptied and reset.
    struct TreeStore has key {
        map: TableWithLength<u64, CritBitTree<address>>
    }

    /// Initialize a `TreeStore` under `econia` account.
    fun init_module(
        econia: &signer
    ) {
        let tree = critbit::empty(); // Get tree
        let map = table_with_length::new();  // Get store map.
        // Add tree to map.
        table_with_length::add(&mut map, 1, tree);
        // Get tree store
        let tree_store = TreeStore{map};
        // Move tree store to Econia account.
        move_to<TreeStore>(econia, tree_store);
    }

    /// Immutably borrow from the tree.
    public entry fun borrow(
        account: &signer,
        key: u128
    ) acquires TreeStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Immutably borrow tree store map.
        let tree_store_map_ref = &borrow_global<TreeStore>(@econia).map;
        let reset_count = table_with_length::length(
            tree_store_map_ref); // Get reset count.
        // Immutably borrow corresponding tree.
        let tree_ref = table_with_length::borrow(
            tree_store_map_ref, reset_count);
        // Borrow address corresponding to given key.
        let address_ref = critbit::borrow(tree_ref, key);
        // Assert address is Econia.
        assert!(*address_ref == @econia, E_NOT_ECONIA);
    }

    /// Insert the given key.
    public entry fun insert(
        account: &signer,
        key: u128
    ) acquires TreeStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow tree store map.
        let tree_store_map_ref_mut =
            &mut borrow_global_mut<TreeStore>(@econia).map;
        let reset_count = table_with_length::length(
            tree_store_map_ref_mut); // Get reset count.
        // Mutably borrow corresponding tree.
        let tree_ref_mut = table_with_length::borrow_mut(
            tree_store_map_ref_mut, reset_count);
        // Insert key and bogus address.
        critbit::insert(tree_ref_mut, key, @econia);
    }

    /// Pop key and discard value.
    public entry fun pop(
        account: &signer,
        key: u128
    ) acquires TreeStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow tree store map.
        let tree_store_map_ref_mut =
            &mut borrow_global_mut<TreeStore>(@econia).map;
        let reset_count = table_with_length::length(
            tree_store_map_ref_mut); // Get reset count.
        // Mutably borrow corresponding tree.
        let tree_ref_mut = table_with_length::borrow_mut(
            tree_store_map_ref_mut, reset_count);
        // Remove key and discard value.
        critbit::pop(tree_ref_mut, key);
    }

    /// Pop both keys and discard values.
    public entry fun pop_twice(
        account: &signer,
        key_1: u128,
        key_2: u128,
    ) acquires TreeStore {
        pop(account, key_1);
        pop(account, key_2);
    }

    /// Reset with a new tree.
    public entry fun reset(
        account: &signer
    ) acquires TreeStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow tree store map.
        let tree_store_map_ref_mut =
            &mut borrow_global_mut<TreeStore>(@econia).map;
        let reset_count = table_with_length::length(
            tree_store_map_ref_mut); // Get reset count.
        let tree = critbit::empty(); // Get new tree.
        // Add new tree to store map.
        table_with_length::add(tree_store_map_ref_mut, reset_count + 1, tree);
    }

    /// Clear tree out.
    public entry fun clear(
        account: &signer
    ) acquires TreeStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow tree store map.
        let tree_store_map_ref_mut =
            &mut borrow_global_mut<TreeStore>(@econia).map;
        let reset_count = table_with_length::length(
            tree_store_map_ref_mut); // Get reset count.
        // Mutably borrow corresponding tree.
        let tree_ref_mut = table_with_length::borrow_mut(
            tree_store_map_ref_mut, reset_count);
        // While tree is not empty:
        while (!critbit::is_empty(tree_ref_mut)) {
            // Get max key.
            let max_key = critbit::max_key(tree_ref_mut);
            // Pop it.
            critbit::pop(tree_ref_mut, max_key);
        };
    }

}