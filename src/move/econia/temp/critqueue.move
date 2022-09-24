module econia::critqueue {

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Crit-queue direction bit flag indicating `ASCENDING`.
    const ASCENDING_BIT_FLAG: u128 = 0;
    /// Crit-queue direction bit flag indicating `DESCENDING`.
    const DESCENDING_BIT_FLAG: u128 = 1;
    /// Bit number of crit-queue direction bit flag.
    const DIRECTION: u8 = 62;

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

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}