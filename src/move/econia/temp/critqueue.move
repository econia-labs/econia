module econia::critqueue {

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ascending crit-queue flag.
    const ASCENDING: bool = false;
    /// Crit-queue direction bit flag indicating `ASCENDING`.
    const ASCENDING_BIT_FLAG: u128 = 0;
    /// Descending crit-queue flag.
    const DESCENDING: bool = true;
    /// Crit-queue direction bit flag indicating `DESCENDING`.
    const DESCENDING_BIT_FLAG: u128 = 1;
    /// Bit number of crit-queue direction bit flag.
    const DIRECTION: u8 = 62;
    /// Number of bits to shift when encoding enqueue key in leaf key.
    const ENQUEUE_KEY: u8 = 64;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// Maximum number of times a given enqueue key can be enqueued.
    /// A `u64` bitmask with all bits set except 62 and 63, generated
    /// in Python via `hex(int('1' * 62, 2))`.
    const MAX_ENQUEUE_COUNT: u64 = 0x3fffffffffffffff;
    /// `u128` bitmask set at bit 63, the node type bit flag, generated
    /// in Python via `hex(int('1' + '0' * 63, 2))`.
    const NODE_TYPE: u128 = 0x8000000000000000;
    /// Result of bitwise `AND` with `NODE_TYPE` for `Inner` node.
    const NODE_INNER: u128 = 0x8000000000000000;
    /// Result of bitwise `AND` with `NODE_TYPE` for `Leaf` node.
    const NODE_LEAF: u128 = 0;
    /// `XOR` bitmask for flipping all 62 enqueue count bits and setting
    /// bit 63 high in the case of a descending crit-queue. `u64`
    /// bitmask with all bits set except bit 63, generated in Python via
    /// `hex(int('1' * 63, 2))`.
    const NOT_ENQUEUE_COUNT_DESCENDING: u64 = 0x7fffffffffffffff;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // To implement >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Dequeue head and borrow next element in the queue, the new head.
    ///
    /// Should only be called after `dequeue_init()` indicates that
    /// iteration can proceed, or if a subsequent call to `dequeue()`
    /// indicates the same.
    ///
    /// # Parameters
    /// * `crit_queue_ref_mut`: Mutable reference to `CritQueue`.
    ///
    /// # Returns
    /// * `u128`: New queue head leaf key.
    /// * `&mut V`: Mutable reference to new queue head enqueue value.
    /// * `bool`: `true` if the new queue head `Leaf` has a parent, and
    ///   thus if iteration can proceed.
    ///
    /// # Aborts if
    /// * Indicated `CritQueue` is empty.
    /// * Indicated `CritQueue` is a singleton, e.g. if there are no
    ///   elements to proceed to after dequeueing.
    public fun dequeue<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>
    )//: (
        //u128,
        //&mut V,
        //bool
    /*)*/ {
        // Can ensure that there is a queue head by attempting to borrow
        // the corresponding leaf key from the option field, which
        // aborts if it is none.
    }

    /// Mutably borrow the head of the queue before dequeueing.
    ///
    /// # Parameters
    /// * `crit_queue_ref_mut`: Mutable reference to `CritQueue`.
    ///
    /// # Returns
    /// * `u128`: Queue head leaf key.
    /// * `&mut V`: Mutable reference to queue head enqueue value.
    /// * `bool`: `true` if the queue `Leaf` has a parent, and thus if
    ///   there is another element to iterate to. If `false`, can still
    ///   remove the head via `remove()`.
    ///
    /// # Aborts if
    /// * Indicated `CritQueue` is empty.
    public fun dequeue_init<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>
    )//: (
        //u128,
        //&mut V,
        //bool
    /*)*/ {
        // Can ensure that there is a queue head by attempting to borrow
        // corresponding leaf key from `CritQueue.head`, which aborts
        // if none.
    }

    /// Enqueue key-value pair, returning generated leaf key.
    public fun enqueue<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
        _enqueue_key: u64,
        //_enqueue_value: V,
    )/*: u128*/ {}

    /// Remove corresponding leaf, return enqueue value.
    public fun remove<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
        _leaf_key: u128
    )/*: V*/ {}

    // To implement <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Borrow enqueue value corresponding to given `leaf_key` for given
    /// `CritQueue`.
    public fun borrow<V>(
        crit_queue_ref: &CritQueue<V>,
        leaf_key: u128
    ): &V {
        &table::borrow(&crit_queue_ref.leaves, leaf_key).value
    }

    /// Mutably borrow enqueue value corresponding to given `leaf_key`
    /// for given `CritQueue`.
    public fun borrow_mut<V>(
        crit_queue_ref_mut: &mut CritQueue<V>,
        leaf_key: u128
    ): &mut V {
        &mut table::borrow_mut(&mut crit_queue_ref_mut.leaves, leaf_key).value
    }

    /// Return head leaf key of given `CritQueue`, if any.
    public fun get_head_leaf_key<V>(
        crit_queue_ref: &CritQueue<V>,
    ): Option<u128> {
        crit_queue_ref.head
    }

    /// Return `true` if given `CritQueue` has the given `leaf_key`.
    public fun has_leaf_key<V>(
        crit_queue_ref: &CritQueue<V>,
        leaf_key: u128
    ): bool {
        table::contains(&crit_queue_ref.leaves, leaf_key)
    }

    /// Return `true` if given `CritQueue` is empty.
    public fun is_empty<V>(
        crit_queue_ref: &CritQueue<V>,
    ): bool {
        option::is_none(&crit_queue_ref.root)
    }

    /// Return `ASCENDING` or `DESCENDING` `CritQueue`, per `direction`.
    public fun new<V: store>(
        direction: bool
    ): CritQueue<V> {
        CritQueue{
            direction,
            root: option::none(),
            head: option::none(),
            enqueues: table::new(),
            inners: table::new(),
            leaves: table::new()
        }
    }

    /// Return `true` if, were `enqueue_key` to be enqueued, it would
    /// trail behind the head of the given `CritQueue`.
    public fun would_trail_head<V>(
        crit_queue_ref: &CritQueue<V>,
        enqueue_key: u64
    ): bool {
        // Return false if the crit-queue is empty and has no head.
        if (option::is_none(&crit_queue_ref.head)) false else
            // Otherwise, if the crit-queue is ascending, return true
            // if enqueue key is greater than or equal to the enqueue
            // key encoded in the head leaf key.
            if (crit_queue_ref.direction == ASCENDING) (enqueue_key as u128) >=
                *option::borrow(&crit_queue_ref.head) >> ENQUEUE_KEY
            // Otherwise, if the crit-queue is descending, return true
            // if the enqueue key is less than or equal to the enqueue
            // key encoded in the head leaf key.
            else (enqueue_key as u128) <=
                *option::borrow(&crit_queue_ref.head) >> ENQUEUE_KEY
    }

    /// Return `true` if, were `enqueue_key` to be enqueued, it would
    /// become new the new head of the given `CritQueue`.
    public fun would_become_new_head<V>(
        crit_queue_ref: &CritQueue<V>,
        enqueue_key: u64
    ): bool {
        // Return true if the crit-queue is empty and has no head.
        if (option::is_none(&crit_queue_ref.head)) true else
            // Otherwise, if the crit-queue is ascending, return true
            // if enqueue key is less than the enqueue key encoded in
            // the head leaf key.
            if (crit_queue_ref.direction == ASCENDING) (enqueue_key as u128) <
                *option::borrow(&crit_queue_ref.head) >> ENQUEUE_KEY
            // Otherwise, if the crit-queue is descending, return true
            // if the enqueue key is greater than the enqueue key
            // encoded in the head leaf key.
            else (enqueue_key as u128) >
                *option::borrow(&crit_queue_ref.head) >> ENQUEUE_KEY
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return the leaf key corresponding to the given `enqueue_key`
    /// for the indicated `CritQueue`.
    fun get_leaf_key<V>(
        enqueue_key: u64,
        crit_queue_ref_mut: &mut CritQueue<V>
    ): u128 {
        // Borrow mutable reference to enqueue count table.
        let enqueues_ref_mut = &mut crit_queue_ref_mut.enqueues;
        let enqueue_count = 0; // Assume key has not been enqueued.
        // If the key has already been enqueued:
        if (table::contains(enqueues_ref_mut, enqueue_key)) {
            // Borrow mutable reference to enqueue count.
            let enqueue_count_ref_mut =
                table::borrow_mut(enqueues_ref_mut, enqueue_key);
            // Get enqueue count of current enqueue key.
            enqueue_count = *enqueue_count_ref_mut + 1;
            // Assert max enqueue count is not exceeded.
            assert!(enqueue_count <= MAX_ENQUEUE_COUNT, E_TOO_MANY_ENQUEUES);
            // Update enqueue count table.
            *enqueue_count_ref_mut = enqueue_count;
        } else { // If the enqueue key has not been enqueued:
            // Initialize the enqueue count to 0.
            table::add(enqueues_ref_mut, enqueue_key, enqueue_count);
        }; // Enqueue count has been assigned.
        // If a descending crit-queue, flip all bits of the count.
        if (crit_queue_ref_mut.direction == DESCENDING) enqueue_count =
            enqueue_count ^ NOT_ENQUEUE_COUNT_DESCENDING;
        // Return leaf key with encoded enqueue key and enqueue count.
        (enqueue_key as u128) << ENQUEUE_KEY | (enqueue_count as u128)
    }

    /// Return `true` if `node_key` indicates an `Inner` node.
    fun is_inner_key(
        node_key: u128
    ): bool {
        node_key & NODE_TYPE == NODE_INNER
    }

    /// Return `true` if `node_key` indicates a `Leaf`.
    fun is_leaf_key(
        node_key: u128
    ): bool {
        node_key & NODE_TYPE == NODE_LEAF
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify borrowing, immutably and mutably.
    fun test_borrowers():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Add a mock leaf to the leaves table.
        table::add(&mut crit_queue.leaves, 0,
            Leaf{value: 0, parent: option::none()});
        // Assert correct value borrow.
        assert!(*borrow(&crit_queue, 0) == 0, 0);
        *borrow_mut(&mut crit_queue, 0) = 123; // Mutate value.
        assert!(*borrow(&crit_queue, 0) == 123, 0); // Assert mutation.
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify lookup returns.
    fun test_get_head_leaf_key():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert no head leaf key indicated.
        assert!(option::is_none(&get_head_leaf_key(&crit_queue)), 0);
        // Set mock head leaf key.
        option::fill(&mut crit_queue.head, 123);
        // Assert head leaf key returned correctly.
        assert!(*option::borrow(&get_head_leaf_key(&crit_queue)) == 123, 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful leaf key generation.
    fun test_get_leaf_key():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert successful returns across multiple queries.
        assert!(get_leaf_key(0, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
        ), 0);
        assert!(get_leaf_key(0, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
        ), 0);
        assert!(get_leaf_key(0, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000010",
        ), 0);
        *table::borrow_mut(&mut crit_queue.enqueues, 0) =
            MAX_ENQUEUE_COUNT - 1; // Set count to one less than max.
        // Assert can get one final leaf key.
        assert!(get_leaf_key(0, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00111111111111111111111111111111",
            b"11111111111111111111111111111111",
        ), 0);
        // Flip the enqueue direction.
        crit_queue.direction = DESCENDING;
        // Assert successful returns across multiple queries.
        assert!(get_leaf_key(1, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111111",
        ), 0);
        assert!(get_leaf_key(1, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111110",
        ), 0);
        assert!(get_leaf_key(1, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111101",
        ), 0);
        *table::borrow_mut(&mut crit_queue.enqueues, 1) =
            MAX_ENQUEUE_COUNT - 1; // Set count to one less than max.
        // Assert can get one final leaf key.
        assert!(get_leaf_key(1, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"01000000000000000000000000000000",
            b"00000000000000000000000000000000",
        ), 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for exceeding maximum enqueue count.
    fun test_get_leaf_key_too_many_enqueues():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Set count to max.
        table::add(&mut crit_queue.enqueues, 0, MAX_ENQUEUE_COUNT);
        // Attempt to enqueue one more.
        get_leaf_key(0, &mut crit_queue);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify returns for membership checks.
    fun test_has_leaf_key():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert arbitrary leaf key not contained.
        assert!(!has_leaf_key(&crit_queue, 0), 0);
        // Add a mock leaf to the leaves table.
        table::add(&mut crit_queue.leaves, 0,
            Leaf{value: 0, parent: option::none()});
        // Assert arbitrary leaf key contained.
        assert!(has_leaf_key(&crit_queue, 0), 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful returns.
    fun test_is_empty():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert is marked empty.
        assert!(is_empty(&crit_queue), 0);
        option::fill(&mut crit_queue.root, 1234); // Mark mock root.
        // Assert is marked not empty.
        assert!(!is_empty(&crit_queue), 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful determination of key types.
    fun test_key_types() {
        assert!(is_inner_key(u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"10000000000000000000000000000000",
            b"00000000000000000000000000000000",
        )), 0);
        assert!(is_leaf_key(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111111",
        )), 0);
    }

    #[test]
    /// Verify lookup returns.
    fun test_would_become_trail_head():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert return for value that would become new head.
        assert!(would_become_new_head(&crit_queue, HI_64), 0);
        // Assert return for value that would not trail head.
        assert!(!would_trail_head(&crit_queue, HI_64), 0);
        // Set mock head leaf key.
        option::fill(&mut crit_queue.head, u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000010",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
        ));
        // Assert return for value that would become new head.
        assert!(would_become_new_head(&crit_queue, (u_128(b"01") as u64)), 0);
        // Assert return for value that would not trail head.
        assert!(!would_trail_head(&crit_queue, (u_128(b"01") as u64)), 0);
        // Assert return for value that would not become new head.
        assert!(!would_become_new_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Assert return for value that would trail head.
        assert!(would_trail_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Flip crit-queue direction.
        crit_queue.direction = DESCENDING;
        // Assert return for value that would become new head.
        assert!(would_become_new_head(&crit_queue, (u_128(b"11") as u64)), 0);
        // Assert return for value that would not trail head.
        assert!(!would_trail_head(&crit_queue, (u_128(b"11") as u64)), 0);
        // Assert return for value that would not become new head.
        assert!(!would_become_new_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Assert return for value that would trail head.
        assert!(would_trail_head(&crit_queue, (u_128(b"10") as u64)), 0);
        crit_queue // Return crit-queue.
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}