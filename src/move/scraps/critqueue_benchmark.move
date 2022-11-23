/// Wrappers for on-chain `CritQueue` benchmarking.
module econia::critqueue_benchmark {

    use aptos_std::table_with_length::{Self, TableWithLength};
    use econia::critqueue::{Self, CritQueue};
    use std::signer::address_of;

    /// When not called by Econia.
    const E_NOT_ECONIA: u64 = 0;
    /// When value is not as expected.
    const E_UNEXPECTED_VALUE: u64 = 1;

    /// Ascending crit-queue flag.
    const ASCENDING: bool = false;

    /// Stores a `CritQueue` in a table, so insertion counts can be
    /// reset.
    struct CritQueueStore has key {
        map: TableWithLength<u64, CritQueue<u64>>
    }

    /// Initialize a `CritQueueStore` under `econia` account.
    fun init_module(
        econia: &signer
    ) {
        let critqueue = critqueue::new(ASCENDING); // Get crit-queue.
        let map = table_with_length::new();  // Get store map.
        // Add crit-queue to map.
        table_with_length::add(&mut map, 1, critqueue);
        // Get crit-queue store.
        let critqueue_store = CritQueueStore{map};
        // Move crit-queue store to Econia account.
        move_to<CritQueueStore>(econia, critqueue_store);
    }

    /// Insert a key-value insertion pair.
    public entry fun insert(
        account: &signer,
        insertion_key: u64,
        insertion_value: u64
    ) acquires CritQueueStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow crit-queue store map.
        let critqueue_store_map_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).map;
        let reset_count = table_with_length::length(
            critqueue_store_map_ref_mut); // Get reset count.
        // Mutably borrow crit-queue.
        let critqueue_ref_mut = table_with_length::borrow_mut(
            critqueue_store_map_ref_mut, reset_count);
        // Insert key-value insertion pair.
        critqueue::insert(critqueue_ref_mut, insertion_key, insertion_value);
    }

    /// Remove insertion value corresponding to `access_key`,
    /// asserting it is equal to `insertion_value_expected`.
    public entry fun remove(
        account: &signer,
        access_key: u128,
        insertion_value_expected: u64
    ) acquires CritQueueStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow crit-queue store map.
        let critqueue_store_map_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).map;
        let reset_count = table_with_length::length(
            critqueue_store_map_ref_mut); // Get reset count.
        // Mutably borrow crit-queue.
        let critqueue_ref_mut = table_with_length::borrow_mut(
            critqueue_store_map_ref_mut, reset_count);
        assert!( // Assert removed insertion value is as expected.
            critqueue::remove(critqueue_ref_mut, access_key) ==
            insertion_value_expected, E_UNEXPECTED_VALUE);
    }

    /// Dequeue insertion value at crit-queue head, asserting it is
    /// equal to `insertion_value_expected`.
    public entry fun dequeue(
        account: &signer,
        insertion_value_expected: u64
    ) acquires CritQueueStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow crit-queue store map.
        let critqueue_store_map_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).map;
        let reset_count = table_with_length::length(
            critqueue_store_map_ref_mut); // Get reset count.
        // Mutably borrow crit-queue.
        let critqueue_ref_mut = table_with_length::borrow_mut(
            critqueue_store_map_ref_mut, reset_count);
        assert!( // Assert dequeued insertion value is as expected.
            critqueue::dequeue(critqueue_ref_mut) ==
            insertion_value_expected, E_UNEXPECTED_VALUE);
    }

    /// Dequeue all values in given crit-queue.
    public entry fun dequeue_all(
        account: &signer,
    ) acquires CritQueueStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow crit-queue store map.
        let critqueue_store_map_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).map;
        let reset_count = table_with_length::length(
            critqueue_store_map_ref_mut); // Get reset count.
        // Mutably borrow crit-queue.
        let critqueue_ref_mut = table_with_length::borrow_mut(
            critqueue_store_map_ref_mut, reset_count);
        // While crit-queue is not empty:
        while (!critqueue::is_empty(critqueue_ref_mut)) {
            // De-queue the head.
            critqueue::dequeue(critqueue_ref_mut);
        };
    }

    /// Reset with a new crit-queue.
    public entry fun reset(
        account: &signer,
    ) acquires CritQueueStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow crit-queue store map.
        let critqueue_store_map_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).map;
        let reset_count = table_with_length::length(
            critqueue_store_map_ref_mut); // Get reset count.
        // Get crit-queue.
        let critqueue = critqueue::new<u64>(ASCENDING);
        // Add new crit-queue to store map.
        table_with_length::add(
            critqueue_store_map_ref_mut, reset_count + 1, critqueue);
    }

}