/// Extends the `aptos_framework::table` with a `vector` of contained
/// keys, enabling simple SDK indexing. Does not implement wrappers for
/// all functions.
module econia::open_table {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table;
    use std::vector;

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Extended version of `aptos_framework::table` with vector of
    /// contained keys
    struct OpenTable<K: copy + drop, phantom V> has store {
        /// Standard table type
        base_table: table::Table<K, V>,
        /// Vector of keys contained in table
        keys: vector<K>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return an empty `OpenTable`
    public fun empty<K: copy + drop, V: store>():
    OpenTable<K, V> {
        OpenTable{base_table: table::new(), keys: vector::empty()}
    }

    /// Add `key` and `value` to `open_table`, aborting if `key` already
    /// in `open_table`
    public fun add<K: copy + drop, V>(
        open_table: &mut OpenTable<K, V>,
        key: K,
        value: V
    ) {
        // Add key-value pair to base table (aborts if already inside)
        table::add(&mut open_table.base_table, key, value);
        // Add key to the list of keys
        vector::push_back(&mut open_table.keys, key);
    }

    /// Return immutable reference to the value which `key` maps to,
    /// aborting if no entry in `open_table`
    public fun borrow<K: copy + drop, V>(
        open_table: &OpenTable<K, V>,
        key: K
    ): &V {
        // Borrow corresponding reference (aborts if no such entry)
        table::borrow(&open_table.base_table, key)
    }

    /// Return mutable reference to the value which `key` maps to,
    /// aborting if no entry in `open_table`
    public fun borrow_mut<K: copy + drop, V>(
        open_table: &mut OpenTable<K, V>,
        key: K
    ): &mut V {
        // Borrow corresponding reference (aborts if no such entry)
        table::borrow_mut(&mut open_table.base_table, key)
    }

    /// Return `true` if `key` in `open_table`, otherwise `false`
    public fun contains<K: copy + drop, V>(
        open_table: &OpenTable<K, V>,
        key: K
    ): bool {
        // Return if key in base table
        table::contains(&open_table.base_table, key)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify basic functionality
    fun test_basic():
    OpenTable<u8, u8> {
        let open_table = empty();
        // Assert keys list is empty
        assert!(vector::is_empty(&open_table.keys), 0);
        // Assert membership check returns
        assert!(!contains(&open_table, 1), 0);
        add(&mut open_table, 1, 2); // Add key 1, value 2
        add(&mut open_table, 3, 4); // Add key 3, value 4
        // Assert membership check returns
        assert!(contains(&open_table, 1), 0);
        assert!(contains(&open_table, 3), 0);
        // Assert correct borrow returns
        assert!(*table::borrow(&open_table.base_table, 1) == 2, 0);
        assert!(*table::borrow(&open_table.base_table, 3) == 4, 0);
        assert!(*vector::borrow(&open_table.keys, 0) == 1, 0);
        assert!(*vector::borrow(&open_table.keys, 1) == 3, 0);
        // Borrow mutabl reference to value for key 1
        let key_1_ref_mut = borrow_mut(&mut open_table, 1);
        *key_1_ref_mut = 8; // Modify value
        // Assert correct borrow return
        assert!(*borrow(&open_table, 1) == 8, 0);
        open_table // Return rather than unpack
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}