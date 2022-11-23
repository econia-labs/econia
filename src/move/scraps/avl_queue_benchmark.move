/// Wrappers for on-chain `AVLqueue` benchmarking.
module econia::avl_queue_benchmark {

    use aptos_std::table_with_length::{Self, TableWithLength};
    use econia::avl_queue::{Self, AVLqueue};
    use std::signer::address_of;

    /// Mock insertion value type.
    struct Value has store {
        addr: address,
        bits: u128
    }

    /// Ascending AVL queue flag.
    const ASCENDING: bool = true;

    /// Stores an AVL queue in a table, so it can be effectively
    /// emptied and reset.
    struct AVLqueueStore has key {
        map: TableWithLength<u64, AVLqueue<Value>>
    }

    /// Initialize an AVL queue under the Econia account.
    fun init_module(
        econia: &signer
    ) {
        // Init AVL queue.
        let avlq = avl_queue::new(ASCENDING, 0, 0);
        let map = table_with_length::new();  // Get store map.
        // Add AVL queue to map.
        table_with_length::add(&mut map, 1, avlq);
        // Get AVL queue store.
        let avlq_store = AVLqueueStore{map};
        // Move store to Econia account.
        move_to<AVLqueueStore>(econia, avlq_store);
    }

    /// Immutably borrow from the AVL queue and assert value.
    public entry fun borrow(
        account: &signer,
        access_key: u64,
        expected_bits: u128
    ) acquires AVLqueueStore {
        let addr = address_of(account); // Get account address.
        // Immutably borrow AVL queue store map.
        let avlq_store_map_ref = &borrow_global<AVLqueueStore>(addr).map;
        let reset_count = // Get reset count.
            table_with_length::length(avlq_store_map_ref);
        let avlq_ref = // Immutably borrow corresponding AVL queue.
            table_with_length::borrow(avlq_store_map_ref, reset_count);
        // Borrow address corresponding to given key.
        let value_ref = avl_queue::borrow(avlq_ref, access_key);
        // Assert expected bits.
        assert!(value_ref.bits == expected_bits, 0);
    }

    /// Insert given key-value pair, assert expected access key.
    public entry fun insert(
        account: &signer,
        key: u64,
        bits: u128,
        access_key_expected: u64
    ) acquires AVLqueueStore {
        let addr = address_of(account); // Get account address.
        // Mutably borrow AVL queue store map.
        let avlq_store_map_ref_mut =
            &mut borrow_global_mut<AVLqueueStore>(addr).map;
        let reset_count = // Get reset count.
            table_with_length::length(avlq_store_map_ref_mut);
        let avlq_ref_mut = // Mutably borrow corresponding AVL queue.
            table_with_length::borrow_mut(avlq_store_map_ref_mut, reset_count);
        let access_key = avl_queue::insert(avlq_ref_mut, key, Value{
            addr, bits}); // Insert key-value pair, storing access key.
        // Assert access key is as expected.
        assert!(access_key == access_key_expected, 0);
    }

    /// Insert given key-value pair, assert expected access key, evictee
    /// access key, and evictee value bits.
    public entry fun insert_evict_tail(
        account: &signer,
        key: u64,
        bits: u128,
        access_key_expected: u64,
        evictee_access_key_expected: u64,
        evictee_value_bits_expected: u128
    ) acquires AVLqueueStore {
        let addr = address_of(account); // Get account address.
        // Mutably borrow AVL queue store map.
        let avlq_store_map_ref_mut =
            &mut borrow_global_mut<AVLqueueStore>(addr).map;
        let reset_count = // Get reset count.
            table_with_length::length(avlq_store_map_ref_mut);
        let avlq_ref_mut = // Mutably borrow corresponding AVL queue.
            table_with_length::borrow_mut(avlq_store_map_ref_mut, reset_count);
        let value = Value{addr, bits}; // Declare insertion value.
        // Insert key-value pair and evict tail, storing returns.
        let (access_key, evictee_access_key, Value{addr: _, bits}) =
            avl_queue::insert_evict_tail(avlq_ref_mut, key, value);
        // Assert returns
        assert!(access_key == access_key_expected, 0);
        assert!(evictee_access_key == evictee_access_key_expected, 0);
        assert!(bits == evictee_value_bits_expected, 0);
    }

    /// Remove given key-value pair, assert expected value bits.
    public entry fun remove(
        account: &signer,
        access_key: u64,
        bits_expected: u128
    ) acquires AVLqueueStore {
        let addr = address_of(account); // Get account address.
        // Mutably borrow AVL queue store map.
        let avlq_store_map_ref_mut =
            &mut borrow_global_mut<AVLqueueStore>(addr).map;
        let reset_count = // Get reset count.
            table_with_length::length(avlq_store_map_ref_mut);
        let avlq_ref_mut = // Mutably borrow corresponding AVL queue.
            table_with_length::borrow_mut(avlq_store_map_ref_mut, reset_count);
        // Remove key-value pair, storing value bits.
        let Value{addr: _, bits} = avl_queue::remove(avlq_ref_mut, access_key);
        // Assert value bits as expected.
        assert!(bits == bits_expected, 0);
    }

    /// Clear AVL queue out.
    public entry fun clear(
        account: &signer
    ) acquires AVLqueueStore {
        let addr = address_of(account); // Get account address.
        // Mutably borrow AVL queue store map.
        let avlq_store_map_ref_mut =
            &mut borrow_global_mut<AVLqueueStore>(addr).map;
        let reset_count = // Get reset count.
            table_with_length::length(avlq_store_map_ref_mut);
        let avlq_ref_mut = // Mutably borrow corresponding AVL queue.
            table_with_length::borrow_mut(avlq_store_map_ref_mut, reset_count);
        // While AVL queue is not empty:
        while (!avl_queue::is_empty(avlq_ref_mut)) {
            // Pop head, unpack and discard value.
            let Value{addr: _, bits: _} = avl_queue::pop_head(avlq_ref_mut);
        };
    }

    /// Reset with a new AVL queue.
    public entry fun reset(
        account: &signer,
        n_inactive_tree_nodes: u64,
        n_inactive_list_nodes: u64
    ) acquires AVLqueueStore {
        let addr = address_of(account); // Get account address.
        // Mutably borrow AVL queue store map.
        let avlq_store_map_ref_mut =
            &mut borrow_global_mut<AVLqueueStore>(addr).map;
        let reset_count = // Get reset count.
            table_with_length::length(avlq_store_map_ref_mut);
        table_with_length::add( // Add new AVL queue to store map.
            avlq_store_map_ref_mut, reset_count + 1, avl_queue::new(
                ASCENDING, n_inactive_tree_nodes, n_inactive_list_nodes));
    }

}
