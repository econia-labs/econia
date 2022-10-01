/// Wrappers for on-chain `CritQueue` benchmarking.
module econia::critqueue_benchmark {

    use econia::critqueue::{Self, CritQueue};
    use std::signer::address_of;

    /// When not called by Econia.
    const E_NOT_ECONIA: u64 = 0;
    /// When value is not as expected.
    const E_UNEXPECTED_VALUE: u64 = 1;

    /// Ascending crit-queue flag.
    const ASCENDING: bool = false;

    /// Stores a `CritQueue`.
    struct CritQueueStore has key {
        critqueue: CritQueue<u64>
    }

    /// Initialize a `CritQueueStore` under `econia` account.
    fun init_module(
        econia: &signer
    ) {
        // Get crit-queue.
        let critqueue = critqueue::new(ASCENDING);
        // Get crit-queue store.
        let critqueue_store = CritQueueStore{critqueue};
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
        // Mutably borrow crit-queue.
        let critqueue_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).critqueue;
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
        // Mutably borrow crit-queue.
        let critqueue_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).critqueue;
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
        // Mutably borrow crit-queue.
        let critqueue_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).critqueue;
        assert!( // Assert dequeued insertion value is as expected.
            critqueue::dequeue(critqueue_ref_mut) ==
            insertion_value_expected, E_UNEXPECTED_VALUE);
    }

    /// Dequeue all values in given crit-queue.
    public entry fun empty(
        account: &signer,
    ) acquires CritQueueStore {
        // Assert caller is Econia.
        assert!(address_of(account) == @econia, E_NOT_ECONIA);
        // Mutably borrow crit-queue.
        let critqueue_ref_mut =
            &mut borrow_global_mut<CritQueueStore>(@econia).critqueue;
        // While crit-queue is not empty:
        while (!critqueue::is_empty(critqueue_ref_mut)) {
            // De-queue the head.
            critqueue::dequeue(critqueue_ref_mut);
        };
    }

}