/// An iterable table implementation based on a [doubly linked list](
/// https://en.wikipedia.org/wiki/Doubly_linked_list).
///
/// Modeled off of what was previously `aptos_std::iterable_table.move`,
/// which had been removed from `aptos_std` as of the time of this
/// writing.
///
/// Accepts key-value pairs having key type `K` and value type `V`.
///
/// ---
///
module econia::table_list {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table_with_length::{Self, TableWithLength};
    use std::option::{Self, Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A node in the doubly linked list, pointing to the previous and
    /// next keys, if there are any.
    struct Node<
        K: copy + drop + store,
        V: store
    > has store {
        /// Value in a key-value pair.
        value: V,
        /// Previous key in linked list, if any.
        previous: Option<K>,
        /// Next key in linked list, if any.
        next: Option<K>
    }

    /// A doubly linked list based on a hash table.
    struct TableList<
        K: copy + drop + store,
        V: store
    > has store {
        /// All `Node`s in the list.
        inner_table: TableWithLength<K, Node<K, V>>,
        /// Key of first `Node` in the list, if any.
        head: Option<K>,
        /// Key of final `Node` in the list, if any.
        tail: Option<K>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When attempting to destroy a table that is not empty.
    const E_DESTROY_NOT_EMPTY: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Add `key`-`value` pair to `TableList` indicated by
    /// `table_list_ref_mut`, aborting if `key` already present.
    public fun add<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref_mut: &mut TableList<K, V>,
        key: K,
        value: V
    ) {
        let node = Node{value, previous: table_list_ref_mut.tail,
            next: option::none()}; // Wrap value in a node.
        // Add node to the inner table.
        table_with_length::add(&mut table_list_ref_mut.inner_table, key, node);
        // If adding the first node in the table:
        if (option::is_none(&table_list_ref_mut.head)) {
            // Mark key as the new head.
            table_list_ref_mut.head = option::some(key);
        } else { // If adding node that is not first in the table:
            // Get the old tail node key.
            let old_tail = option::borrow(&table_list_ref_mut.tail);
            // Update the old tail node to have the new key as next.
            table_with_length::borrow_mut(
                &mut table_list_ref_mut.inner_table, *old_tail).next =
                    option::some(key);
        };
        // Update the table tail to the new key.
        table_list_ref_mut.tail = option::some(key);
    }

    /// Return immutable reference to the value that `key` maps to,
    /// aborting if `key` is not in `table_list_ref_mut`.
    public fun borrow<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref: &TableList<K, V>,
        key: K,
    ): &V {
        &table_with_length::borrow(&table_list_ref.inner_table, key).value
    }

    /// Borrow the `Node` in the `TableList` at `table_list_ref` having
    /// `key`, then return:
    /// * Immutable reference to corresponding value.
    /// * Optional key of previous `Node` in the `TableList`, if any.
    /// * Optional key of next `Node` in the `TableList`, if any.
    public fun borrow_iterable<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref: &TableList<K, V>,
        key: K,
    ): (
        &V,
        Option<K>,
        Option<K>
    ) {
        let node_ref = // Borrow immutable reference to node having key.
            table_with_length::borrow(&table_list_ref.inner_table, key);
        // Return corresponding fields.
        (&node_ref.value, node_ref.previous, node_ref.next)
    }

    /// Mutably borrow the `Node` in the `TableList` at `table_list_ref`
    /// having `key`, then return:
    /// * Mutable reference to corresponding value.
    /// * Optional key of previous `Node` in the `TableList`, if any.
    /// * Optional key of next `Node` in the `TableList`, if any.
    public fun borrow_iterable_mut<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref_mut: &mut TableList<K, V>,
        key: K,
    ): (
        &mut V,
        Option<K>,
        Option<K>
    ) {
        // Borrow mutable reference to node having key.
        let node_ref_mut = table_with_length::borrow_mut(
            &mut table_list_ref_mut.inner_table, key);
        // Return corresponding fields.
        (&mut node_ref_mut.value, node_ref_mut.previous, node_ref_mut.next)
    }

    ///  Return mutable reference to the value that `key` maps to,
    /// aborting if `key` is not in `table_list_ref_mut`.
    public fun borrow_mut<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref_mut: &mut TableList<K, V>,
        key: K,
    ): &mut V {
        &mut table_with_length::
            borrow_mut(&mut table_list_ref_mut.inner_table, key).value
    }

    /// Return `true` if `TableList` at `table_list_ref` contains `key`,
    /// else `false`.
    public fun contains<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref: &TableList<K, V>,
        key: K,
    ): bool {
        table_with_length::contains(&table_list_ref.inner_table, key)
    }


    /// Destroy an empty `TableList`, aborting if not empty.
    public fun destroy_empty<
        K: copy + drop + store,
        V: store
    >(
        table_list: TableList<K, V>
    ) {
        // Assert table list is empty.
        assert!(is_empty(&table_list), E_DESTROY_NOT_EMPTY);
        // Unpack, destroying head and tail fields.
        let TableList{inner_table, head: _, tail: _} = table_list;
        table_with_length::destroy_empty(inner_table);
    }

    /// Return optional head key from `TableList` at `table_list_ref`.
    public fun get_head_key<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref: &TableList<K, V>
    ): Option<K> {
        table_list_ref.head
    }

    /// Return optional tail key from `TableList` at `table_list_ref`.
    public fun get_tail_key<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref: &TableList<K, V>
    ): Option<K> {
        table_list_ref.tail
    }

    /// Return number of elements in `TableList` at `table_list_ref`.
    public fun length<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref: &TableList<K, V>
    ): u64 {
        table_with_length::length(&table_list_ref.inner_table)
    }

    /// Return an empty `TableList`.
    public fun new<
        K: copy + drop + store,
        V: store
    >(): TableList<K, V> {
        TableList{
            inner_table: table_with_length::new(),
            head: option::none(),
            tail: option::none()
        }
    }

    /// Return `true` if `TableList` at `table_list_ref` is empty, else
    /// `false`.
    public fun is_empty<
        K: copy + drop + store,
        V: store
    >(
        table_list_ref: &TableList<K, V>
    ): bool {
        table_with_length::empty(&table_list_ref.inner_table)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}