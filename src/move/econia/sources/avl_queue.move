/// AVL queue: a hybrid between an AVL tree and a queue.
///
/// # Node IDs
///
/// Tree nodes and list nodes are each assigned a 1-indexed 14-bit
/// serial ID known as a node ID. Node ID 0 is reserved for null, such
/// that the maximum number of allocated nodes for each node type is
/// thus $2^{14} - 1 = 16383$.
///
/// # Access keys
///
/// | Bit(s) | Data                                         |
/// |--------|----------------------------------------------|
/// | 47-60  | Tree node ID                                 |
/// | 33-46  | List node ID                                 |
/// | 32     | If set, ascending AVL queue, else descending |
/// | 0-31   | Insertion key                                |
///
/// # Height
///
/// In the present implementation, left or right height denotes the
/// height of a node's left or right subtree, respectively, plus one.
/// Subtree height is adjusted by one to avoid negative numbers, with
/// the resultant value denoting the height of a tree rooted at the
/// given node, accounting only for height to the given side:
///
/// >       2
/// >      / \
/// >     1   3
/// >          \
/// >           4
///
/// | Key | Left height | Right height |
/// |-----|-------------|--------------|
/// | 1   | 0           | 0            |
/// | 2   | 1           | 2            |
/// | 3   | 0           | 1            |
/// | 4   | 0           | 0            |
///
/// For a tree of size $n \geq 1$, an AVL tree's height is at most
///
/// $$h \leq c \log_2(n + d) + b$$
///
/// where
///
/// * $\varphi = \frac{1 + \sqrt{5}}{2} \approx 1.618$ (the golden
///   ratio),
/// * $c = \frac{1}{\log_2 \varphi} \approx 1.440$ ,
/// * $b = \frac{c}{2} \log_2 5 - 2 \approx -0.328$ , and
/// * $d = 1 + \frac{1}{\varphi^4 \sqrt{5}} \approx 1.065$ .
///
/// With a maximum node count of $n_{max} = 2^{14} - 1 = 13683$, the
/// maximum height of an AVL tree in the present implementation is
/// thus
///
/// $$h_{max} = \lfloor c \log_2(n_{max} + d) + b \rfloor = 19$$
///
/// such that left height and right height can always be encoded in
/// $\lceil \log_2 19 \rceil = 5$ bits each.
///
/// # References
///
/// * [Adelson-Velski and Landis 1962] (original paper)
/// * [Galles 2011] (interactive visualizer)
/// * [Wikipedia 2022]
///
/// [Adelson-Velski and Landis 1962]:
///     https://zhjwpku.com/assets/pdf/AED2-10-avl-paper.pdf
/// [Galles 2011]:
///     https://www.cs.usfca.edu/~galles/visualization/AVLtree.html
/// [Wikipedia 2022]:
///     https://en.wikipedia.org/wiki/AVL_tree
///
/// # Complete docgen index
///
/// The below index is automatically generated from source code:
module econia::avl_queue {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table::{Self, Table};
    use aptos_std::table_with_length::{Self, TableWithLength};
    use std::option::{Self, Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use std::vector;

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A hybrid between an AVL tree and a queue. See above.
    ///
    /// Most non-table fields stored compactly in `bits` as follows:
    ///
    /// | Bit(s)  | Data                                               |
    /// |---------|----------------------------------------------------|
    /// | 126     | If set, ascending AVL queue, else descending       |
    /// | 112-125 | Tree node ID at top of inactive stack              |
    /// | 98-111  | List node ID at top of inactive stack              |
    /// | 84-97   | AVL queue head list node ID                        |
    /// | 52-83   | AVL queue head insertion key (if node ID not null) |
    /// | 38-51   | AVL queue tail list node ID                        |
    /// | 6-37    | AVL queue tail insertion key (if node ID not null) |
    /// | 0-5     | Bits 8-13 of tree root node ID                     |
    ///
    /// Bits 0-7 of the tree root node ID are stored in `root_lsbs`.
    struct AVLqueue<V> has store {
        bits: u128,
        root_lsbs: u8,
        /// Map from tree node ID to tree node.
        tree_nodes: TableWithLength<u64, TreeNode>,
        /// Map from list node ID to list node.
        list_nodes: TableWithLength<u64, ListNode>,
        /// Map from list node ID to optional insertion value.
        values: Table<u64, Option<V>>
    }

    /// A tree node in an AVL queue.
    ///
    /// All fields stored compactly in `bits` as follows:
    ///
    /// | Bit(s) | Data                                 |
    /// |--------|--------------------------------------|
    /// | 94-125 | Insertion key                        |
    /// | 89-93  | Left height                          |
    /// | 84-88  | Right height                         |
    /// | 70-83  | Parent node ID                       |
    /// | 56-69  | Left child node ID                   |
    /// | 42-55  | Right child node ID                  |
    /// | 28-41  | List head node ID                    |
    /// | 14-27  | List tail node ID                    |
    /// | 0-13   | Next inactive node ID, when in stack |
    ///
    /// All fields except next inactive node ID are ignored when the
    /// node is in the inactive nodes stack.
    struct TreeNode has store {
        bits: u128
    }

    /// A list node in an AVL queue.
    ///
    /// For compact storage, a "virtual last field" and a "virtual next
    /// field" are split into two `u8` fields each: one for
    /// most-significant bits (`last_msbs`, `next_msbs`), and one for
    /// least-significant bits (`last_lsbs`, `next_lsbs`).
    ///
    /// When set at bit 14, the 16-bit concatenated result of `_msbs`
    /// and `_lsbs` fields, in either case, refers to a tree node ID: If
    /// `last_msbs` and `last_lsbs` indicate a tree node ID, then the
    /// list node is the head of the list at the given tree node. If
    /// `next_msbs` and `next_lsbs` indicate a tree node ID, then the
    /// list node is the tail of the list at the given tree node.
    ///
    /// If not set at bit 14, the corresponding node ID is either the
    /// last or the next list node in the doubly linked list.
    ///
    /// If list node is in the inactive list node stack, next node ID
    /// indicates next inactive node in the stack.
    struct ListNode has store {
        last_msbs: u8,
        last_lsbs: u8,
        next_msbs: u8,
        next_lsbs: u8
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Number of allocated nodes is too high.
    const E_TOO_MANY_NODES: u64 = 0;
    /// Insertion key is too large.
    const E_INSERTION_KEY_TOO_LARGE: u64 = 1;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ascending AVL queue flag.
    const ASCENDING: bool = true;
    /// Bit flag denoting ascending AVL queue.
    const BIT_FLAG_ASCENDING: u8 = 1;
    /// Bit flag denoting a tree node.
    const BIT_FLAG_TREE_NODE: u8 = 1;
    /// Number of bits in a byte.
    const BITS_PER_BYTE: u8 = 8;
    /// Flag for decrement to height during retrace.
    const DECREMENT: bool = false;
    /// Descending AVL queue flag.
    const DESCENDING: bool = false;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// `u128` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 128, 2))`.
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// Single bit set in integer of width required to encode bit flag.
    const HI_BIT: u8 = 1;
    /// All bits set in integer of width required to encode a byte.
    /// Generated in Python via `hex(int('1' * 8, 2))`.
    const HI_BYTE: u64 = 0xff;
    /// All bits set in integer of width required to encode left or
    /// right height. Generated in Python via `hex(int('1' * 5, 2))`.
    const HI_HEIGHT: u8 = 0x1f;
    /// All bits set in integer of width required to encode insertion
    /// key. Generated in Python via `hex(int('1' * 32, 2))`.
    const HI_INSERTION_KEY: u64 = 0xffffffff;
    /// All bits set in integer of width required to encode node ID.
    /// Generated in Python via `hex(int('1' * 14, 2))`.
    const HI_NODE_ID: u64 = 0x3fff;
    /// Flag for increment to height during retrace.
    const INCREMENT: bool = true;
    /// Flag for left direction.
    const LEFT: bool = true;
    /// Flag for null value when null defined as 0.
    const NIL: u8 = 0;
    /// $2^{14} - 1$, the maximum number of nodes that can be allocated
    /// for either node type.
    const N_NODES_MAX: u64 = 16383;
    /// Flag for right direction.
    const RIGHT: bool = false;
    /// Number of bits sort order bit flag is shifted in an access key.
    const SHIFT_ACCESS_SORT_ORDER: u8 = 32;
    /// Number of bits list node ID is shifted in an access key.
    const SHIFT_ACCESS_LIST_NODE_ID: u8 = 33;
    /// Number of bits tree node ID is shifted in an access key.
    const SHIFT_ACCESS_TREE_NODE_ID: u8 = 47;
    /// Number of bits sort order is shifted in `AVLqueue.bits`.
    const SHIFT_SORT_ORDER: u8 = 126;
    /// Number of bits left child node ID is shifted in `TreeNode.bits`.
    const SHIFT_CHILD_LEFT: u8 = 56;
    /// Number of bits right child node ID is shifted in
    /// `TreeNode.bits`.
    const SHIFT_CHILD_RIGHT: u8 = 42;
    /// Number of bits AVL queue head insertion key is shifted in
    /// `AVLqueue.bits`.
    const SHIFT_HEAD_KEY: u8 = 52;
    /// Number of bits AVL queue head list node ID is shifted in
    /// `AVLqueue.bits`.
    const SHIFT_HEAD_NODE_ID: u8 = 84;
    /// Number of bits left height is shifted in `TreeNode.bits`.
    const SHIFT_HEIGHT_LEFT: u8 = 89;
    /// Number of bits right height is shifted in `TreeNode.bits`.
    const SHIFT_HEIGHT_RIGHT: u8 = 84;
    /// Number of bits insertion key is shifted in `TreeNode.bits`.
    const SHIFT_INSERTION_KEY: u8 = 94;
    /// Number of bits inactive list node stack top is shifted in
    /// `AVLqueue.bits`.
    const SHIFT_LIST_STACK_TOP: u8 = 98;
    /// Number of bits node type bit flag is shifted in `ListNode`
    /// virtual last and next fields.
    const SHIFT_NODE_TYPE: u8 = 14;
    /// Number of bits list head node ID is shited in `TreeNode.bits`.
    const SHIFT_LIST_HEAD: u8 = 28;
    /// Number of bits list tail node ID is shited in `TreeNode.bits`.
    const SHIFT_LIST_TAIL: u8 = 14;
    /// Number of bits parent node ID is shifted in `AVLqueue.bits`.
    const SHIFT_PARENT: u8 = 70;
    /// Number of bits AVL queue tail insertion key is shifted in
    /// `AVLqueue.bits`.
    const SHIFT_TAIL_KEY: u8 = 6;
    /// Number of bits AVL queue tail list node ID is shifted in
    /// `AVLqueue.bits`.
    const SHIFT_TAIL_NODE_ID: u8 = 38;
    /// Number of bits inactive tree node stack top is shifted in
    /// `AVLqueue.bits`.
    const SHIFT_TREE_STACK_TOP: u8 = 112;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Get insertion key encoded in an access key.
    ///
    /// # Testing
    ///
    /// * `test_access_key_getters()`
    fun get_access_key_insertion_key(
        access_key: u64
    ): u64 {
        access_key & HI_INSERTION_KEY
    }

    /// Insert a key-value pair into an AVL queue.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `key`: Key to insert.
    /// * `value`: Value to insert.
    ///
    /// # Returns
    ///
    /// * `u64`: Access key used for lookup.
    ///
    /// # Aborts
    ///
    /// * `E_INSERTION_KEY_TOO_LARGE`: Insertion key is too large.
    ///
    /// # Failure testing
    ///
    /// * `test_insert_insertion_key_too_large()`.
    /// * `test_insert_too_many_list_nodes()`.
    /// * `test_insert_too_many_tree_nodes()`.
    ///
    /// # State verification testing
    ///
    /// See `test_insert()` for state verification testing of the
    /// below insertion sequence.
    ///
    /// Insert $\langle 3, 9 \rangle$:
    ///
    /// >      3
    /// >     [9]
    ///
    /// Insert $\langle 4, 8 \rangle$:
    ///
    /// >      3
    /// >     [9]
    /// >        \
    /// >         4
    /// >        [8]
    ///
    /// Insert $\langle 5, 7 \rangle$:
    ///
    /// >         4
    /// >        [8]
    /// >       /   \
    /// >      3     5
    /// >     [9]   [7]
    ///
    /// Insert $\langle 3, 6 \rangle$
    ///
    /// >               4
    /// >              [8]
    /// >             /   \
    /// >            3     5
    /// >     [9 -> 6]    [7]
    ///
    /// Insert $\langle 5, 5 \rangle$
    ///
    /// >               4
    /// >              [8]
    /// >             /   \
    /// >            3     5
    /// >     [9 -> 6]     [7 -> 5]
    public fun insert<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        key: u64,
        value: V
    ): u64 {
        // Assert insertion key is not too many bits.
        assert!(key <= HI_INSERTION_KEY, E_INSERTION_KEY_TOO_LARGE);
        // Search for key, storing match node ID, and optional side on
        // which a new leaf would be inserted relative to match node.
        let (match_node_id, new_leaf_side) = search(avlq_ref_mut, key);
        // If search returned null from the root, or if search flagged
        // that a new tree node will have to be inserted as child, flag
        // that the inserted list node will be the sole node in the
        // corresponding doubly linked list.
        let solo = match_node_id == (NIL as u64) ||
                   option::is_some(&new_leaf_side);
        // If a solo list node, flag no anchor tree node yet inserted,
        // otherwise set anchor tree node as match node from search.
        let anchor_tree_node_id = if (solo) (NIL as u64) else match_node_id;
        let list_node_id = // Insert list node, storing its node ID.
            insert_list_node(avlq_ref_mut, anchor_tree_node_id, value);
        // Get corresponding tree node: if solo list node, insert a tree
        // node and store its ID. Otherwise tree node is match node from
        // search.
        let tree_node_id = if (solo) insert_tree_node(
            avlq_ref_mut, key, match_node_id, list_node_id, new_leaf_side) else
            match_node_id;
        // If just inserted new tree node that is not root, retrace
        // starting at the parent to the inserted tree node.
        if (solo && (match_node_id != (NIL as u64)))
            retrace(avlq_ref_mut, match_node_id, INCREMENT,
                    *option::borrow(&new_leaf_side));
        // Check AVL queue head and tail.
        insert_check_head_tail(avlq_ref_mut, key, list_node_id);
        let order_bit = // Get sort order bit from AVL queue bits.
            (avlq_ref_mut.bits >> SHIFT_SORT_ORDER) & (HI_BIT as u128);
        // Return bit-packed access key.
        key | ((order_bit as u64) << SHIFT_ACCESS_SORT_ORDER) |
              ((list_node_id    ) << SHIFT_ACCESS_LIST_NODE_ID) |
              ((tree_node_id    ) << SHIFT_ACCESS_TREE_NODE_ID)
    }

    /// Return a new AVL queue, optionally allocating inactive nodes.
    ///
    /// # Parameters
    ///
    /// * `sort_order`: `ASCENDING` or `DESCENDING`.
    /// * `n_inactive_tree_nodes`: The number of inactive tree nodes
    ///   to allocate.
    /// * `n_inactive_list_nodes`: The number of inactive list nodes
    ///   to allocate.
    ///
    /// # Returns
    ///
    /// * `AVLqueue<V>`: A new AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_new_no_nodes()`
    /// * `test_new_some_nodes()`
    /// * `test_new_some_nodes_loop()`
    public fun new<V: store>(
        sort_order: bool,
        n_inactive_tree_nodes: u64,
        n_inactive_list_nodes: u64,
    ): AVLqueue<V> {
        // Assert not trying to allocate too many tree nodes.
        verify_node_count(n_inactive_tree_nodes);
        // Assert not trying to allocate too many list nodes.
        verify_node_count(n_inactive_list_nodes);
        // Initialize bits field based on sort order.
        let bits = if (sort_order == DESCENDING) (NIL as u128) else
            ((BIT_FLAG_ASCENDING as u128) << SHIFT_SORT_ORDER);
        // Mask in 1-indexed node ID at top of each inactive node stack.
        bits = bits | ((n_inactive_tree_nodes as u128) << SHIFT_TREE_STACK_TOP)
            | ((n_inactive_list_nodes as u128) << SHIFT_LIST_STACK_TOP);
        // Declare empty AVL queue.
        let avlq = AVLqueue{bits,
                            root_lsbs: NIL,
                            tree_nodes: table_with_length::new(),
                            list_nodes: table_with_length::new(),
                            values: table::new()};
        // If need to allocate at least one tree node:
        if (n_inactive_tree_nodes > 0) {
            let i = 0; // Declare loop counter.
            // While nodes to allocate:
            while (i < n_inactive_tree_nodes) {
                // Add to tree nodes table a node having 1-indexed node
                // ID derived from counter, indicating next inactive
                // node in stack has ID of last allocated node (or null
                // in the case of the first loop iteration).
                table_with_length::add(
                    &mut avlq.tree_nodes, i + 1, TreeNode{bits: (i as u128)});
                i = i + 1; // Increment loop counter.
            };
        };
        // If need to allocate at least one list node:
        if (n_inactive_list_nodes > 0) {
            let i = 0; // Declare loop counter.
            // While nodes to allocate:
            while (i < n_inactive_list_nodes) {
                // Add to list nodes table a node having 1-indexed node
                // ID derived from counter, indicating next inactive
                // node in stack has ID of last allocated node (or null
                // in the case of the first loop iteration).
                table_with_length::add(&mut avlq.list_nodes, i + 1, ListNode{
                    last_msbs: 0,
                    last_lsbs: 0,
                    next_msbs: ((i >> BITS_PER_BYTE) as u8),
                    next_lsbs: ((i & HI_BYTE) as u8)});
                // Allocate optional insertion value entry.
                table::add(&mut avlq.values, i + 1, option::none());
                i = i + 1; // Increment loop counter.
            };
        };
        avlq // Return AVL queue.
    }

    /// Return `true` if given AVL queue has ascending sort order.
    ///
    /// # Testing
    ///
    /// * `test_is_ascending()`
    public fun is_ascending<V>(
        avlq_ref: &AVLqueue<V>
    ): bool {
        ((avlq_ref.bits >> SHIFT_SORT_ORDER) & (BIT_FLAG_ASCENDING as u128)) ==
            (BIT_FLAG_ASCENDING as u128)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Check head and tail of AVL queue during insertion.
    ///
    /// Update fields as needed based on sort order.
    ///
    /// Inner function for `insert()`.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `key`: Insertion key just inserted.
    /// * `list_node_id`: ID of list node just inserted.
    ///
    /// # Testing
    ///
    /// * `test_insert_check_head_tail_ascending()`
    /// * `test_insert_check_head_tail_descending()`
    fun insert_check_head_tail<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        key: u64,
        list_node_id: u64
    ) {
        let bits = avlq_ref_mut.bits; // Get AVL queue field bits.
        // Extract relevant fields.
        let (order_bit, head_key, tail_key) =
            (((bits >> SHIFT_SORT_ORDER ) & (HI_BIT as u128) as u8),
             ((bits >> SHIFT_HEAD_KEY) & (HI_INSERTION_KEY  as u128) as u64),
             ((bits >> SHIFT_TAIL_KEY) & (HI_INSERTION_KEY  as u128) as u64));
        // Determine if AVL queue is ascending.
        let ascending = order_bit == BIT_FLAG_ASCENDING;
        if ((head_key == (NIL as u64)) || // If no head key,
            // If ascending AVL queue and insertion key less than head
            // key,
            (ascending && key < head_key) || // If
            // Or if descending AVL queue and insertion key greater than
            // head key,
            (!ascending && key > head_key))
            // Reassign bits for head key and node ID:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out fields via mask unset at field bits.
                (HI_128 ^ (((HI_INSERTION_KEY as u128) << SHIFT_HEAD_KEY) |
                           ((HI_NODE_ID as u128) << SHIFT_HEAD_NODE_ID))) |
                // Mask in new bits.
                ((list_node_id as u128) << SHIFT_HEAD_NODE_ID) |
                ((key as u128) << SHIFT_HEAD_KEY);
        if ((tail_key == (NIL as u64)) || // If no tail key,
            // If ascending AVL queue and insertion key greater than or
            // equal to tail key,
            (ascending && key >= tail_key) || // If
            // Or if descending AVL queue and insertion key less than or
            // equal to tail key:
            (!ascending && key <= tail_key))
            // Reassign bits for tail key and node ID:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out fields via mask unset at field bits.
                (HI_128 ^ (((HI_INSERTION_KEY as u128) << SHIFT_TAIL_KEY) |
                           ((HI_NODE_ID as u128) << SHIFT_TAIL_NODE_ID))) |
                // Mask in new bits.
                ((list_node_id as u128) << SHIFT_TAIL_NODE_ID) |
                ((key as u128) << SHIFT_TAIL_KEY);
    }

    /// Insert a list node and return its node ID.
    ///
    /// In the case of inserting a list node to a doubly linked list in
    /// an existing tree node, known as the "anchor tree node", the list
    /// node becomes the new list tail.
    ///
    /// In the other case of inserting a "solo node" as the sole list
    /// node in a doubly linked list in a new tree leaf, the list node
    /// becomes the head and tail of the new list.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `anchor_tree_node_id`: Node ID of anchor tree node, `NIL` if
    ///   inserting a list node as the sole list node in a new tree
    ///   node.
    /// * `value`: Insertion value for list node to insert.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of inserted list node.
    ///
    /// # Testing
    ///
    /// * `test_insert_list_node_not_solo()`
    /// * `test_insert_list_node_solo()`
    fun insert_list_node<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        anchor_tree_node_id: u64,
        value: V
    ): u64 {
        let (last, next) = // Get virtual last and next fields for node.
            insert_list_node_get_last_next(avlq_ref_mut, anchor_tree_node_id);
        let list_node_id = // Assign fields, store inserted node ID.
            insert_list_node_assign_fields(avlq_ref_mut, last, next, value);
        // If inserting a new list tail that is not solo:
        if (anchor_tree_node_id != (NIL as u64)) {
            // Mutably borrow tree nodes table.
            let tree_nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
            // Mutably borrow list nodes table.
            let list_nodes_ref_mut = &mut avlq_ref_mut.list_nodes;
            let last_node_ref_mut = // Mutably borrow old tail.
                table_with_length::borrow_mut(list_nodes_ref_mut, last);
            last_node_ref_mut.next_msbs = // Reassign its next MSBs.
                ((list_node_id >> BITS_PER_BYTE) as u8);
            // Reassign its next LSBs to those of inserted list node.
            last_node_ref_mut.next_lsbs = ((list_node_id & HI_BYTE) as u8);
            // Mutably borrow anchor tree node.
            let anchor_node_ref_mut = table_with_length::borrow_mut(
                tree_nodes_ref_mut, anchor_tree_node_id);
            // Reassign bits for list tail node:
            anchor_node_ref_mut.bits = anchor_node_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_LIST_TAIL)) |
                // Mask in new bits.
                ((list_node_id as u128) << SHIFT_LIST_TAIL);
        };
        list_node_id // Return inserted list node ID.
    }

    /// Assign fields when inserting a list node.
    ///
    /// Inner function for `insert_list_node()`.
    ///
    /// If inactive list node stack is empty, allocate a new list node,
    /// otherwise pop one off the inactive stack.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref`: Immutable reference to AVL queue.
    /// * `last`: Virtual last field from
    ///   `insert_list_node_get_last_next()`.
    /// * `next`: Virtual next field from
    ///   `insert_list_node_get_last_next()`.
    /// * `value`: Insertion value.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of inserted list node.
    ///
    /// # Testing
    ///
    /// * `test_insert_list_node_assign_fields_allocate()`
    /// * `test_insert_list_node_assign_fields_stacked()`
    /// * `test_insert_too_many_list_nodes()`
    fun insert_list_node_assign_fields<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        last: u64,
        next: u64,
        value: V
    ): u64 {
        // Mutably borrow list nodes table.
        let list_nodes_ref_mut = &mut avlq_ref_mut.list_nodes;
        // Mutably borrow insertion values table.
        let values_ref_mut = &mut avlq_ref_mut.values;
        // Split last and next arguments into byte fields.
        let (last_msbs, last_lsbs, next_msbs, next_lsbs) = (
            ((last >> BITS_PER_BYTE) as u8), ((last & HI_BYTE) as u8),
            ((next >> BITS_PER_BYTE) as u8), ((next & HI_BYTE) as u8));
        // Get top of inactive list nodes stack.
        let list_node_id = (((avlq_ref_mut.bits >> SHIFT_LIST_STACK_TOP) &
                             (HI_NODE_ID as u128)) as u64);
        // If will need to allocate a new list node:
        if (list_node_id == (NIL as u64)) {
            // Get new 1-indexed list node ID.
            list_node_id = table_with_length::length(list_nodes_ref_mut) + 1;
            // Verify list nodes not over-allocated.
            verify_node_count(list_node_id);
            // Allocate a new list node with given fields.
            table_with_length::add(list_nodes_ref_mut, list_node_id, ListNode{
                last_msbs, last_lsbs, next_msbs, next_lsbs});
            // Allocate a new list node value option.
            table::add(values_ref_mut, list_node_id, option::some(value));
        } else { // If can pop inactive node off stack:
            // Mutably borrow inactive node at top of stack.
            let node_ref_mut = table_with_length::borrow_mut(
                list_nodes_ref_mut, list_node_id);
            let new_list_stack_top = // Get new list stack top node ID.
                ((node_ref_mut.next_msbs as u128) << BITS_PER_BYTE) |
                 (node_ref_mut.next_lsbs as u128);
            // Reassign bits for inactive list node stack top:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_LIST_STACK_TOP)) |
                // Mask in new bits.
                (new_list_stack_top << SHIFT_LIST_STACK_TOP);
            node_ref_mut.last_msbs = last_msbs; // Reassign last MSBs.
            node_ref_mut.last_lsbs = last_lsbs; // Reassign last LSBs.
            node_ref_mut.next_msbs = next_msbs; // Reassign next MSBs.
            node_ref_mut.next_lsbs = next_lsbs; // Reassign next LSBs.
            // Mutably borrow empty value option for node ID.
            let value_option_ref_mut =
                table::borrow_mut(values_ref_mut, list_node_id);
            // Fill the empty value option with the insertion value.
            option::fill(value_option_ref_mut, value);
        };
        list_node_id // Return list node ID.
    }

    /// Get virtual last and next fields when inserting a list node.
    ///
    /// Inner function for `insert_list_node()`.
    ///
    /// If inserted list node will be the only list node in a doubly
    /// linked list, a "solo list node", then it will have to indicate
    /// for next and last node IDs a new tree node, which will also have
    /// to be inserted via `insert_tree_node()`. Hence error checking
    /// for the number of allocated tree nodes is performed here first,
    /// and is not re-performed in `inserted_tree_node()` for the case
    /// of a solo list node.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref`: Immutable reference to AVL queue.
    /// * `anchor_tree_node_id`: Node ID of anchor tree node, `NIL` if
    ///   inserting a solo list node.
    ///
    /// # Returns
    ///
    /// * `u64`: Virtual last field of inserted list node.
    /// * `u64`: Virtual next field of inserted list node.
    ///
    /// # Testing
    ///
    /// * `test_insert_list_node_get_last_next_new_tail()`
    /// * `test_insert_list_node_get_last_next_solo_allocate()`
    /// * `test_insert_list_node_get_last_next_solo_stacked()`
    /// * `test_insert_too_many_tree_nodes()`.
    fun insert_list_node_get_last_next<V>(
        avlq_ref: &AVLqueue<V>,
        anchor_tree_node_id: u64,
    ): (
        u64,
        u64
    ) {
        // Declare bitmask for flagging a tree node.
        let is_tree_node = ((BIT_FLAG_TREE_NODE as u64) << SHIFT_NODE_TYPE);
        // Immutably borrow tree nodes table.
        let tree_nodes_ref = &avlq_ref.tree_nodes;
        let last; // Declare virtual last field for inserted list node.
        // If inserting a solo list node:
        if (anchor_tree_node_id == (NIL as u64)) {
            // Get top of inactive tree nodes stack.
            anchor_tree_node_id = (((avlq_ref.bits >> SHIFT_TREE_STACK_TOP) &
                                    (HI_NODE_ID as u128)) as u64);
            // If will need to allocate a new tree node:
            if (anchor_tree_node_id == (NIL as u64)) {
                anchor_tree_node_id = // Get new 1-indexed tree node ID.
                    table_with_length::length(tree_nodes_ref) + 1;
                // Verify tree nodes not over-allocated.
                verify_node_count(anchor_tree_node_id);
            };
            // Set virtual last field as flagged anchor tree node ID.
            last = anchor_tree_node_id | is_tree_node;
        } else { // If not inserting a solo list node:
            // Immutably borrow anchor tree node.
            let anchor_node_ref = table_with_length::borrow(
                tree_nodes_ref, anchor_tree_node_id);
            // Set virtual last field as anchor node list tail.
            last = (((anchor_node_ref.bits >> SHIFT_LIST_TAIL) &
                     (HI_NODE_ID as u128)) as u64);
        };
        // Return virtual last field per above, and virtual next field
        // as flagged anchor tree node ID.
        (last, (anchor_tree_node_id | is_tree_node))
    }

    /// Insert a tree node and return its node ID.
    ///
    /// If inactive tree node stack is empty, allocate a new tree node,
    /// otherwise pop one off the inactive stack.
    ///
    /// Should only be called when `insert_list_node()` inserts the
    /// sole list node in new AVL tree node, thus checking the number
    /// of allocated tree nodes in `insert_list_node_get_last_next()`.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `key`: Insertion key for inserted node.
    /// * `parent`: Node ID of parent to inserted node, `NIL` when
    ///   inserted node is to become root.
    /// * `solo_node_id`: Node ID of sole list node in tree node's
    ///   doubly linked list.
    /// * `new_leaf_side`: None if inserted node is root, `LEFT` if
    ///   inserted node is left child of its parent, and `RIGHT` if
    ///   inserted node is right child of its parent.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of inserted tree node.
    ///
    /// # Assumptions
    ///
    /// * Node is a leaf in the AVL tree and has a single list node in
    ///   its doubly linked list.
    /// * The number of allocated tree nodes has already been checked
    ///   via `insert_list_node_get_last_next()`.
    /// * All `u64` fields correspond to valid node IDs.
    ///
    /// # Testing
    ///
    /// * `test_insert_tree_node_empty()`.
    /// * `test_insert_tree_node_stacked()`.
    fun insert_tree_node<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        key: u64,
        parent: u64,
        solo_node_id: u64,
        new_leaf_side: Option<bool>
    ): u64 {
        // Pack field bits.
        let bits = ((key          as u128) << SHIFT_INSERTION_KEY) |
                   ((parent       as u128) << SHIFT_PARENT) |
                   ((solo_node_id as u128) << SHIFT_LIST_HEAD) |
                   ((solo_node_id as u128) << SHIFT_LIST_TAIL);
        // Get top of inactive tree nodes stack.
        let tree_node_id = (((avlq_ref_mut.bits >> SHIFT_TREE_STACK_TOP) &
                             (HI_NODE_ID as u128)) as u64);
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        // If need to allocate new tree node:
        if (tree_node_id == (NIL as u64)) {
            // Get new 1-indexed tree node ID.
            tree_node_id = table_with_length::length(tree_nodes_ref_mut) + 1;
            table_with_length::add( // Allocate new packed tree node.
                tree_nodes_ref_mut, tree_node_id, TreeNode{bits})
        } else { // If can pop inactive node off stack:
            // Mutably borrow inactive node at top of stack.
            let node_ref_mut = table_with_length::borrow_mut(
                tree_nodes_ref_mut, tree_node_id);
            // Get new inactive tree nodes stack top node ID.
            let new_tree_stack_top = node_ref_mut.bits & (HI_NODE_ID as u128);
            // Reassign bits for inactive tree node stack top:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_TREE_STACK_TOP)) |
                // Mask in new bits.
                (new_tree_stack_top << SHIFT_TREE_STACK_TOP);
            node_ref_mut.bits = bits; // Reassign inserted node bits.
        };
        insert_tree_node_update_parent_edge( // Update parent edge.
            avlq_ref_mut, tree_node_id, parent, new_leaf_side);
        tree_node_id // Return inserted tree node ID.
    }

    /// Update the parent edge for a tree node just inserted.
    ///
    /// Inner function for `insert_tree_node()`.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `tree_node_id`: Node ID of tree node just inserted in
    ///   `insert_tree_node()`.
    /// * `parent`: Node ID of parent to inserted node, `NIL` when
    ///   inserted node is root.
    /// * `new_leaf_side`: None if inserted node is root, `LEFT` if
    ///   inserted node is left child of its parent, and `RIGHT` if
    ///   inserted node is right child of its parent.
    ///
    /// # Testing
    ///
    /// * `test_insert_tree_node_update_parent_edge_left()`
    /// * `test_insert_tree_node_update_parent_edge_right()`
    /// * `test_insert_tree_node_update_parent_edge_root()`
    fun insert_tree_node_update_parent_edge<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        tree_node_id: u64,
        parent: u64,
        new_leaf_side: Option<bool>
    ) {
        if (option::is_none(&new_leaf_side)) { // If inserting root:
            // Set root LSBs.
            avlq_ref_mut.root_lsbs = ((tree_node_id & HI_BYTE) as u8);
            // Reassign bits for root MSBs:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID >> BITS_PER_BYTE) as u128)) |
                // Mask in new bits.
                ((tree_node_id as u128) >> BITS_PER_BYTE)
        } else { // If inserting child to existing node:
            // Mutably borrow tree nodes table.
            let tree_nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
            // Mutably borrow parent.
            let parent_ref_mut = table_with_length::borrow_mut(
                tree_nodes_ref_mut, parent);
            // Determine if inserting left child.
            let left_child = *option::borrow(&new_leaf_side) == LEFT;
            // Get child node ID field shift amounts for given side;
            let child_shift = if (left_child) SHIFT_CHILD_LEFT else
                SHIFT_CHILD_RIGHT;
            // Reassign bits for child field on given side.
            parent_ref_mut.bits = parent_ref_mut.bits &
                // Clear out all bits via mask unset at relevant bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << child_shift)) |
                // Mask in new bits.
                ((tree_node_id as u128) << child_shift);
        };
    }

    /// Retrace ancestor heights after tree node insertion or removal.
    ///
    /// Should only be called by `insert()` or `remove()`.
    ///
    /// When a tree leaf node is inserted or removed, the parent-leaf
    /// edge is first updated with corresponding node IDs for both
    /// parent and optional leaf. Then the corresponding change in
    /// height at the parent node, on the affected side, must be
    /// updated, along with any affected heights up to the root. If the
    /// process results in an imbalance of more than one between the
    /// left height and right height of a node in the ancestor chain,
    /// the corresponding subtree must be rebalanced.
    ///
    /// Parent-leaf edge updates are handled in `insert()` and
    /// `remove()`, while the height retracing process is handled here.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `node_id` : Node ID of tree node that just had a child
    ///   inserted or removed, resulting in a modification to its height
    ///   on the side that the insertion or removal took place.
    /// * `operation`: `INCREMENT` if height on given side increases as
    ///   a result, `DECREMENT` if it decreases.
    /// * `side`: `LEFT` or `RIGHT`, the side on which the child was
    ///   inserted or deleted.
    ///
    /// # Testing
    ///
    /// Tests are designed to evaluate both true and false outcomes for
    /// all logical branches, with each relevant test covering multiple
    /// conditional branches, optionally via a retrace back to the root.
    ///
    /// See `test_rotate_right_1()` and `test_rotate_left_2()` for more
    /// information on their corresponding reference diagrams.
    ///
    /// `if (height_left != height_right)`
    ///
    /// | Exercises `true`       | Excercises `false`             |
    /// |------------------------|--------------------------------|
    /// | `test_rotate_left_2()` | `test_retrace_insert_remove()` |
    ///
    /// `if (height_left > height_right)`
    ///
    /// | Exercises `true`        | Excercises `false`     |
    /// |-------------------------|------------------------|
    /// | `test_rotate_right_1()` | `test_rotate_left_2()` |
    ///
    /// `if (imbalance > 1)`
    ///
    /// | Exercises `true`       | Excercises `false`             |
    /// |------------------------|--------------------------------|
    /// | `test_rotate_left_2()` | `test_retrace_insert_remove()` |
    ///
    /// `if (left_heavy)`
    ///
    /// | Exercises `true`        | Excercises `false`     |
    /// |-------------------------|------------------------|
    /// | `test_rotate_right_1()` | `test_rotate_left_2()` |
    ///
    /// `if (parent == (NIL as u64))`
    ///
    /// | Exercises `true`        | Excercises `false`     |
    /// |-------------------------|------------------------|
    /// | `test_rotate_right_1()` | `test_rotate_left_2()` |
    ///
    /// `if (new_subtree_root != (NIL as u64))`
    ///
    /// | Exercises `true`        | Excercises `false`             |
    /// |-------------------------|--------------------------------|
    /// | `test_rotate_right_1()` | `test_retrace_insert_remove()` |
    ///
    /// `if (delta == 0)`
    ///
    /// | Exercises `true`       | Excercises `false`             |
    /// |------------------------|--------------------------------|
    /// | `test_rotate_left_2()` | `test_retrace_insert_remove()` |
    ///
    /// ## Reference diagram
    ///
    /// For `test_retrace_insert_remove()`, insert node d and retrace
    /// from node c, then remove node d and retrace from c again.
    ///
    /// Pre-insertion:
    ///
    /// >       4
    /// >      / \
    /// >     3   5
    ///
    /// Pre-removal:
    ///
    /// >       node b -> 4
    /// >                / \
    /// >     node a -> 3   5 <- node c
    /// >                    \
    /// >                     6 <- node d
    ///
    /// Post-removal:
    ///
    /// >       4
    /// >      / \
    /// >     3   5
    fun retrace<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_id: u64,
        operation: bool,
        side: bool
    ) {
        let delta = 1; // Mark height change of one for first iteration.
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        // Mutably borrow node under consideration.
        let node_ref_mut =
            table_with_length::borrow_mut(nodes_ref_mut, node_id);
        loop {
            // Get parent field of node under review.
            let parent = (((node_ref_mut.bits >> SHIFT_PARENT) &
                           (HI_NODE_ID as u128)) as u64);
            let (height_left, height_right, height, height_old) =
                retrace_update_heights(node_ref_mut, side, operation, delta);
            // Flag no rebalancing via null new subtree root.
            let new_subtree_root = (NIL as u64);
            if (height_left != height_right) { // If node not balanced:
                // Determine if node is left-heavy, and calculate the
                // imbalance of the node (the difference in height
                // between node's two subtrees).
                let (left_heavy, imbalance) = if (height_left > height_right)
                    (true, height_left - height_right) else
                    (false, height_right - height_left);
                if (imbalance > 1) { // If imbalance greater than 1:
                    // Get shift amount for child on heavy side.
                    let child_shift = if (left_heavy) SHIFT_CHILD_LEFT else
                        SHIFT_CHILD_RIGHT;
                    // Get child ID from node bits.
                    let child_id = (((node_ref_mut.bits >> child_shift) &
                                     (HI_NODE_ID as u128)) as u64);
                    // Rebalance, storing node ID of new subtree root
                    // and new subtree height.
                    (new_subtree_root, height) = retrace_rebalance(
                        avlq_ref_mut, node_id, child_id, left_heavy);
                };
            }; // Corresponding subtree has been optionally rebalanced.
            if (parent == (NIL as u64)) { // If just retraced root:
                // If just rebalanced at root:
                if (new_subtree_root != (NIL as u64)) {
                    avlq_ref_mut.root_lsbs = // Set AVL queue root LSBs.
                        (new_subtree_root & HI_BYTE as u8);
                    // Reassign bits for root MSBs:
                    avlq_ref_mut.bits = avlq_ref_mut.bits &
                        // Clear out field via mask unset at field bits.
                        (HI_128 ^ ((HI_NODE_ID as u128) >> BITS_PER_BYTE)) |
                        // Mask in new bits.
                        ((new_subtree_root as u128) >> BITS_PER_BYTE);
                }; // AVL queue root now current for actual root.
                return // Stop looping.
            } else { // If just retraced node not at root:
                // Prepare to optionally iterate again.
                (node_ref_mut, operation, side, delta) =
                    retrace_prep_iterate(avlq_ref_mut, parent, node_id,
                                         new_subtree_root, height, height_old);
                // Return if current iteration did not result in height
                // change for corresponding subtree.
                if (delta == 0) return;
                // Store parent ID as node ID for next iteration.
                node_id = parent;
            };
        }
    }

    /// Prepare for an optional next retrace iteration.
    ///
    /// Inner function for `retrace()`, should only be called if just
    /// retraced below the root of the AVL queue.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `parent_id`: Node ID of next ancestor in retrace chain.
    /// * `node_id`: Node ID at root of subtree just retraced, before
    ///   any optional rebalancing took place.
    /// * `new_subtree_root`: Node ID of new subtree root for when
    ///   rebalancing took place, `NIL` if no rebalancing.
    /// * `height`: Height of subtree after retrace.
    /// * `height_old`: Height of subtree before retrace.
    ///
    /// # Returns
    ///
    /// * `&mut TreeNode`: Mutable reference to next ancestor.
    /// * `bool`: `INCREMENT` or `DECREMENT`, the change in height for
    ///   the subtree just retraced. Evalutes to `DECREMENT` when
    ///   height does not change.
    /// * `bool`: `LEFT` or `RIGHT`, the side on which the retraced
    ///   subtree was a child to the next ancestor.
    /// * `u8`: Change in height of subtree due to retrace, evaluates to
    ///   0 when height does not change.
    ///
    /// # Testing
    ///
    /// * `test_retrace_prep_iterate_1()`.
    /// * `test_retrace_prep_iterate_2()`.
    /// * `test_retrace_prep_iterate_3()`.
    fun retrace_prep_iterate<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        parent_id: u64,
        node_id: u64,
        new_subtree_root: u64,
        height: u8,
        height_old: u8,
    ): (
        &mut TreeNode,
        bool,
        bool,
        u8
    ) {
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        // Mutably borrow parent to subtree just retraced.
        let node_ref_mut =
            table_with_length::borrow_mut(nodes_ref_mut, parent_id);
        // Get parent's left child.
        let left_child = ((node_ref_mut.bits >> SHIFT_CHILD_LEFT) &
                          (HI_NODE_ID as u128) as u64);
        // Flag side on which retracing operation took place.
        let side = if (left_child == node_id) LEFT else RIGHT;
        // If subtree rebalanced:
        if (new_subtree_root != (NIL as u64)) {
            // Get corresponding child field shift amount.
            let child_shift = if (side == LEFT)
                SHIFT_CHILD_LEFT else SHIFT_CHILD_RIGHT;
            // Reassign bits for new child field.
            node_ref_mut.bits = node_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << child_shift)) |
                // Mask in new bits.
                ((new_subtree_root as u128) << child_shift)
        }; // Parent-child edge updated.
        // Determine retrace operation type and height delta.
        let (operation, delta) = if (height > height_old)
            (INCREMENT, height - height_old) else
            (DECREMENT, height_old - height);
        // Return mutable reference to parent node, operation performed,
        // side of operation, and corresponding change in height.
        (node_ref_mut, operation, side, delta)
    }

    /// Rebalance a subtree, returning new root and height.
    ///
    /// Inner function for `retrace()`.
    ///
    /// Updates state for nodes in subtree, but not for potential parent
    /// to subtree.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `node_id_x`: Node ID of subtree root.
    /// * `node_id_z`: Node ID of child to subtree root, on subtree
    ///   root's heavy side.
    /// * `node_x_left_heavy`: `true` if node x is left-heavy.
    ///
    /// # Returns
    ///
    /// * `u64`: Tree node ID of new subtree root after rotation.
    /// * `u8`: Height of subtree after rotation.
    ///
    /// # Node x status
    ///
    /// Node x can be either left-heavy or right heavy. In either case,
    /// consider that node z has left child and right child fields.
    ///
    /// ## Node x left-heavy
    ///
    /// >             n_x
    /// >            /
    /// >          n_z
    /// >         /   \
    /// >     z_c_l   z_c_r
    ///
    /// ## Node x right-heavy
    ///
    /// >       n_x
    /// >          \
    /// >          n_z
    /// >         /   \
    /// >     z_c_l   z_c_r
    ///
    /// # Testing
    ///
    /// * `test_rotate_left_1()`
    /// * `test_rotate_left_2()`
    /// * `test_rotate_left_right_1()`
    /// * `test_rotate_left_right_2()`
    /// * `test_rotate_right_1()`
    /// * `test_rotate_right_2()`
    /// * `test_rotate_right_left_1()`
    /// * `test_rotate_right_left_2()`
    fun retrace_rebalance<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_x_id: u64,
        node_z_id: u64,
        node_x_left_heavy: bool,
    ): (
        u64,
        u8
    ) {
        let node_z_ref = // Immutably borrow node z.
            table_with_length::borrow(&avlq_ref_mut.tree_nodes, node_z_id);
        let bits = node_z_ref.bits; // Get node z bits.
        // Get node z's left height, right height, and child fields.
        let (node_z_height_left, node_z_height_right,
             node_z_child_left , node_z_child_right  ) =
            (((bits >> SHIFT_HEIGHT_LEFT ) & (HI_HEIGHT  as u128) as u8),
             ((bits >> SHIFT_HEIGHT_RIGHT) & (HI_HEIGHT  as u128) as u8),
             ((bits >> SHIFT_CHILD_LEFT  ) & (HI_NODE_ID as u128) as u64),
             ((bits >> SHIFT_CHILD_RIGHT ) & (HI_NODE_ID as u128) as u64));
        // Return result of rotation. If node x is left-heavy:
        return (if (node_x_left_heavy)
            // If node z is right-heavy, rotate left-right
            (if (node_z_height_right > node_z_height_left)
                retrace_rebalance_rotate_left_right(
                    avlq_ref_mut, node_x_id, node_z_id, node_z_child_right,
                    node_z_height_left)
                // Otherwise node z is not right-heavy so rotate right.
                else retrace_rebalance_rotate_right(
                    avlq_ref_mut, node_x_id, node_z_id, node_z_child_right,
                    node_z_height_right))
            else // If node x is right-heavy:
            // If node z is left-heavy, rotate right-left
            (if (node_z_height_left > node_z_height_right)
                retrace_rebalance_rotate_right_left(
                    avlq_ref_mut, node_x_id, node_z_id, node_z_child_left,
                    node_z_height_right)
                // Otherwise node z is not left-heavy so rotate left.
                else retrace_rebalance_rotate_left(
                    avlq_ref_mut, node_x_id, node_z_id, node_z_child_left,
                    node_z_height_left)))
    }

    /// Rotate left during rebalance.
    ///
    /// Inner function for `retrace_rebalance()`.
    ///
    /// Updates state for nodes in subtree, but not for potential parent
    /// to subtree.
    ///
    /// Here, subtree root node x is right-heavy, with right child
    /// node z that is not left-heavy. Node x has an optional tree 1
    /// as its left child subtree, and node z has optional trees 2 and
    /// 3 as its left and right child subtrees, respectively.
    ///
    /// Pre-rotation:
    ///
    /// >        n_x
    /// >       /   \
    /// >     t_1   n_z
    /// >          /   \
    /// >        t_2   t_3
    ///
    /// Post-rotation:
    ///
    /// >           n_z
    /// >          /   \
    /// >        n_x   t_3
    /// >       /   \
    /// >     t_1   t_2
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `node_x_id`: Node ID of subtree root pre-rotation.
    /// * `node_z_id`: Node ID of subtree root post-rotation.
    /// * `tree_2_id`: Node z's left child field.
    /// * `node_z_height_left`: Node z's left height.
    ///
    /// # Returns
    ///
    /// * `u64`: Node z's ID.
    /// * `u8`: The height of the subtree rooted at node z,
    ///   post-rotation.
    ///
    /// # Reference rotations
    ///
    /// ## Case 1
    ///
    /// * Tree 2 null.
    /// * Node x left height greater than or equal to right height
    ///   post-rotation.
    /// * Node z right height greater than or equal to left height
    ///   post-rotation.
    ///
    /// Pre-rotation:
    ///
    /// >     4 <- node x
    /// >      \
    /// >       6 <- node z
    /// >        \
    /// >         8 <- tree 3
    ///
    /// Post-rotation:
    ///
    /// >                 6 <- node z
    /// >                / \
    /// >     node x -> 4   8 <- tree 3
    ///
    /// ## Case 2
    ///
    /// * Tree 2 not null.
    /// * Node x left height not greater than or equal to right height
    ///   post-rotation.
    /// * Node z right height not greater than or equal to left height
    ///   post-rotation.
    /// * Simulates removing node d, then retracing from node x.
    ///
    /// Pre-removal:
    ///
    /// >                   3 <- node a
    /// >                  / \
    /// >       node b -> 2   5
    /// >                /   / \
    /// >     node c -> 1   4   7
    /// >            node d ^  / \
    /// >                     6   8
    ///
    /// Pre-rotation:
    ///
    /// >             3
    /// >            / \
    /// >           2   5 <- node x
    /// >          /     \
    /// >         1       7 <- node z
    /// >                / \
    /// >     tree 2 -> 6   8 <- tree 3
    ///
    /// Post-rotation:
    ///
    /// >         3
    /// >        / \
    /// >       2   7 <- node z
    /// >      /   / \
    /// >     1   5   8 <- tree 3
    /// >          \
    /// >           6 <- tree 2
    ///
    /// # Testing
    ///
    /// * `test_rotate_left_1()`
    /// * `test_rotate_left_2()`
    fun retrace_rebalance_rotate_left<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_x_id: u64,
        node_z_id: u64,
        tree_2_id: u64,
        node_z_height_left: u8
    ): (
        u64,
        u8
    ) {
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        if (tree_2_id != (NIL as u64)) { // If tree 2 is not empty:
            let tree_2_ref_mut = // Mutably borrow tree 2 root.
                table_with_length::borrow_mut(nodes_ref_mut, tree_2_id);
            // Reassign bits for new parent field:
            tree_2_ref_mut.bits = tree_2_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_PARENT)) |
                // Mask in new bits.
                ((node_x_id as u128) << SHIFT_PARENT);
        };
        let node_x_ref_mut =  // Mutably borrow node x.
            table_with_length::borrow_mut(nodes_ref_mut, node_x_id);
        let node_x_height_left = (((node_x_ref_mut.bits >> SHIFT_HEIGHT_LEFT) &
            (HI_HEIGHT as u128)) as u8); // Get node x left height.
        // Node x's right height is from transferred tree 2.
        let node_x_height_right = node_z_height_left;
        let node_x_parent = (((node_x_ref_mut.bits >> SHIFT_PARENT) &
            (HI_NODE_ID as u128)) as u64); // Get node x parent field.
        // Reassign bits for right child, right height, and parent:
        node_x_ref_mut.bits = node_x_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_RIGHT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_RIGHT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((tree_2_id           as u128) << SHIFT_CHILD_RIGHT) |
            ((node_x_height_right as u128) << SHIFT_HEIGHT_RIGHT) |
            ((node_z_id           as u128) << SHIFT_PARENT);
        // Determine height of tree rooted at x.
        let node_x_height = if (node_x_height_left >= node_x_height_right)
            node_x_height_left else node_x_height_right;
        // Get node z left height.
        let node_z_height_left = node_x_height + 1;
        let node_z_ref_mut =  // Mutably borrow node z.
            table_with_length::borrow_mut(nodes_ref_mut, node_z_id);
        // Reassign bits for left child, left height, and parent:
        node_z_ref_mut.bits = node_z_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_LEFT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_LEFT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((node_x_id          as u128) << SHIFT_CHILD_LEFT) |
            ((node_z_height_left as u128) << SHIFT_HEIGHT_LEFT) |
            ((node_x_parent      as u128) << SHIFT_PARENT);
        let node_z_height_right = (((node_z_ref_mut.bits >> SHIFT_HEIGHT_RIGHT)
            & (HI_HEIGHT as u128)) as u8); // Get node z right height.
        // Determine height of tree rooted at z.
        let node_z_height = if (node_z_height_right >= node_z_height_left)
            node_z_height_right else node_z_height_left;
        (node_z_id, node_z_height) // Return new subtree root, height.
    }

    /// Rotate left-right during rebalance.
    ///
    /// Inner function for `retrace_rebalance()`.
    ///
    /// Updates state for nodes in subtree, but not for potential parent
    /// to subtree.
    ///
    /// Here, subtree root node x is left-heavy, with left child node
    /// z that is right-heavy. Node z has as its right child node y.
    ///
    /// Node z has an optional tree 1 as its left child subtree, node
    /// y has optional trees 2 and 3 as its left and right child
    /// subtrees, respectively, and node x has an optional tree 4 as its
    /// right child subtree.
    ///
    /// Double rotations result in a subtree root with a balance factor
    /// of zero, such that node y is has the same left and right height
    /// post-rotation.
    ///
    /// Pre-rotation:
    ///
    /// >           n_x
    /// >          /   \
    /// >        n_z   t_4
    /// >       /   \
    /// >     t_1   n_y
    /// >          /   \
    /// >        t_2   t_3
    ///
    /// Post-rotation:
    ///
    /// >              n_y
    /// >          ___/   \___
    /// >        n_z         n_x
    /// >       /   \       /   \
    /// >     t_1   t_2   t_3   t_4
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `node_x_id`: Node ID of subtree root pre-rotation.
    /// * `node_z_id`: Node ID of subtree left child pre-rotation.
    /// * `node_y_id`: Node ID of subtree root post-rotation.
    /// * `node_z_height_left`: Node z's left height pre-rotation.
    ///
    /// # Procedure
    ///
    /// * Inspect node y's fields.
    /// * Optionally update tree 2's parent field.
    /// * Optionally update tree 3's parent field.
    /// * Update node x's left child and parent fields.
    /// * Update node z's right child and parent fields.
    /// * Update node y's children and parent fields.
    ///
    /// # Reference rotations
    ///
    /// ## Case 1
    ///
    /// * Tree 2 null.
    /// * Tree 3 not null.
    /// * Node z right height not greater than or equal to left height
    ///   post-rotation.
    ///
    /// Pre-rotation:
    ///
    /// >                   8 <- node x
    /// >                  / \
    /// >       node z -> 2   9 <- tree 4
    /// >                / \
    /// >     tree 1 -> 1   6 <- node y
    /// >                    \
    /// >                     7 <- tree 3
    ///
    /// Post-rotation:
    ///
    /// >                   6 <- node y
    /// >                  / \
    /// >       node z -> 2   8 <- node x
    /// >                /   / \
    /// >     tree 1 -> 1   7   9 <- tree 4
    /// >                   ^ tree 3
    ///
    /// ## Case 2
    ///
    /// * Tree 2 not null.
    /// * Tree 3 null.
    /// * Node z right height greater than or equal to left height
    ///   post-rotation.
    ///
    /// Pre-rotation:
    ///
    /// >                   8 <- node x
    /// >                  / \
    /// >       node z -> 2   9 <- tree 4
    /// >                / \
    /// >     tree 1 -> 1   6 <- node y
    /// >                  /
    /// >       tree 2 -> 5
    ///
    /// Post-rotation:
    ///
    /// >                   6 <- node y
    /// >                  / \
    /// >       node z -> 2   8 <- node x
    /// >                / \   \
    /// >     tree 1 -> 1   5   9 <- tree 4
    /// >                   ^ tree 2
    ///
    /// # Testing
    ///
    /// * `test_rotate_left_right_1()`
    /// * `test_rotate_left_right_2()`
    fun retrace_rebalance_rotate_left_right<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_x_id: u64,
        node_z_id: u64,
        node_y_id: u64,
        node_z_height_left: u8
    ): (
        u64,
        u8
    ) {
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        // Immutably borrow node y.
        let node_y_ref = table_with_length::borrow(nodes_ref_mut, node_y_id);
        let y_bits = node_y_ref.bits; // Get node y bits.
        // Get node y's left and right height, and tree 2 and 3 IDs.
        let (node_y_height_left, node_y_height_right, tree_2_id, tree_3_id) =
            ((((y_bits >> SHIFT_HEIGHT_LEFT ) & (HI_HEIGHT  as u128)) as u8),
             (((y_bits >> SHIFT_HEIGHT_RIGHT) & (HI_HEIGHT  as u128)) as u8),
             (((y_bits >> SHIFT_CHILD_LEFT  ) & (HI_NODE_ID as u128)) as u64),
             (((y_bits >> SHIFT_CHILD_RIGHT ) & (HI_NODE_ID as u128)) as u64));
        if (tree_2_id != (NIL as u64)) { // If tree 2 not null:
            let tree_2_ref_mut = // Mutably borrow tree 2 root.
                table_with_length::borrow_mut(nodes_ref_mut, tree_2_id);
            // Reassign bits for new parent field:
            tree_2_ref_mut.bits = tree_2_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_PARENT)) |
                // Mask in new bits.
                ((node_z_id as u128) << SHIFT_PARENT);
        };
        if (tree_3_id != (NIL as u64)) { // If tree 3 not null:
            let tree_3_ref_mut = // Mutably borrow tree 3 root.
                table_with_length::borrow_mut(nodes_ref_mut, tree_3_id);
            // Reassign bits for new parent field:
            tree_3_ref_mut.bits = tree_3_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_PARENT)) |
                // Mask in new bits.
                ((node_x_id as u128) << SHIFT_PARENT);
        };
        let node_x_ref_mut =  // Mutably borrow node x.
            table_with_length::borrow_mut(nodes_ref_mut, node_x_id);
        // Node x's left height is from transferred tree 3.
        let node_x_height_left = node_y_height_right;
        let node_x_parent = (((node_x_ref_mut.bits >> SHIFT_PARENT) &
            (HI_NODE_ID as u128)) as u64); // Store node x parent field.
        // Reassign bits for left child, left height, and parent:
        node_x_ref_mut.bits = node_x_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_LEFT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_LEFT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((tree_3_id          as u128) << SHIFT_CHILD_LEFT) |
            ((node_x_height_left as u128) << SHIFT_HEIGHT_LEFT) |
            ((node_y_id          as u128) << SHIFT_PARENT);
        let node_z_ref_mut =  // Mutably borrow node z.
            table_with_length::borrow_mut(nodes_ref_mut, node_z_id);
        // Node z's right height is from transferred tree 2.
        let node_z_height_right = node_y_height_left;
        // Reassign bits for right child, right height, and parent:
        node_z_ref_mut.bits = node_z_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_RIGHT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_RIGHT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((tree_2_id           as u128) << SHIFT_CHILD_RIGHT) |
            ((node_z_height_right as u128) << SHIFT_HEIGHT_RIGHT) |
            ((node_y_id           as u128) << SHIFT_PARENT);
        // Determine height of tree rooted at z.
        let node_z_height = if (node_z_height_right >= node_z_height_left)
            node_z_height_right else node_z_height_left;
        // Get node y's post-rotation height (same on left and right).
        let node_y_height = node_z_height + 1;
        let node_y_ref_mut = // Mutably borrow node y.
            table_with_length::borrow_mut(nodes_ref_mut, node_y_id);
        // Reassign bits for both child edges, and parent.
        node_y_ref_mut.bits = node_y_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_LEFT) |
                       ((HI_NODE_ID as u128) << SHIFT_CHILD_RIGHT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_LEFT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_RIGHT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((node_z_id     as u128) << SHIFT_CHILD_LEFT) |
            ((node_x_id     as u128) << SHIFT_CHILD_RIGHT) |
            ((node_y_height as u128) << SHIFT_HEIGHT_LEFT) |
            ((node_y_height as u128) << SHIFT_HEIGHT_RIGHT) |
            ((node_x_parent as u128) << SHIFT_PARENT);
        (node_y_id, node_y_height) // Return new subtree root, height.
    }

    /// Rotate right during rebalance.
    ///
    /// Inner function for `retrace_rebalance()`.
    ///
    /// Updates state for nodes in subtree, but not for potential parent
    /// to subtree.
    ///
    /// Here, subtree root node x is left-heavy, with left child
    /// node z that is not right-heavy. Node x has an optional tree 3
    /// as its right child subtree, and node z has optional trees 1 and
    /// 2 as its left and right child subtrees, respectively.
    ///
    /// Pre-rotation:
    ///
    /// >           n_x
    /// >          /   \
    /// >        n_z   t_3
    /// >       /   \
    /// >     t_1   t_2
    ///
    /// Post-rotation:
    ///
    /// >        n_z
    /// >       /   \
    /// >     t_1   n_x
    /// >          /   \
    /// >        t_2   t_3
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `node_x_id`: Node ID of subtree root pre-rotation.
    /// * `node_z_id`: Node ID of subtree root post-rotation.
    /// * `tree_2_id`: Node z's right child field.
    /// * `node_z_height_right`: Node z's right height.
    ///
    /// # Returns
    ///
    /// * `u64`: Node z's ID.
    /// * `u8`: The height of the subtree rooted at node z,
    ///   post-rotation.
    ///
    /// # Reference rotations
    ///
    /// ## Case 1
    ///
    /// * Tree 2 null.
    /// * Node x right height greater than or equal to left height
    ///   post-rotation.
    /// * Node z left height greater than or equal to right height
    ///   post-rotation.
    /// * Simulates inserting tree 1, then retracing from node z.
    ///
    /// Pre-insertion:
    ///
    /// >       8
    /// >      /
    /// >     6
    ///
    /// Pre-rotation:
    ///
    /// >         8 <- node x
    /// >        /
    /// >       6 <- node z
    /// >      /
    /// >     4 <- tree 1
    ///
    /// Post-rotation:
    ///
    /// >                 6 <- node z
    /// >                / \
    /// >     tree 1 -> 4   8 <- node x
    ///
    /// ## Case 2
    ///
    /// * Tree 2 not null.
    /// * Node x right height not greater than or equal to left height
    ///   post-rotation.
    /// * Node z left height not greater than or equal to right height
    ///   post-rotation.
    ///
    /// Pre-rotation:
    ///
    /// >                   7 <- node x
    /// >                  /
    /// >                 4 <- node z
    /// >                / \
    /// >     tree 1 -> 3   5 <- tree 2
    ///
    /// Post-rotation:
    ///
    /// >                 4 <- node z
    /// >                / \
    /// >     tree 1 -> 3   7 <- node x
    /// >                  /
    /// >                 5 <- tree 2
    ///
    /// # Testing
    ///
    /// * `test_rotate_right_1()`
    /// * `test_rotate_right_2()`
    fun retrace_rebalance_rotate_right<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_x_id: u64,
        node_z_id: u64,
        tree_2_id: u64,
        node_z_height_right: u8
    ): (
        u64,
        u8
    ) {
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        if (tree_2_id != (NIL as u64)) { // If tree 2 is not empty:
            let tree_2_ref_mut = // Mutably borrow tree 2 root.
                table_with_length::borrow_mut(nodes_ref_mut, tree_2_id);
            // Reassign bits for new parent field:
            tree_2_ref_mut.bits = tree_2_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_PARENT)) |
                // Mask in new bits.
                ((node_x_id as u128) << SHIFT_PARENT);
        };
        let node_x_ref_mut =  // Mutably borrow node x.
            table_with_length::borrow_mut(nodes_ref_mut, node_x_id);
        let node_x_height_right = (((node_x_ref_mut.bits >> SHIFT_HEIGHT_RIGHT)
            & (HI_HEIGHT as u128)) as u8); // Get node x right height.
        // Node x's left height is from transferred tree 2.
        let node_x_height_left = node_z_height_right;
        let node_x_parent = (((node_x_ref_mut.bits >> SHIFT_PARENT) &
            (HI_NODE_ID as u128)) as u64); // Get node x parent field.
        // Reassign bits for left child, left height, and parent:
        node_x_ref_mut.bits = node_x_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_LEFT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_LEFT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((tree_2_id          as u128) << SHIFT_CHILD_LEFT) |
            ((node_x_height_left as u128) << SHIFT_HEIGHT_LEFT) |
            ((node_z_id          as u128) << SHIFT_PARENT);
        // Determine height of tree rooted at x.
        let node_x_height = if (node_x_height_right >= node_x_height_left)
            node_x_height_right else node_x_height_left;
        // Get node z right height.
        let node_z_height_right = node_x_height + 1;
        let node_z_ref_mut =  // Mutably borrow node z.
            table_with_length::borrow_mut(nodes_ref_mut, node_z_id);
        // Reassign bits for right child, right height, and parent:
        node_z_ref_mut.bits = node_z_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_RIGHT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_RIGHT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((node_x_id           as u128) << SHIFT_CHILD_RIGHT) |
            ((node_z_height_right as u128) << SHIFT_HEIGHT_RIGHT) |
            ((node_x_parent       as u128) << SHIFT_PARENT);
        let node_z_height_left = (((node_z_ref_mut.bits >> SHIFT_HEIGHT_LEFT) &
            (HI_HEIGHT as u128)) as u8); // Get node z left height.
        // Determine height of tree rooted at z.
        let node_z_height = if (node_z_height_left >= node_z_height_right)
            node_z_height_left else node_z_height_right;
        (node_z_id, node_z_height) // Return new subtree root, height.
    }

    /// Rotate right-left during rebalance.
    ///
    /// Inner function for `retrace_rebalance()`.
    ///
    /// Updates state for nodes in subtree, but not for potential parent
    /// to subtree.
    ///
    /// Here, subtree root node x is right-heavy, with right child node
    /// z that is left-heavy. Node z has as its left child node y.
    ///
    /// Node x has an optional tree 1 as its left child subtree, node
    /// y has optional trees 2 and 3 as its left and right child
    /// subtrees, respectively, and node z has an optional tree 4 as its
    /// right child subtree.
    ///
    /// Double rotations result in a subtree root with a balance factor
    /// of zero, such that node y is has the same left and right height
    /// post-rotation.
    ///
    /// Pre-rotation:
    ///
    /// >        n_x
    /// >       /   \
    /// >     t_1   n_z
    /// >          /   \
    /// >        n_y   t_4
    /// >       /   \
    /// >     t_2   t_3
    ///
    /// Post-rotation:
    ///
    /// >              n_y
    /// >          ___/   \___
    /// >        n_x         n_z
    /// >       /   \       /   \
    /// >     t_1   t_2   t_3   t_4
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `node_x_id`: Node ID of subtree root pre-rotation.
    /// * `node_z_id`: Node ID of subtree right child pre-rotation.
    /// * `node_y_id`: Node ID of subtree root post-rotation.
    /// * `node_z_height_right`: Node z's right height pre-rotation.
    ///
    /// # Procedure
    ///
    /// * Inspect node y's fields.
    /// * Optionally update tree 2's parent field.
    /// * Optionally update tree 3's parent field.
    /// * Update node x's right child and parent fields.
    /// * Update node z's left child and parent fields.
    /// * Update node y's children and parent fields.
    ///
    /// # Reference rotations
    ///
    /// ## Case 1
    ///
    /// * Tree 2 not null.
    /// * Tree 3 null.
    /// * Node z left height not greater than or equal to right height
    ///   post-rotation.
    ///
    /// Pre-rotation:
    ///
    /// >                 2 <- node x
    /// >                / \
    /// >     tree 1 -> 1   8 <- node z
    /// >                  / \
    /// >       node y -> 4   9 <- tree 4
    /// >                /
    /// >               3 <- tree 2
    ///
    /// Post-rotation:
    ///
    /// >                   4 <- node y
    /// >                  / \
    /// >       node x -> 2   8 <- node z
    /// >                / \   \
    /// >     tree 1 -> 1   3   9 <- tree 4
    /// >                   ^ tree 2
    ///
    /// ## Case 2
    ///
    /// * Tree 2 null.
    /// * Tree 3 not null.
    /// * Node z left height greater than or equal to right height
    ///   post-rotation.
    ///
    /// Pre-rotation:
    ///
    /// >                 2 <- node x
    /// >                / \
    /// >     tree 1 -> 1   8 <- node z
    /// >                  / \
    /// >       node y -> 4   9 <- tree 4
    /// >                  \
    /// >                   5 <- tree 3
    ///
    /// Post-rotation:
    ///
    /// >                   4 <- node y
    /// >                  / \
    /// >       node x -> 2   8 <- node z
    /// >                /   / \
    /// >     tree 1 -> 1   5   9 <- tree 4
    /// >                   ^ tree 3
    ///
    /// # Testing
    ///
    /// * `test_rotate_right_left_1()`
    /// * `test_rotate_right_left_2()`
    fun retrace_rebalance_rotate_right_left<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_x_id: u64,
        node_z_id: u64,
        node_y_id: u64,
        node_z_height_right: u8
    ): (
        u64,
        u8
    ) {
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        // Immutably borrow node y.
        let node_y_ref = table_with_length::borrow(nodes_ref_mut, node_y_id);
        let y_bits = node_y_ref.bits; // Get node y bits.
        // Get node y's left and right height, and tree 2 and 3 IDs.
        let (node_y_height_left, node_y_height_right, tree_2_id, tree_3_id) =
            ((((y_bits >> SHIFT_HEIGHT_LEFT ) & (HI_HEIGHT  as u128)) as u8),
             (((y_bits >> SHIFT_HEIGHT_RIGHT) & (HI_HEIGHT  as u128)) as u8),
             (((y_bits >> SHIFT_CHILD_LEFT  ) & (HI_NODE_ID as u128)) as u64),
             (((y_bits >> SHIFT_CHILD_RIGHT ) & (HI_NODE_ID as u128)) as u64));
        if (tree_2_id != (NIL as u64)) { // If tree 2 not null:
            let tree_2_ref_mut = // Mutably borrow tree 2 root.
                table_with_length::borrow_mut(nodes_ref_mut, tree_2_id);
            // Reassign bits for new parent field:
            tree_2_ref_mut.bits = tree_2_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_PARENT)) |
                // Mask in new bits.
                ((node_x_id as u128) << SHIFT_PARENT);
        };
        if (tree_3_id != (NIL as u64)) { // If tree 3 not null:
            let tree_3_ref_mut = // Mutably borrow tree 3 root.
                table_with_length::borrow_mut(nodes_ref_mut, tree_3_id);
            // Reassign bits for new parent field:
            tree_3_ref_mut.bits = tree_3_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_PARENT)) |
                // Mask in new bits.
                ((node_z_id as u128) << SHIFT_PARENT);
        };
        let node_x_ref_mut =  // Mutably borrow node x.
            table_with_length::borrow_mut(nodes_ref_mut, node_x_id);
        // Node x's right height is from transferred tree 2.
        let node_x_height_right = node_y_height_left;
        let node_x_parent = (((node_x_ref_mut.bits >> SHIFT_PARENT) &
            (HI_NODE_ID as u128)) as u64); // Store node x parent field.
        // Reassign bits for right child, right height, and parent:
        node_x_ref_mut.bits = node_x_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_RIGHT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_RIGHT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((tree_2_id           as u128) << SHIFT_CHILD_RIGHT) |
            ((node_x_height_right as u128) << SHIFT_HEIGHT_RIGHT) |
            ((node_y_id           as u128) << SHIFT_PARENT);
        let node_z_ref_mut =  // Mutably borrow node z.
            table_with_length::borrow_mut(nodes_ref_mut, node_z_id);
        // Node z's left height is from transferred tree 3.
        let node_z_height_left = node_y_height_right;
        // Reassign bits for left child, left height, and parent:
        node_z_ref_mut.bits = node_z_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_LEFT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_LEFT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((tree_3_id          as u128) << SHIFT_CHILD_LEFT) |
            ((node_z_height_left as u128) << SHIFT_HEIGHT_LEFT) |
            ((node_y_id          as u128) << SHIFT_PARENT);
        // Determine height of tree rooted at z.
        let node_z_height = if (node_z_height_left >= node_z_height_right)
            node_z_height_left else node_z_height_right;
        // Get node y's post-rotation height (same on left and right).
        let node_y_height = node_z_height + 1;
        let node_y_ref_mut = // Mutably borrow node y.
            table_with_length::borrow_mut(nodes_ref_mut, node_y_id);
        // Reassign bits for both child edges, and parent.
        node_y_ref_mut.bits = node_y_ref_mut.bits &
            // Clear out fields via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_CHILD_LEFT) |
                       ((HI_NODE_ID as u128) << SHIFT_CHILD_RIGHT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_LEFT) |
                       ((HI_HEIGHT  as u128) << SHIFT_HEIGHT_RIGHT) |
                       ((HI_NODE_ID as u128) << SHIFT_PARENT))) |
            // Mask in new bits.
            ((node_x_id     as u128) << SHIFT_CHILD_LEFT) |
            ((node_z_id     as u128) << SHIFT_CHILD_RIGHT) |
            ((node_y_height as u128) << SHIFT_HEIGHT_LEFT) |
            ((node_y_height as u128) << SHIFT_HEIGHT_RIGHT) |
            ((node_x_parent as u128) << SHIFT_PARENT);
        (node_y_id, node_y_height) // Return new subtree root, height.
    }

    /// Update height fields during retracing.
    ///
    /// Inner function for `retrace()`.
    ///
    /// # Parameters
    ///
    /// * `node_ref_mut`: Mutable reference to a node that needs to have
    ///   its height fields updated during retrace.
    /// * `side`: `LEFT` or `RIGHT`, the side on which the node's height
    ///   needs to be updated.
    /// * `operation`: `INCREMENT` or `DECREMENT`, the kind of change in
    ///   the height field for the given side.
    /// * `delta`: The amount of height change for the operation.
    ///
    /// # Returns
    ///
    /// * `u8`: The left height of the node after updating height.
    /// * `u8`: The right height of the node after updating height.
    /// * `u8`: The height of the node before updating height.
    /// * `u8`: The height of the node after updating height.
    ///
    /// # Testing
    ///
    /// * `test_retrace_update_heights_1()`
    /// * `test_retrace_update_heights_2()`
    fun retrace_update_heights(
        node_ref_mut: &mut TreeNode,
        side: bool,
        operation: bool,
        delta: u8
    ): (
        u8,
        u8,
        u8,
        u8
    ) {
        let bits = node_ref_mut.bits; // Get node's field bits.
        // Get node's left height, right height, and parent fields.
        let (height_left, height_right) =
            ((((bits >> SHIFT_HEIGHT_LEFT ) & (HI_HEIGHT as u128)) as u8),
             (((bits >> SHIFT_HEIGHT_RIGHT) & (HI_HEIGHT as u128)) as u8));
        let height_old = if (height_left >= height_right) height_left else
            height_right; // Get height of node before retracing.
        // Get height field and shift amount for operation side.
        let (height_field, height_shift) = if (side == LEFT)
            (height_left , SHIFT_HEIGHT_LEFT ) else
            (height_right, SHIFT_HEIGHT_RIGHT);
        // Get updated height field for side.
        let height_field = if (operation == INCREMENT) height_field + delta
            else height_field - delta;
        // Reassign bits for corresponding height field:
        node_ref_mut.bits = bits &
            // Clear out field via mask unset at field bits.
            (HI_128 ^ ((HI_HEIGHT as u128) << height_shift)) |
            // Mask in new bits.
            ((height_field as u128) << height_shift);
        // Reassign local height to that of indicated field.
        if (side == LEFT) height_left = height_field else
            height_right = height_field;
        let height = if (height_left >= height_right) height_left else
            height_right; // Get height of node after update.
        (height_left, height_right, height, height_old)
    }

    /// Search in AVL queue for closest match to seed key.
    ///
    /// Return immediately if empty tree, otherwise get node ID of root
    /// node. Then start walking down nodes, branching left whenever the
    /// seed key is less than a node's key, right whenever the seed
    /// key is greater than a node's key, and returning when the seed
    /// key equals a node's key. Also return if there is no child to
    /// branch to on a given side.
    ///
    /// The "match" node is the node last walked before returning.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref`: Immutable reference to AVL queue.
    /// * `seed_key`: Seed key to search for.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of match node, or `NIL` if empty tree.
    /// * `Option<bool>`: None if empty tree or if match key equals seed
    ///   key, `LEFT` if seed key is less than match key but match node
    ///   has no left child, `RIGHT` if seed key is greater than match
    ///   key but match node has no right child.
    ///
    /// # Assumptions
    ///
    /// * AVL queue is not empty, and `root_node_id` properly indicates
    ///   the root node.
    /// * Seed key fits in 32 bits.
    ///
    /// # Reference diagram
    ///
    /// >               4 <- ID 1
    /// >              / \
    /// >     ID 5 -> 2   8 <- ID 2
    /// >                / \
    /// >       ID 4 -> 6   10 <- ID 3
    ///
    /// | Seed key | Match key | Node ID | Side  |
    /// |----------|-----------|---------|-------|
    /// | 2        | 2         | 5       | None  |
    /// | 7        | 6         | 4       | Right |
    /// | 9        | 10        | 3       | Left  |
    /// | 4        | 4         | 1       | None  |
    ///
    /// # Testing
    ///
    /// * `test_search()`.
    fun search<V>(
        avlq_ref: &AVLqueue<V>,
        seed_key: u64
    ): (
        u64,
        Option<bool>
    ) {
        let root_msbs = // Get root MSBs.
            (avlq_ref.bits & ((HI_NODE_ID >> BITS_PER_BYTE) as u128) as u64);
        let node_id = // Shift over, mask in LSBs, store as search node.
            (root_msbs << BITS_PER_BYTE) | (avlq_ref.root_lsbs as u64);
        // If no node at root, return as such, with empty option.
        if (node_id == (NIL as u64)) return (node_id, option::none());
        // Mutably borrow tree nodes table.
        let nodes_ref = &avlq_ref.tree_nodes;
        loop { // Begin walking down tree nodes:
            let node_ref = // Mutably borrow node having given ID.
                table_with_length::borrow(nodes_ref, node_id);
            // Get insertion key encoded in search node's bits.
            let node_key = (((node_ref.bits >> SHIFT_INSERTION_KEY) &
                             (HI_INSERTION_KEY as u128)) as u64);
            // If search key equals seed key, return node's ID and
            // empty option.
            if (seed_key == node_key) return (node_id, option::none());
            // Get bitshift for child node ID and side based on
            // inequality comparison between seed key and node key.
            let (child_shift, child_side) = if (seed_key < node_key)
                (SHIFT_CHILD_LEFT, LEFT) else (SHIFT_CHILD_RIGHT, RIGHT);
            let child_id = (((node_ref.bits >> child_shift) &
                (HI_NODE_ID as u128)) as u64); // Get child node ID.
            // If no child on given side, return match node's ID
            // and option with given side.
            if (child_id == (NIL as u64)) return
                (node_id, option::some(child_side));
            // Otherwise continue walk at given child.
            node_id = child_id;
        }
    }

    /// Verify node count is not too high.
    ///
    /// # Aborts
    ///
    /// * `E_TOO_MANY_NODES`: `n_nodes` is not less than `N_NODES_MAX`.
    ///
    /// # Testing
    ///
    /// * `test_verify_node_count_fail()`
    /// * `test_verify_node_count_pass()`
    fun verify_node_count(
        n_nodes: u64,
    ) {
        // Assert node count is less than or equal to max amount.
        assert!(n_nodes <= N_NODES_MAX, E_TOO_MANY_NODES);
    }

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// When a char in a bytestring is neither 0 nor 1.
    const E_BIT_NOT_0_OR_1: u64 = 100;

    // Test-only error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Immutably borrow list node having given node ID.
    fun borrow_list_node_test<V>(
        avlq_ref: &AVLqueue<V>,
        node_id: u64
    ): &ListNode {
        table_with_length::borrow(&avlq_ref.list_nodes, node_id)
    }

    #[test_only]
    /// Immutably borrow tree node having given node ID.
    fun borrow_tree_node_test<V>(
        avlq_ref: &AVLqueue<V>,
        node_id: u64
    ): &TreeNode {
        table_with_length::borrow(&avlq_ref.tree_nodes, node_id)
    }

    #[test_only]
    /// Immutably borrow value option having given node ID.
    fun borrow_value_option_test<V>(
        avlq_ref: &AVLqueue<V>,
        node_id: u64
    ): &Option<V> {
        table::borrow(&avlq_ref.values, node_id)
    }

    #[test_only]
    /// Drop AVL queue.
    fun drop_avlq_test<V>(
        avlq: AVLqueue<V>
    ) {
        // Unpack all fields, dropping those that are not tables.
        let AVLqueue{bits: _, root_lsbs: _, tree_nodes, list_nodes, values} =
            avlq;
        // Drop all tables.
        table_with_length::drop_unchecked(tree_nodes);
        table_with_length::drop_unchecked(list_nodes);
        table::drop_unchecked(values);
    }

    #[test_only]
    /// Get list node ID encoded in an access key.
    ///
    /// # Testing
    ///
    /// * `test_access_key_getters()`
    fun get_access_key_list_node_id_test(
        access_key: u64
    ): u64 {
        (access_key >> SHIFT_ACCESS_LIST_NODE_ID) & HI_NODE_ID
    }

    #[test_only]
    /// Get tree node ID encoded in an access key.
    ///
    /// # Testing
    ///
    /// * `test_access_key_getters()`
    fun get_access_key_tree_node_id_test(
        access_key: u64
    ): u64 {
        (access_key >> SHIFT_ACCESS_TREE_NODE_ID) & HI_NODE_ID
    }

    #[test_only]
    /// Like `get_child_left_test()`, but accepts tree node ID inside
    /// given AVL queue.
    fun get_child_left_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u64 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_child_left_test(tree_node_ref) // Return left child field.
    }

    #[test_only]
    /// Return left child node ID indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_child_left_test()`
    fun get_child_left_test(
        tree_node_ref: &TreeNode
    ): u64 {
        (((tree_node_ref.bits >> SHIFT_CHILD_LEFT) &
          (HI_NODE_ID as u128)) as u64)
    }

    #[test_only]
    /// Return right child node ID indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_child_right_test()`
    fun get_child_right_test(
        tree_node_ref: &TreeNode
    ): u64 {
        (((tree_node_ref.bits >> SHIFT_CHILD_RIGHT)) &
          (HI_NODE_ID as u128) as u64)
    }

    #[test_only]
    /// Like `get_child_right_test()`, but accepts tree node ID inside
    /// given AVL queue.
    fun get_child_right_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u64 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_child_right_test(tree_node_ref) // Return right child field.
    }

    #[test_only]
    /// Return head insertion key indicated by given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_head_tail()`
    fun get_head_key_test<V>(
        avlq_ref: &AVLqueue<V>
    ): u64 {
        (((avlq_ref.bits >> SHIFT_HEAD_KEY) &
          (HI_INSERTION_KEY as u128)) as u64)
    }

    #[test_only]
    /// Return head list node ID indicated by given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_head_tail()`
    fun get_head_node_id_test<V>(
        avlq_ref: &AVLqueue<V>
    ): u64 {
        (((avlq_ref.bits >> SHIFT_HEAD_NODE_ID) & (HI_NODE_ID as u128)) as u64)
    }

    #[test_only]
    /// Like `get_height_left_test()`, but accepts tree node ID inside
    /// given AVL queue.
    fun get_height_left_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u8 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_height_left_test(tree_node_ref) // Return left height.
    }

    #[test_only]
    /// Return left height indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_height_left_test()`
    fun get_height_left_test(
        tree_node_ref: &TreeNode
    ): u8 {
        (((tree_node_ref.bits >> SHIFT_HEIGHT_LEFT) &
          (HI_HEIGHT as u128)) as u8)
    }

    #[test_only]
    /// Return right height indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_height_right_test()`
    fun get_height_right_test(
        tree_node_ref: &TreeNode
    ): u8 {
        (((tree_node_ref.bits >> SHIFT_HEIGHT_RIGHT) &
          (HI_HEIGHT as u128)) as u8)
    }

    #[test_only]
    /// Like `get_height_right_test()`, but accepts tree node ID inside
    /// given AVL queue.
    fun get_height_right_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u8 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_height_right_test(tree_node_ref) // Return right height.
    }

    #[test_only]
    /// Like `get_insertion_key_test()`, but accepts tree node ID inside
    /// given AVL queue.
    fun get_insertion_key_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u64 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_insertion_key_test(tree_node_ref) // Return insertion key.
    }

    #[test_only]
    /// Return insertion key indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_insertion_key_test()`
    fun get_insertion_key_test(
        tree_node_ref: &TreeNode
    ): u64 {
        (((tree_node_ref.bits >> SHIFT_INSERTION_KEY) &
          (HI_INSERTION_KEY as u128)) as u64)
    }

    #[test_only]
    /// Like `get_list_head_test()`, but accepts tree node ID inside
    /// given AVL queue.
    fun get_list_head_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u64 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_list_head_test(tree_node_ref) // Return list head.
    }

    #[test_only]
    /// Return list head node ID indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_list_head_test()`
    fun get_list_head_test(
        tree_node_ref: &TreeNode
    ): u64 {
        (((tree_node_ref.bits >> SHIFT_LIST_HEAD) &
          (HI_NODE_ID as u128)) as u64)
    }

    #[test_only]
    /// Return node ID of last node and if last node is a tree node,
    /// for given list node.
    ///
    /// # Testing
    ///
    /// * `test_get_list_last_test()`
    fun get_list_last_test(
        list_node_ref: &ListNode
    ): (
        u64,
        bool
    ) {
        // Get virtual last field.
        let last_field = ((list_node_ref.last_msbs as u64) << BITS_PER_BYTE) |
                          (list_node_ref.last_lsbs as u64);
        let tree_node_flag = (((last_field >> SHIFT_NODE_TYPE) &
            (BIT_FLAG_TREE_NODE as u64)) as u8); // Get tree node flag.
        // Return node ID, and if last node is a tree node.
        ((last_field & HI_NODE_ID), tree_node_flag == BIT_FLAG_TREE_NODE)
    }

    #[test_only]
    /// Like `get_list_last_test()`, but accepts list node ID inside
    /// given AVL queue.
    fun get_list_last_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        list_node_id: u64
    ): (
        u64,
        bool
    ) {
        let list_node_ref = // Immutably borrow list node.
            table_with_length::borrow(&avlq_ref.list_nodes, list_node_id);
        get_list_last_test(list_node_ref) // Return last field data.
    }

    #[test_only]
    /// Return only node ID from `get_list_last_by_id_test()`.
    fun get_list_last_node_id_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        list_node_id: u64
    ): u64 {
        // Get last node ID.
        let (node_id, _) = get_list_last_by_id_test(avlq_ref, list_node_id);
        node_id // Return it.
    }

    #[test_only]
    /// Return node ID of next node and if next node is a tree node,
    /// for given list node.
    ///
    /// # Testing
    ///
    /// * `test_get_list_next_test()`
    fun get_list_next_test(
        list_node_ref: &ListNode
    ): (
        u64,
        bool
    ) {
        // Get virtual next field.
        let next_field = ((list_node_ref.next_msbs as u64) << BITS_PER_BYTE) |
                          (list_node_ref.next_lsbs as u64);
        let tree_node_flag = (((next_field >> SHIFT_NODE_TYPE) &
            (BIT_FLAG_TREE_NODE as u64)) as u8); // Get tree node flag.
        // Return node ID, and if next node is a tree node.
        ((next_field & HI_NODE_ID), tree_node_flag == BIT_FLAG_TREE_NODE)
    }

    #[test_only]
    /// Like `get_list_next_test()`, but accepts list node ID inside
    /// given AVL queue.
    fun get_list_next_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        list_node_id: u64
    ): (
        u64,
        bool
    ) {
        let list_node_ref = // Immutably borrow list node.
            table_with_length::borrow(&avlq_ref.list_nodes, list_node_id);
        get_list_next_test(list_node_ref) // Return next field data.
    }

    #[test_only]
    /// Return only node ID from `get_list_next_by_id_test()`.
    fun get_list_next_node_id_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        list_node_id: u64
    ): u64 {
        // Get next node ID.
        let (node_id, _) = get_list_next_by_id_test(avlq_ref, list_node_id);
        node_id // Return it.
    }

    #[test_only]
    /// Like `get_list_tail_test()`, but accepts tree node ID inside
    /// given AVL queue.
    fun get_list_tail_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u64 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_list_tail_test(tree_node_ref) // Return list tail.
    }

    #[test_only]
    /// Return list tail node ID indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_list_tail_test()`
    fun get_list_tail_test(
        tree_node_ref: &TreeNode
    ): u64 {
        (((tree_node_ref.bits >> SHIFT_LIST_TAIL) &
          (HI_NODE_ID as u128)) as u64)
    }

    #[test_only]
    /// Return node ID at top of inactive list node stack indicated by
    /// given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_get_list_top_test()`
    fun get_list_top_test<V>(
        avlq_ref: &AVLqueue<V>
    ): u64 {
        (((avlq_ref.bits >> SHIFT_LIST_STACK_TOP) &
          (HI_NODE_ID as u128)) as u64)
    }

    #[test_only]
    /// Like `get_parent_test()`, but accepts tree node ID inside given
    /// AVL queue.
    fun get_parent_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u64 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_parent_test(tree_node_ref) // Return parent field.
    }

    #[test_only]
    /// Return parent node ID indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_parent_test()`
    fun get_parent_test(
        tree_node_ref: &TreeNode
    ): u64 {
        (((tree_node_ref.bits >> SHIFT_PARENT) &
          (HI_NODE_ID as u128)) as u64)
    }

    #[test_only]
    /// Return tail insertion key indicated by given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_head_tail()`
    fun get_tail_key_test<V>(
        avlq_ref: &AVLqueue<V>
    ): u64 {
        (((avlq_ref.bits >> SHIFT_TAIL_KEY) &
          (HI_INSERTION_KEY as u128)) as u64)
    }

    #[test_only]
    /// Return tail list node ID indicated by given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_head_tail()`
    fun get_tail_node_id_test<V>(
        avlq_ref: &AVLqueue<V>
    ): u64 {
        (((avlq_ref.bits >> SHIFT_TAIL_NODE_ID) & (HI_NODE_ID as u128)) as u64)
    }

    #[test_only]
    /// Like `get_tree_next_test()`, but accepts tree node ID inside
    /// given AVL queue.
    fun get_tree_next_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        tree_node_id: u64
    ): u64 {
        let tree_node_ref = // Immutably borrow tree node.
            table_with_length::borrow(&avlq_ref.tree_nodes, tree_node_id);
        get_tree_next_test(tree_node_ref) // Return parent field.
    }

    #[test_only]
    /// Return node ID of next inactive tree node in stack, indicated
    /// by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_tree_next_test()`
    fun get_tree_next_test(
        tree_node_ref: &TreeNode
    ): u64 {
        ((tree_node_ref.bits & (HI_64 as u128)) as u64) & HI_NODE_ID
    }

    #[test_only]
    /// Return node ID at top of inactive tree node stack indicated by
    /// given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_get_tree_top_test()`
    fun get_tree_top_test<V>(
        avlq_ref: &AVLqueue<V>
    ): u64 {
        (((avlq_ref.bits >> SHIFT_TREE_STACK_TOP) &
          (HI_NODE_ID as u128)) as u64)
    }

    #[test_only]
    /// Return root node ID indicated by AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_root_test()`
    fun get_root_test<V>(
        avlq_ref: &AVLqueue<V>
    ): u64 {
        // Get MSBs.
        let msbs = avlq_ref.bits & ((HI_NODE_ID as u128) >> BITS_PER_BYTE);
        // Mask in LSBs and return.
        ((msbs << BITS_PER_BYTE) as u64) | (avlq_ref.root_lsbs as u64)
    }

    #[test_only]
    /// Return copy of value for given node ID.
    fun get_value_test<V: copy>(
        avlq_ref: &AVLqueue<V>,
        node_id: u64
    ): V {
        // Borrow value option.
        let value_option_ref = borrow_value_option_test(avlq_ref, node_id);
        // Return copy of value.
        *option::borrow(value_option_ref)
    }

    #[test_only]
    /// Return `true` if ascending access key, else `false`.
    ///
    /// # Testing
    ///
    /// * `test_access_key_getters()`
    fun is_ascending_access_key_test(
        access_key: u64
    ): bool {
        ((access_key >> SHIFT_ACCESS_SORT_ORDER) & (HI_BIT as u64) as u8) ==
            BIT_FLAG_ASCENDING
    }

    #[test_only]
    /// Return only is tree node flag from `get_list_last_by_id_test()`.
    fun is_tree_node_list_last_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        list_node_id: u64
    ): bool {
        let (_, is_tree_node) = // Check if last node is tree node.
            get_list_last_by_id_test(avlq_ref, list_node_id);
        is_tree_node // Return flag.
    }

    #[test_only]
    /// Return only is tree node flag from `get_list_next_by_id_test()`.
    fun is_tree_node_list_next_by_id_test<V>(
        avlq_ref: &AVLqueue<V>,
        list_node_id: u64
    ): bool {
        let (_, is_tree_node) = // Check if next node is tree node.
            get_list_next_by_id_test(avlq_ref, list_node_id);
        is_tree_node // Return flag.
    }

    #[test_only]
    /// Set head insertion key in given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_head_tail()`
    fun set_head_key_test<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        key: u64
    ) {
        // Reassign bits:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (HI_128 ^ ((HI_INSERTION_KEY as u128) << SHIFT_HEAD_KEY as u128)) |
            // Mask in new bits.
            ((key as u128) << SHIFT_HEAD_KEY)
    }

    #[test_only]
    /// Set head list node ID in given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_head_tail()`
    fun set_head_node_id_test<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_id: u64
    ) {
        // Reassign bits:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_HEAD_NODE_ID as u128)) |
            // Mask in new bits.
            ((node_id as u128) << SHIFT_HEAD_NODE_ID)
    }

    #[test_only]
    /// Set root node ID.
    ///
    /// # Testing
    ///
    /// * `test_set_get_root_test()`
    fun set_root_test<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        root_node_id: u64
    ) {
        // Set root LSBs.
        avlq_ref_mut.root_lsbs = ((root_node_id & HI_BYTE) as u8);
        // Reassign bits for root MSBs:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (HI_128 ^ ((HI_NODE_ID >> BITS_PER_BYTE) as u128)) |
            // Mask in new bits.
            ((root_node_id as u128) >> BITS_PER_BYTE)
    }

    #[test_only]
    /// Set tail insertion key in given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_head_tail()`
    fun set_tail_key_test<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        key: u64
    ) {
        // Reassign bits:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (HI_128 ^ (((HI_INSERTION_KEY as u128) << SHIFT_TAIL_KEY) as u128))
            // Mask in new bits.
            | ((key as u128) << SHIFT_TAIL_KEY)
    }

    #[test_only]
    /// Set tail list node ID in given AVL queue.
    ///
    /// # Testing
    ///
    /// * `test_set_get_head_tail()`
    fun set_tail_node_id_test<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_id: u64
    ) {
        // Reassign bits:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (HI_128 ^ (((HI_NODE_ID as u128) << SHIFT_TAIL_NODE_ID) as u128)) |
            // Mask in new bits.
            ((node_id as u128) << SHIFT_TAIL_NODE_ID)
    }

    #[test_only]
    /// Return a `u128` corresponding to provided byte string `s`. The
    /// byte should only contain only "0"s and "1"s, up to 128
    /// characters max (e.g. `b"100101...10101010"`).
    ///
    /// # Testing
    ///
    /// * `test_u_128_64()`
    /// * `test_u_128_failure()`
    public fun u_128(
        s: vector<u8>
    ): u128 {
        let n = vector::length<u8>(&s); // Get number of bits.
        let r = 0; // Initialize result to 0.
        let i = 0; // Start loop at least significant bit.
        while (i < n) { // While there are bits left to review.
            // Get bit under review.
            let b = *vector::borrow<u8>(&s, n - 1 - i);
            if (b == 0x31) { // If the bit is 1 (0x31 in ASCII):
                // OR result with the correspondingly leftshifted bit.
                r = r | (1 << (i as u8));
            // Otherwise, assert bit is marked 0 (0x30 in ASCII).
            } else assert!(b == 0x30, E_BIT_NOT_0_OR_1);
            i = i + 1; // Proceed to next-least-significant bit.
        };
        r // Return result.
    }

    #[test_only]
    /// Return `u128` corresponding to concatenated result of `a`, `b`,
    /// `c`, and `d`. Useful for line-wrapping long byte strings, and
    /// inspection via 32-bit sections.
    ///
    /// # Testing
    ///
    /// * `test_u_128_64()`
    public fun u_128_by_32(
        a: vector<u8>,
        b: vector<u8>,
        c: vector<u8>,
        d: vector<u8>,
    ): u128 {
        vector::append<u8>(&mut c, d); // Append d onto c.
        vector::append<u8>(&mut b, c); // Append c onto b.
        vector::append<u8>(&mut a, b); // Append b onto a.
        u_128(a) // Return u128 equivalent of concatenated bytestring.
    }

    #[test_only]
    /// Wrapper for `u_128()`, casting return to `u64`.
    ///
    /// # Testing
    ///
    /// * `test_u_128_64()`
    public fun u_64(s: vector<u8>): u64 {(u_128(s) as u64)}

    #[test_only]
    /// Wrapper for `u_128_by_32()`, accepting only two inputs, with
    /// casted return to `u64`.
    public fun u_64_by_32(
        a: vector<u8>,
        b: vector<u8>
    ): u64 {
        // Get u128 for given inputs, cast to u64.
        (u_128_by_32(a, b, b"", b"") as u64)
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify successful returns.
    fun test_access_key_getters() {
        // Assert access key not marked ascending if no bits set.
        assert!(!is_ascending_access_key_test((NIL as u64)), 0);
        // Declare encoded information for access key.
        let tree_node_id = u_64(b"10000000000001");
        let list_node_id = u_64(b"11000000000011");
        let insertion_key = u_64(b"10000000000000000000000000000001");
        let access_key = u_64_by_32(
            b"00010000000000001110000000000111",
            //   ^ bits 47-60 ^^ bits 33-46 ^^ bit 32
            b"10000000000000000000000000000001");
        // Assert access key getter returns.
        assert!(get_access_key_tree_node_id_test(access_key)
                == tree_node_id, 0);
        assert!(get_access_key_list_node_id_test(access_key)
                == list_node_id, 0);
        assert!(is_ascending_access_key_test(access_key), 0);
        assert!(get_access_key_insertion_key(access_key)
                == insertion_key, 0);
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_child_left_test() {
        let tree_node = TreeNode{bits: u_128_by_32( // Create tree node.
            b"11111111111111111111111111111111",
            b"11111111111111111111111111100000",
            //                          ^ bit 69
            b"00000001111111111111111111111111",
            //       ^ bit 56
            b"11111111111111111111111111111111")};
        // Assert left child node ID.
        assert!(get_child_left_test(&tree_node) == u_64(b"10000000000001"), 0);
        let TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_child_right_test() {
        let tree_node = TreeNode{bits: u_128_by_32( // Create tree node.
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111100000000000011111111111",
            //        ^ bit 55     ^ bit 42
            b"11111111111111111111111111111111")};
        assert!( // Assert right child node ID.
            get_child_right_test(&tree_node) == u_64(b"10000000000001"), 0);
        let TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_height_left_test() {
        let tree_node = TreeNode{bits: u_128_by_32( // Create tree node.
            b"11111111111111111111111111111111",
            b"11100011111111111111111111111111",
            //  ^   ^ bits 89-93
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111")};
        // Assert left height.
        assert!(get_height_left_test(&tree_node) == (u_64(b"10001") as u8), 0);
        let TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_height_right_test() {
        let tree_node = TreeNode{bits: u_128_by_32( // Create tree node.
            b"11111111111111111111111111111111",
            b"11111111000111111111111111111111",
            //       ^   ^ bits 84-88
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111")};
        assert!( // Assert right height.
            get_height_right_test(&tree_node) == (u_64(b"10001") as u8), 0);
        let TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_insertion_key_test() {
        let tree_node = TreeNode{bits: u_128_by_32( // Create tree node.
            b"11100000000000000000000000000000",
            //  ^ bit 125
            b"01111111111111111111111111111111",
            // ^ bit 94
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111")};
        // Assert insertion key
        assert!(get_insertion_key_test(&tree_node) ==
            u_64(b"10000000000000000000000000000001"), 0);
        let TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_list_head_test() {
        let tree_node = TreeNode{bits: u_128_by_32( // Create tree node.
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111000000000",
            //                      ^ bit 41
            b"00011111111111111111111111111111")};
            //   ^ bit 28
        // Assert list head node ID.
        assert!(get_list_head_test(&tree_node) == u_64(b"10000000000001"), 0);
        let TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_list_last_test() {
        // Declare list node.
        let list_node = ListNode{
            last_msbs: (u_64(b"00100000") as u8),
            last_lsbs: (u_64(b"00000001") as u8),
            next_msbs: 0,
            next_lsbs: 0};
        // Get last node info.
        let (node_id, is_tree_node) = get_list_last_test(&list_node);
        // Assert last node ID.
        assert!(node_id == u_64(b"10000000000001"), 0);
        // Assert not marked as tree node.
        assert!(!is_tree_node, 0);
        // Flag as tree node.
        list_node.last_msbs = (u_64(b"01100000") as u8);
        // Get last node info.
        (node_id, is_tree_node) = get_list_last_test(&list_node);
        // Assert last node ID unchanged.
        assert!(node_id == u_64(b"10000000000001"), 0);
        // Assert marked as tree node.
        assert!(is_tree_node, 0);
        ListNode{last_msbs: _, last_lsbs: _, next_msbs: _, next_lsbs: _} =
            list_node; // Unpack list node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_list_next_test() {
        // Declare list node.
        let list_node = ListNode{
            last_msbs: 0,
            last_lsbs: 0,
            next_msbs: (u_64(b"00100000") as u8),
            next_lsbs: (u_64(b"00000001") as u8)};
        // Get next node info.
        let (node_id, is_tree_node) = get_list_next_test(&list_node);
        // Assert next node ID.
        assert!(node_id == u_64(b"10000000000001"), 0);
        // Assert not marked as tree node.
        assert!(!is_tree_node, 0);
        // Flag as tree node.
        list_node.next_msbs = (u_64(b"01100000") as u8);
        // Get next node info.
        (node_id, is_tree_node) = get_list_next_test(&list_node);
        // Assert next node ID unchanged.
        assert!(node_id == u_64(b"10000000000001"), 0);
        // Assert marked as tree node.
        assert!(is_tree_node, 0);
        ListNode{last_msbs: _, last_lsbs: _, next_msbs: _, next_lsbs: _} =
            list_node; // Unpack list node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_list_tail_test() {
        let tree_node = TreeNode{bits: u_128_by_32( // Create tree node.
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111000000000000111111111111111")};
            //    ^ bit 27     ^ bit 14
        // Assert list tail node ID.
        assert!(get_list_tail_test(&tree_node) == u_64(b"10000000000001"), 0);
        let TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_list_top_test() {
        let avlq = AVLqueue<u8>{ // Create empty AVL queue.
            bits: u_128_by_32(
                b"11111111111111111000000000000111",
                //                ^ bit 111    ^ bit 98
                b"11111111111111111111111111111111",
                b"11111111111111111111111111111111",
                b"11111111111111111111111111111111"),
            root_lsbs: (NIL as u8),
            tree_nodes: table_with_length::new(),
            list_nodes: table_with_length::new(),
            values: table::new(),
        };
        // Assert list top.
        assert!(get_list_top_test(&avlq) == u_64(b"10000000000001"), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_parent_test() {
        let tree_node = TreeNode{bits: u_128_by_32( // Create tree node.
            b"11111111111111111111111111111111",
            b"11111111111110000000000001111111",
            //            ^ bit 83     ^ bit 70
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111")};
        // Assert parent node ID.
        assert!(get_parent_test(&tree_node) == u_64(b"10000000000001"), 0);
        let TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_tree_next_test() {
        // Declare tree node.
        let tree_node = TreeNode{bits: u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111110000000000001")};
        assert!( // Assert next node ID.
            get_tree_next_test(&tree_node) == u_64(b"10000000000001"), 0);
        TreeNode{bits: _} = tree_node; // Unpack tree node.
    }

    #[test]
    /// Verify successful extraction.
    fun test_get_tree_top_test() {
        let avlq = AVLqueue<u8>{ // Create empty AVL queue.
            bits: u_128_by_32(
                b"11100000000000011111111111111111",
                //  ^ bit 125    ^ bit 112
                b"11111111111111111111111111111111",
                b"11111111111111111111111111111111",
                b"11111111111111111111111111111111"),
            root_lsbs: (NIL as u8),
            tree_nodes: table_with_length::new(),
            list_nodes: table_with_length::new(),
            values: table::new(),
        };
        // Assert tree top.
        assert!(get_tree_top_test(&avlq) == u_64(b"10000000000001"), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify insertion sequence from `insert()`.
    fun test_insert() {
        // Init ascending AVL queue with allocated nodes.
        let avlq = new(ASCENDING, 7, 3);
        // Insert per reference diagram, storing access keys.
        let access_key_3_9 = insert(&mut avlq, 3, 9);
        let access_key_4_8 = insert(&mut avlq, 4, 8);
        let access_key_5_7 = insert(&mut avlq, 5, 7);
        let access_key_3_6 = insert(&mut avlq, 3, 6);
        let access_key_5_5 = insert(&mut avlq, 5, 5);
        // Declare expected node IDs per initial node allocations.
        let tree_node_id_3_9 = 7;
        let tree_node_id_4_8 = 6;
        let tree_node_id_5_7 = 5;
        let tree_node_id_3_6 = 7;
        let tree_node_id_5_5 = 5;
        let list_node_id_3_9 = 3;
        let list_node_id_4_8 = 2;
        let list_node_id_5_7 = 1;
        let list_node_id_3_6 = 4;
        let list_node_id_5_5 = 5;
        let tree_node_id_3 = tree_node_id_3_9;
        let tree_node_id_4 = tree_node_id_4_8;
        let tree_node_id_5 = tree_node_id_5_7;
        // Assert access key insertion keys.
        assert!(get_access_key_insertion_key(access_key_3_9) == 3, 0);
        assert!(get_access_key_insertion_key(access_key_4_8) == 4, 0);
        assert!(get_access_key_insertion_key(access_key_5_7) == 5, 0);
        assert!(get_access_key_insertion_key(access_key_3_6) == 3, 0);
        assert!(get_access_key_insertion_key(access_key_5_5) == 5, 0);
        // Assert access key tree node IDs.
        assert!(get_access_key_tree_node_id_test(access_key_3_9)
                == tree_node_id_3_9, 0);
        assert!(get_access_key_tree_node_id_test(access_key_4_8)
                == tree_node_id_4_8, 0);
        assert!(get_access_key_tree_node_id_test(access_key_5_7)
                == tree_node_id_5_7, 0);
        assert!(get_access_key_tree_node_id_test(access_key_3_6)
                == tree_node_id_3_6, 0);
        assert!(get_access_key_tree_node_id_test(access_key_5_5)
                == tree_node_id_5_5, 0);
        // Assert access key list node IDs.
        assert!(get_access_key_list_node_id_test(access_key_3_9)
                == list_node_id_3_9, 0);
        assert!(get_access_key_list_node_id_test(access_key_4_8)
                == list_node_id_4_8, 0);
        assert!(get_access_key_list_node_id_test(access_key_5_7)
                == list_node_id_5_7, 0);
        assert!(get_access_key_list_node_id_test(access_key_3_6)
                == list_node_id_3_6, 0);
        assert!(get_access_key_list_node_id_test(access_key_5_5)
                == list_node_id_5_5, 0);
        // Assert root tree node ID.
        assert!(get_root_test(&avlq) == tree_node_id_4, 0);
        // Assert inactive tree node stack top
        assert!(get_tree_top_test(&avlq) == 4, 0);
        // Assert empty inactive list node stack.
        assert!(get_list_top_test(&avlq) == (NIL as u64), 0);
        // Assert AVL queue head and tail.
        assert!(get_head_node_id_test(&avlq) == list_node_id_3_9, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_5_5, 0);
        assert!(get_head_key_test(&avlq) == 3, 0);
        assert!(get_tail_key_test(&avlq) == 5, 0);
        // Assert all tree node state.
        assert!(get_insertion_key_by_id_test(&avlq, tree_node_id_3) == 3, 0);
        assert!(get_height_left_by_id_test(  &avlq, tree_node_id_3) == 0, 0);
        assert!(get_height_right_by_id_test( &avlq, tree_node_id_3) == 0, 0);
        assert!(get_parent_by_id_test(       &avlq, tree_node_id_3)
                == tree_node_id_4, 0);
        assert!(get_child_left_by_id_test(   &avlq, tree_node_id_3)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(  &avlq, tree_node_id_3)
                == (NIL as u64), 0);
        assert!(get_list_head_by_id_test(    &avlq, tree_node_id_3)
                == list_node_id_3_9, 0);
        assert!(get_list_tail_by_id_test(    &avlq, tree_node_id_3)
                == list_node_id_3_6, 0);
        assert!(get_tree_next_by_id_test(    &avlq, tree_node_id_3)
                == (NIL as u64), 0);
        assert!(get_insertion_key_by_id_test(&avlq, tree_node_id_4) == 4, 0);
        assert!(get_height_left_by_id_test(  &avlq, tree_node_id_4) == 1, 0);
        assert!(get_height_right_by_id_test( &avlq, tree_node_id_4) == 1, 0);
        assert!(get_parent_by_id_test(       &avlq, tree_node_id_4)
                == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(   &avlq, tree_node_id_4)
                == tree_node_id_3, 0);
        assert!(get_child_right_by_id_test(  &avlq, tree_node_id_4)
                == tree_node_id_5, 0);
        assert!(get_list_head_by_id_test(    &avlq, tree_node_id_4)
                == list_node_id_4_8, 0);
        assert!(get_list_tail_by_id_test(    &avlq, tree_node_id_4)
                == list_node_id_4_8, 0);
        assert!(get_tree_next_by_id_test(    &avlq, tree_node_id_4)
                == (NIL as u64), 0);
        assert!(get_insertion_key_by_id_test(&avlq, tree_node_id_5) == 5, 0);
        assert!(get_height_left_by_id_test(  &avlq, tree_node_id_5) == 0, 0);
        assert!(get_height_right_by_id_test( &avlq, tree_node_id_5) == 0, 0);
        assert!(get_parent_by_id_test(       &avlq, tree_node_id_5)
                == tree_node_id_4, 0);
        assert!(get_child_left_by_id_test(   &avlq, tree_node_id_5)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(  &avlq, tree_node_id_5)
                == (NIL as u64), 0);
        assert!(get_list_head_by_id_test(    &avlq, tree_node_id_5)
                == list_node_id_5_7, 0);
        assert!(get_list_tail_by_id_test(    &avlq, tree_node_id_5)
                == list_node_id_5_5, 0);
        assert!(get_tree_next_by_id_test(    &avlq, tree_node_id_5)
                == (NIL as u64), 0);
        // Assert all list node state.
        assert!(get_list_last_node_id_by_id_test(  &avlq, list_node_id_3_9)
                == tree_node_id_3, 0);
        assert!( is_tree_node_list_last_by_id_test(&avlq, list_node_id_3_9),
                0);
        assert!(get_list_next_node_id_by_id_test(  &avlq, list_node_id_3_9)
                == list_node_id_3_6, 0);
        assert!(!is_tree_node_list_next_by_id_test(&avlq, list_node_id_3_9),
                0);
        assert!(get_list_last_node_id_by_id_test(  &avlq, list_node_id_3_6)
                == list_node_id_3_9, 0);
        assert!(!is_tree_node_list_last_by_id_test(&avlq, list_node_id_3_6),
                0);
        assert!(get_list_next_node_id_by_id_test(  &avlq, list_node_id_3_6)
                == tree_node_id_3, 0);
        assert!( is_tree_node_list_next_by_id_test(&avlq, list_node_id_3_6),
                0);
        assert!(get_list_last_node_id_by_id_test(  &avlq, list_node_id_4_8)
                == tree_node_id_4, 0);
        assert!( is_tree_node_list_last_by_id_test(&avlq, list_node_id_4_8),
                0);
        assert!(get_list_next_node_id_by_id_test(  &avlq, list_node_id_4_8)
                == tree_node_id_4, 0);
        assert!( is_tree_node_list_next_by_id_test(&avlq, list_node_id_4_8),
                0);
        assert!(get_list_last_node_id_by_id_test(  &avlq, list_node_id_5_7)
                == tree_node_id_5, 0);
        assert!( is_tree_node_list_last_by_id_test(&avlq, list_node_id_5_7),
                0);
        assert!(get_list_next_node_id_by_id_test(  &avlq, list_node_id_5_7)
                == list_node_id_5_5, 0);
        assert!(!is_tree_node_list_next_by_id_test(&avlq, list_node_id_5_7),
                0);
        assert!(get_list_last_node_id_by_id_test(  &avlq, list_node_id_5_5)
                == list_node_id_5_7, 0);
        assert!(!is_tree_node_list_last_by_id_test(&avlq, list_node_id_5_5),
                0);
        assert!(get_list_next_node_id_by_id_test(  &avlq, list_node_id_5_5)
                == tree_node_id_5, 0);
        assert!( is_tree_node_list_next_by_id_test(&avlq, list_node_id_5_5),
                0);
        // Assert all insertion values.
        assert!(get_value_test(&avlq, list_node_id_3_9) == 9, 0);
        assert!(get_value_test(&avlq, list_node_id_3_6) == 6, 0);
        assert!(get_value_test(&avlq, list_node_id_4_8) == 8, 0);
        assert!(get_value_test(&avlq, list_node_id_5_7) == 7, 0);
        assert!(get_value_test(&avlq, list_node_id_5_5) == 5, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful state manipulation.
    fun test_insert_check_head_tail_ascending() {
        // Init ascending AVL queue.
        let avlq = new<u8>(ASCENDING, 0, 0);
        // Assert head and tail fields.
        assert!(get_head_key_test(&avlq) == (NIL as u64), 0);
        assert!(get_tail_key_test(&avlq) == (NIL as u64), 0);
        assert!(get_head_node_id_test(&avlq) == (NIL as u64), 0);
        assert!(get_tail_node_id_test(&avlq) == (NIL as u64), 0);
        // Declare insertion key and list node ID.
        let key_0 = HI_INSERTION_KEY - 1;
        let list_node_id_0 = HI_NODE_ID;
        // Check head and tail accordingly.
        insert_check_head_tail(&mut avlq, key_0, list_node_id_0);
        // Assert head and tail fields both updated.
        assert!(get_head_key_test(&avlq) == key_0, 0);
        assert!(get_tail_key_test(&avlq) == key_0, 0);
        assert!(get_head_node_id_test(&avlq) == list_node_id_0, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_0, 0);
        // Declare same insertion key with new node ID.
        let key_1 = key_0;
        let list_node_id_1 = list_node_id_0 - 1;
        // Check head and tail accordingly.
        insert_check_head_tail(&mut avlq, key_1, list_node_id_1);
        // Assert head not updated, but tail updated.
        assert!(get_head_key_test(&avlq) == key_0, 0);
        assert!(get_tail_key_test(&avlq) == key_0, 0);
        assert!(get_tail_key_test(&avlq) == key_1, 0);
        assert!(get_head_node_id_test(&avlq) == list_node_id_0, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_1, 0);
        // Declare insertion key smaller than first, new node ID.
        let key_2 = key_1 - 1;
        let list_node_id_2 = list_node_id_1 - 1;
        // Check head and tail accordingly.
        insert_check_head_tail(&mut avlq, key_2, list_node_id_2);
        // Assert head updated, but tail not updated.
        assert!(get_head_key_test(&avlq) == key_2, 0);
        assert!(get_tail_key_test(&avlq) == key_0, 0);
        assert!(get_head_node_id_test(&avlq) == list_node_id_2, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_1, 0);
        // Declare insertion key larger than first, new node ID.
        let key_3 = key_0 + 1;
        let list_node_id_3 = list_node_id_1 - 1;
        // Check head and tail accordingly.
        insert_check_head_tail(&mut avlq, key_3, list_node_id_3);
        // Assert head not updated, but tail updated.
        assert!(get_head_key_test(&avlq) == key_2, 0);
        assert!(get_tail_key_test(&avlq) == key_3, 0);
        assert!(get_head_node_id_test(&avlq) == list_node_id_2, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_3, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful state manipulation.
    fun test_insert_check_head_tail_descending() {
        // Init descending AVL queue.
        let avlq = new<u8>(DESCENDING, 0, 0);
        // Assert head and tail fields.
        assert!(get_head_key_test(&avlq) == (NIL as u64), 0);
        assert!(get_tail_key_test(&avlq) == (NIL as u64), 0);
        assert!(get_head_node_id_test(&avlq) == (NIL as u64), 0);
        assert!(get_tail_node_id_test(&avlq) == (NIL as u64), 0);
        // Declare insertion key and list node ID.
        let key_0 = HI_INSERTION_KEY - 1;
        let list_node_id_0 = HI_NODE_ID;
        // Check head and tail accordingly.
        insert_check_head_tail(&mut avlq, key_0, list_node_id_0);
        // Assert head and tail fields both updated.
        assert!(get_head_key_test(&avlq) == key_0, 0);
        assert!(get_tail_key_test(&avlq) == key_0, 0);
        assert!(get_head_node_id_test(&avlq) == list_node_id_0, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_0, 0);
        // Declare same insertion key with new node ID.
        let key_1 = key_0;
        let list_node_id_1 = list_node_id_0 - 1;
        // Check head and tail accordingly.
        insert_check_head_tail(&mut avlq, key_1, list_node_id_1);
        // Assert head not updated, but tail updated.
        assert!(get_head_key_test(&avlq) == key_0, 0);
        assert!(get_tail_key_test(&avlq) == key_0, 0);
        assert!(get_tail_key_test(&avlq) == key_1, 0);
        assert!(get_head_node_id_test(&avlq) == list_node_id_0, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_1, 0);
        // Declare insertion key larger than first, new node ID.
        let key_2 = key_1 + 1;
        let list_node_id_2 = list_node_id_1 - 1;
        // Check head and tail accordingly.
        insert_check_head_tail(&mut avlq, key_2, list_node_id_2);
        // Assert head updated, but tail not updated.
        assert!(get_head_key_test(&avlq) == key_2, 0);
        assert!(get_tail_key_test(&avlq) == key_0, 0);
        assert!(get_head_node_id_test(&avlq) == list_node_id_2, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_1, 0);
        // Declare insertion key smaller than first, new node ID.
        let key_3 = key_0 - 1;
        let list_node_id_3 = list_node_id_1 - 1;
        // Check head and tail accordingly.
        insert_check_head_tail(&mut avlq, key_3, list_node_id_3);
        // Assert head not updated, but tail updated.
        assert!(get_head_key_test(&avlq) == key_2, 0);
        assert!(get_tail_key_test(&avlq) == key_3, 0);
        assert!(get_head_node_id_test(&avlq) == list_node_id_2, 0);
        assert!(get_tail_node_id_test(&avlq) == list_node_id_3, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    /// Verify failure for insertion key too large.
    fun test_insert_insertion_key_too_large() {
        let avlq = new(ASCENDING, 0, 0); // Init AVL queue.
        // Attempt invalid insertion
        insert(&mut avlq, HI_INSERTION_KEY + 1, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify return and state updates for allocating new list node.
    fun test_insert_list_node_assign_fields_allocate() {
        let avlq = new(ASCENDING, 0, 0); // Init AVL queue.
        // Declare inputs.
        let value = 123;
        let last = 456;
        let next = 789;
        // Assign fields to inserted list node, store its ID.
        let list_node_id = insert_list_node_assign_fields(
            &mut avlq, last, next, value);
        assert!(list_node_id == 1, 0); // Assert list node ID.
        // Assert field assignments.
        let list_node_ref = borrow_list_node_test(&avlq, list_node_id);
        let (last_assigned, _) = get_list_last_test(list_node_ref);
        assert!(last_assigned == last, 0);
        let (next_assigned, _) = get_list_next_test(list_node_ref);
        assert!(next_assigned == next, 0);
        assert!(get_value_test(&avlq, list_node_id) == value, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify return and state updates for inserting stack top.
    fun test_insert_list_node_assign_fields_stacked() {
        let stack_top_id = 321;
        let avlq = new(ASCENDING, 0, stack_top_id); // Init AVL queue.
        // Declare inputs.
        let value = 123;
        let last = 456;
        let next = 789;
        // Assign fields to inserted list node, store its ID.
        let list_node_id = insert_list_node_assign_fields(
            &mut avlq, last, next, value);
        // Assert list node ID.
        assert!(list_node_id == stack_top_id, 0);
        // Assert field assignments.
        let list_node_ref = borrow_list_node_test(&avlq, list_node_id);
        let (last_assigned, _) = get_list_last_test(list_node_ref);
        assert!(last_assigned == last, 0);
        let (next_assigned, _) = get_list_next_test(list_node_ref);
        assert!(next_assigned == next, 0);
        assert!(get_value_test(&avlq, list_node_id) == value, 0);
        // Assert stack top update.
        assert!(get_list_top_test(&avlq) == stack_top_id - 1, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns for list node becoming new tail.
    fun test_insert_list_node_get_last_next_new_tail() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        let anchor_tree_node_id = 15; // Declare anchor tree node ID.
        let old_list_tail = 31; // Declare old list tail node ID.
        // Manually add anchor tree node to tree nodes table.
        table_with_length::add(&mut avlq.tree_nodes, anchor_tree_node_id,
            TreeNode{bits: (old_list_tail as u128) << SHIFT_LIST_TAIL});
        let (last, next) = // Get virtual last and next fields.
            insert_list_node_get_last_next(&avlq, anchor_tree_node_id);
        // Assert last and next fields.
        assert!(last == u_64(b"11111"), 0);
        assert!(next == u_64(b"100000000001111"), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns for solo list node and allocated tree node.
    fun test_insert_list_node_get_last_next_solo_allocate() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        let (last, next) = // Get virtual last and next fields.
            insert_list_node_get_last_next(&avlq, (NIL as u64));
        // Assert last and next fields.
        assert!(last == u_64(b"100000000000001"), 0);
        assert!(next == u_64(b"100000000000001"), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns for solo list node and tree node on stack.
    fun test_insert_list_node_get_last_next_solo_stacked() {
        let avlq = new<u8>(ASCENDING, 7, 0); // Init AVL queue.
        let (last, next) = // Get virtual last and next fields.
            insert_list_node_get_last_next(&avlq, (NIL as u64));
        // Assert last and next fields.
        assert!(last == u_64(b"100000000000111"), 0);
        assert!(next == u_64(b"100000000000111"), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify return, state updates for list node that is not solo.
    fun test_insert_list_node_not_solo() {
        let avlq = new(ASCENDING, 0, 0); // Init AVL queue.
        // Declare old list tail state.
        let old_list_tail = 1;
        let anchor_tree_node_id = 321;
        let list_node_id = 2; // Declare list node ID post-allocation.
        // Manually add anchor tree node to tree nodes table.
        table_with_length::add(&mut avlq.tree_nodes, anchor_tree_node_id,
            TreeNode{bits: (old_list_tail as u128) << SHIFT_LIST_TAIL});
        // Manually add old list tail to list nodes table.
        table_with_length::add(&mut avlq.list_nodes, old_list_tail,
            ListNode{last_msbs: 0, last_lsbs: 0, next_msbs: 0, next_lsbs: 0});
        let value = 100; // Declare insertion value.
        let list_node_id_return = // Insert node, storing resultant ID.
            insert_list_node(&mut avlq, anchor_tree_node_id, value);
        // Assert return.
        assert!(list_node_id_return == list_node_id, 0);
        // Assert state updates.
        let list_node_ref = borrow_list_node_test(&avlq, list_node_id);
        let (last_assigned, is_tree_node) = get_list_last_test(list_node_ref);
        assert!(last_assigned == old_list_tail, 0);
        assert!(!is_tree_node, 0);
        let (next_assigned, is_tree_node) = get_list_next_test(list_node_ref);
        assert!(next_assigned == anchor_tree_node_id, 0);
        assert!(is_tree_node, 0);
        let old_tail_ref = borrow_list_node_test(&avlq, old_list_tail);
        (next_assigned, is_tree_node) = get_list_next_test(old_tail_ref);
        assert!(next_assigned == list_node_id, 0);
        assert!(!is_tree_node, 0);
        assert!(get_value_test(&avlq, list_node_id) == value, 0);
        let anchor_node_ref =
            borrow_tree_node_test(&avlq, anchor_tree_node_id);
        assert!(get_list_tail_test(anchor_node_ref) == list_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify return, state updates for solo list node.
    fun test_insert_list_node_solo() {
        // Declare tree node ID and list node IDs at top of inactive
        // stacks.
        let tree_node_id = 123;
        let list_node_id = 456;
        // Init AVL queue.
        let avlq = new(ASCENDING, tree_node_id, list_node_id);
        let value = 100; // Declare insertion value.
        let list_node_id_return = // Insert node, storing resultant ID.
            insert_list_node(&mut avlq, (NIL as u64), value);
        // Assert return.
        assert!(list_node_id_return == list_node_id, 0);
        // Assert state updates.
        let list_node_ref = borrow_list_node_test(&avlq, list_node_id);
        let (last_assigned, is_tree_node) = get_list_last_test(list_node_ref);
        assert!(last_assigned == tree_node_id, 0);
        assert!(is_tree_node, 0);
        let (next_assigned, is_tree_node) = get_list_next_test(list_node_ref);
        assert!(next_assigned == tree_node_id, 0);
        assert!(is_tree_node, 0);
        assert!(get_value_test(&avlq, list_node_id) == value, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Assert failure for too many list nodes.
    fun test_insert_too_many_list_nodes() {
        // Init AVL queue with max list nodes allocated.
        let avlq = new(ASCENDING, 0, N_NODES_MAX);
        // Reassign inactive list nodes stack top to null:
        avlq.bits = avlq.bits &
            (HI_128 ^ // Clear out field via mask unset at field bits.
                (((HI_NODE_ID as u128) << SHIFT_LIST_STACK_TOP) as u128));
        // Attempt invalid insertion.
        insert(&mut avlq, 0, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Assert failure for too many tree nodes.
    fun test_insert_too_many_tree_nodes() {
        // Init AVL queue with max list nodes allocated.
        let avlq = new(ASCENDING, N_NODES_MAX, 0);
        // Reassign inactive tree nodes stack top to null:
        avlq.bits = avlq.bits &
            (HI_128 ^ // Clear out field via mask unset at field bits.
                (((HI_NODE_ID as u128) << SHIFT_TREE_STACK_TOP) as u128));
        // Attempt invalid insertion.
        insert(&mut avlq, 0, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state update for inserting tree node with empty stack.
    fun test_insert_tree_node_empty() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        let tree_node_id = 1; // Declare inserted tree node ID.
        let solo_node_id = 789; // Declare solo list node ID.
        let key = 321; // Declare insertion key.
        // Insert new tree node, storing its tree node ID.
        let tree_node_id_return = insert_tree_node(
            &mut avlq, key, (NIL as u64), solo_node_id, option::none());
        // Assert inserted tree node ID.
        assert!(tree_node_id_return == tree_node_id, 0);
        // Assert new tree node state.
        assert!(get_insertion_key_by_id_test(&avlq, tree_node_id) == key, 0);
        assert!(get_parent_by_id_test(&avlq, tree_node_id) == (NIL as u64), 0);
        assert!(get_list_head_by_id_test(&avlq, tree_node_id)
                == solo_node_id, 0);
        assert!(get_list_tail_by_id_test(&avlq, tree_node_id)
                == solo_node_id, 0);
        // Assert stack top.
        assert!(get_tree_top_test(&avlq) == (NIL as u64), 0);
        // Assert root update.
        assert!(get_root_test(&avlq) == tree_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state update for inserting tree node with stack.
    fun test_insert_tree_node_stacked() {
        let tree_node_id = 123; // Declare inserted tree node ID.
        // Init AVL queue.
        let avlq = new<u8>(ASCENDING, tree_node_id, 0);
        let solo_node_id = 789; // Declare solo list node ID.
        let key = 321; // Declare insertion key.
        // Insert tree node, storing its tree node ID.
        let tree_node_id_return = insert_tree_node(
            &mut avlq, key, (NIL as u64), solo_node_id, option::none());
        // Assert inserted tree node ID.
        assert!(tree_node_id_return == tree_node_id, 0);
        // Assert tree node state.
        assert!(get_insertion_key_by_id_test(&avlq, tree_node_id) == key, 0);
        assert!(get_parent_by_id_test(&avlq, tree_node_id) == (NIL as u64), 0);
        assert!(get_list_head_by_id_test(&avlq, tree_node_id)
                == solo_node_id, 0);
        assert!(get_list_tail_by_id_test(&avlq, tree_node_id)
                == solo_node_id, 0);
        // Assert stack top.
        assert!(get_tree_top_test(&avlq) == tree_node_id - 1, 0);
        // Assert root update.
        assert!(get_root_test(&avlq) == tree_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state update for inserting left child.
    fun test_insert_tree_node_update_parent_edge_left() {
        let tree_node_id = 1234; // Declare inserted tree node ID.
        let parent = 321;
        let avlq = new<u8>(ASCENDING, parent, 0); // Init AVL queue.
        // Declare empty new leaf side.
        let new_leaf_side = option::some(LEFT);
        // Update parent to inserted node.
        insert_tree_node_update_parent_edge(
            &mut avlq, tree_node_id, parent, new_leaf_side);
        // Assert update to parent's child field.
        assert!(get_child_left_by_id_test(&avlq, parent) == tree_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state update for inserting right child.
    fun test_insert_tree_node_update_parent_edge_right() {
        let tree_node_id = 1234; // Declare inserted tree node ID.
        let parent = 321;
        let avlq = new<u8>(ASCENDING, parent, 0); // Init AVL queue.
        // Declare empty new leaf side.
        let new_leaf_side = option::some(RIGHT);
        // Update parent to inserted node.
        insert_tree_node_update_parent_edge(
            &mut avlq, tree_node_id, parent, new_leaf_side);
        // Assert update to parent's child field.
        assert!(get_child_right_by_id_test(&avlq, parent) == tree_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state update for inserting root.
    fun test_insert_tree_node_update_parent_edge_root() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        let tree_node_id = 1234; // Declare inserted tree node ID.
        let parent = (NIL as u64); // Declare parent as root flag.
        // Declare empty new leaf side.
        let new_leaf_side = option::none();
        // Assert null root.
        assert!(get_root_test(&avlq) == (NIL as u64), 0);
        // Update parent for inserted root node.
        insert_tree_node_update_parent_edge(
            &mut avlq, tree_node_id, parent, new_leaf_side);
        // Assert root update.
        assert!(get_root_test(&avlq) == tree_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful check.
    fun test_is_ascending() {
        let avlq = AVLqueue<u8>{ // Create empty AVL queue.
            bits: (NIL as u128),
            root_lsbs: NIL,
            tree_nodes: table_with_length::new(),
            list_nodes: table_with_length::new(),
            values: table::new(),
        };
        // Assert flagged descending.
        assert!(!is_ascending(&avlq), 0);
        // Flag as ascending.
        avlq.bits = u_128_by_32(
            b"01000000000000000000000000000000",
            // ^ bit 126
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000"
        );
        // Assert flagged descending.
        assert!(is_ascending(&avlq), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful initialization for no node allocations.
    fun test_new_no_nodes() {
        // Init ascending AVL queue.
        let avlq = new<u8>(ASCENDING, 0, 0);
        // Assert flagged ascending.
        assert!(is_ascending(&avlq), 0);
        // Assert null stack tops.
        assert!(get_list_top_test(&avlq) == (NIL as u64), 0);
        assert!(get_tree_top_test(&avlq) == (NIL as u64), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
        // Init descending AVL queue.
        avlq = new(DESCENDING, 0, 0);
        // Assert flagged descending.
        assert!(!is_ascending(&avlq), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful initialization for allocating tree nodes.
    fun test_new_some_nodes() {
        // Init ascending AVL queue with two nodes each.
        let avlq = new<u8>(ASCENDING, 3, 2);
        // Assert table lengths.
        assert!(table_with_length::length(&avlq.tree_nodes) == 3, 0);
        assert!(table_with_length::length(&avlq.list_nodes) == 2, 0);
        // Assert stack tops.
        assert!(get_tree_top_test(&avlq) == 3, 0);
        assert!(get_list_top_test(&avlq) == 2, 0);
        // Assert inactive tree node stack next chain.
        assert!(get_tree_next_test(borrow_tree_node_test(&avlq, 3)) == 2, 0);
        assert!(get_tree_next_test(borrow_tree_node_test(&avlq, 2)) == 1, 0);
        assert!(get_tree_next_test(borrow_tree_node_test(&avlq, 1)) ==
                (NIL as u64), 0);
        // Assert inactive list node stack next chain.
        let (node_id, is_tree_node) =
            get_list_next_test(borrow_list_node_test(&avlq, 2));
        assert!(node_id == 1, 0);
        assert!(!is_tree_node, 0);
        (node_id, is_tree_node) =
            get_list_next_test(borrow_list_node_test(&avlq, 1));
        assert!(node_id == (NIL as u64), 0);
        assert!(!is_tree_node, 0);
        // Assert value options initialize to none.
        assert!(option::is_none(borrow_value_option_test(&avlq, 2)), 0);
        assert!(option::is_none(borrow_value_option_test(&avlq, 1)), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful initialization for allocating tree nodes.
    fun test_new_some_nodes_loop() {
        // Declare number of tree and list nodes to allocate.
        let (n_tree_nodes, n_list_nodes) = (1234, 321);
        // Init ascending AVL queue accordingly.
        let avlq = new<u8>(ASCENDING, n_tree_nodes, n_list_nodes);
        // Assert table lengths.
        assert!(table_with_length::length(&avlq.tree_nodes) ==
            n_tree_nodes, 0);
        assert!(table_with_length::length(&avlq.list_nodes) ==
            n_list_nodes, 0);
        // Assert stack tops.
        assert!(get_tree_top_test(&avlq) == n_tree_nodes, 0);
        assert!(get_list_top_test(&avlq) == n_list_nodes, 0);
        let i = n_tree_nodes; // Declare loop counter.
        while (i > (NIL as u64)) { // Loop over all tree nodes in stack:
            // Assert next indicated tree node in stack.
            assert!(get_tree_next_test(borrow_tree_node_test(&avlq, i)) ==
                i - 1, 0);
            i = i - 1; // Decrement loop counter.
        };
        i = n_list_nodes; // Re-declare loop counter.
        while (i > (NIL as u64)) { // Loop over all list nodes in stack:
            // Assert next indicated list node in stack.
            let (node_id, is_tree_node) =
                get_list_next_test(borrow_list_node_test(&avlq, i));
            assert!(node_id == i - 1, 0);
            assert!(!is_tree_node, 0);
            // Assert value option initializes to none.
            assert!(option::is_none(borrow_value_option_test(&avlq, i)), 0);
            i = i - 1; // Decrement loop counter.
        };
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state updates for reference operations in `retrace()`.
    fun test_retrace_insert_remove() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node IDs.
        let node_a_id = HI_NODE_ID;
        let node_b_id = node_a_id - 1;
        let node_c_id = node_b_id - 1;
        let node_d_id = node_c_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram, with heights
        // not yet updated via insertion retrace.
        table_with_length::add(tree_nodes_ref_mut, node_a_id, TreeNode{bits:
            (        3 as u128) << SHIFT_INSERTION_KEY |
            (node_b_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, node_b_id, TreeNode{bits:
            (        4 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_a_id as u128) << SHIFT_CHILD_LEFT    |
            (node_c_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_c_id, TreeNode{bits:
            (        5 as u128) << SHIFT_INSERTION_KEY |
            (node_b_id as u128) << SHIFT_PARENT        |
            (node_d_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_d_id, TreeNode{bits:
            (        6 as u128) << SHIFT_INSERTION_KEY |
            (node_c_id as u128) << SHIFT_PARENT        });
        // Set root node ID.
        set_root_test(&mut avlq, node_b_id);
        // Retrace from node c.
        retrace(&mut avlq, node_c_id, INCREMENT, RIGHT);
        // Assert state for node a.
        assert!(get_insertion_key_by_id_test(&avlq, node_a_id) == 3, 0);
        assert!(get_height_left_by_id_test(&avlq, node_a_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_a_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_a_id) == node_b_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_a_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_a_id)
                == (NIL as u64), 0);
        // Assert state for node b.
        assert!(get_insertion_key_by_id_test(&avlq, node_b_id) == 4, 0);
        assert!(get_height_left_by_id_test(&avlq, node_b_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_b_id) == 2, 0);
        assert!(get_parent_by_id_test(&avlq, node_b_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_b_id) == node_a_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_b_id) == node_c_id, 0);
        // Assert state for node c.
        assert!(get_insertion_key_by_id_test(&avlq, node_c_id) == 5, 0);
        assert!(get_height_left_by_id_test(&avlq, node_c_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_c_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_c_id) == node_b_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_c_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_c_id) == node_d_id, 0);
        // Assert state for node d.
        assert!(get_insertion_key_by_id_test(&avlq, node_d_id) == 6, 0);
        assert!(get_height_left_by_id_test(&avlq, node_d_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_d_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_d_id) == node_c_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_d_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_d_id)
                == (NIL as u64), 0);
        // Assert root.
        assert!(get_root_test(&avlq) == node_b_id, 0);
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Simulate removing node d by clearing out node c's right child
        // field: remove and unpack node, then add new one with
        // corresponding state.
        let TreeNode{bits: _} =
            table_with_length::remove(tree_nodes_ref_mut, node_c_id);
        table_with_length::add(tree_nodes_ref_mut, node_c_id, TreeNode{bits:
            (        5 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_b_id as u128) << SHIFT_PARENT        });
        // Retrace from node c.
        retrace(&mut avlq, node_c_id, DECREMENT, RIGHT);
        // Assert state for node a.
        assert!(get_insertion_key_by_id_test(&avlq, node_a_id) == 3, 0);
        assert!(get_height_left_by_id_test(&avlq, node_a_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_a_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_a_id) == node_b_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_a_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_a_id)
                == (NIL as u64), 0);
        // Assert state for node b.
        assert!(get_insertion_key_by_id_test(&avlq, node_b_id) == 4, 0);
        assert!(get_height_left_by_id_test(&avlq, node_b_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_b_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_b_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_b_id) == node_a_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_b_id) == node_c_id, 0);
        // Assert state for node c.
        assert!(get_insertion_key_by_id_test(&avlq, node_c_id) == 5, 0);
        assert!(get_height_left_by_id_test(&avlq, node_c_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_c_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_c_id) == node_b_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_c_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_c_id)
                == (NIL as u64), 0);
        // Assert root.
        assert!(get_root_test(&avlq) == node_b_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state updates/returns for:
    ///
    /// * Side is `LEFT`.
    /// * Subtree rebalanced.
    /// * Operation is `DECREMENT`.
    /// * Actual change in height.
    fun test_retrace_prep_iterate_1() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare arguments.
        let insertion_key = HI_INSERTION_KEY;
        let parent_id = HI_NODE_ID;
        let node_id = parent_id - 1;
        let new_subtree_root = node_id - 1;
        let sibling_id = new_subtree_root - 1;
        let height = 2;
        let height_old = 3;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert parent node.
        table_with_length::add(tree_nodes_ref_mut, parent_id, TreeNode{bits:
            (insertion_key  as u128) << SHIFT_INSERTION_KEY |
            (node_id        as u128) << SHIFT_CHILD_LEFT |
            (sibling_id     as u128) << SHIFT_CHILD_RIGHT});
        // Prepare for next iteration, storing returns.
        let (node_ref_mut, operation, side, delta) = retrace_prep_iterate(
            &mut avlq, parent_id, node_id, new_subtree_root, height,
            height_old);
        // Assert insertion key accessed by mutable reference return.
        assert!(get_insertion_key_test(node_ref_mut) == insertion_key, 0);
        // Assert other returns.
        assert!(operation == DECREMENT, 0);
        assert!(side == LEFT, 0);
        assert!(delta == 1, 0);
        // Assert child fields of parent.
        assert!(get_child_left_by_id_test(&avlq, parent_id)
                == new_subtree_root, 0);
        assert!(get_child_right_by_id_test(&avlq, parent_id) == sibling_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state updates/returns for:
    ///
    /// * Side is `RIGHT`.
    /// * Subtree rebalanced.
    /// * Operation is `DECREMENT`.
    /// * No change in height.
    fun test_retrace_prep_iterate_2() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare arguments.
        let insertion_key = HI_INSERTION_KEY;
        let parent_id = HI_NODE_ID;
        let node_id = parent_id - 1;
        let new_subtree_root = node_id - 1;
        let sibling_id = new_subtree_root - 1;
        let height = 3;
        let height_old = 3;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert parent node.
        table_with_length::add(tree_nodes_ref_mut, parent_id, TreeNode{bits:
            (insertion_key  as u128) << SHIFT_INSERTION_KEY |
            (sibling_id     as u128) << SHIFT_CHILD_LEFT |
            (node_id        as u128) << SHIFT_CHILD_RIGHT});
        // Prepare for next iteration, storing returns.
        let (node_ref_mut, operation, side, delta) = retrace_prep_iterate(
            &mut avlq, parent_id, node_id, new_subtree_root, height,
            height_old);
        // Assert insertion key accessed by mutable reference return.
        assert!(get_insertion_key_test(node_ref_mut) == insertion_key, 0);
        // Assert other returns.
        assert!(operation == DECREMENT, 0);
        assert!(side == RIGHT, 0);
        assert!(delta == 0, 0);
        // Assert child fields of parent.
        assert!(get_child_left_by_id_test(&avlq, parent_id) == sibling_id, 0);
        assert!(get_child_right_by_id_test(&avlq, parent_id)
                == new_subtree_root, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state updates/returns for:
    ///
    /// * Side is `RIGHT`.
    /// * Subtree not rebalanced.
    /// * Operation is `INCREMENT`.
    fun test_retrace_prep_iterate_3() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare arguments.
        let insertion_key = HI_INSERTION_KEY;
        let parent_id = HI_NODE_ID;
        let node_id = parent_id - 1;
        let new_subtree_root = (NIL as u64);
        let height = 1;
        let height_old = 0;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert parent node.
        table_with_length::add(tree_nodes_ref_mut, parent_id, TreeNode{bits:
            (insertion_key  as u128) << SHIFT_INSERTION_KEY |
            (node_id        as u128) << SHIFT_CHILD_RIGHT});
        // Prepare for next iteration, storing returns.
        let (node_ref_mut, operation, side, delta) = retrace_prep_iterate(
            &mut avlq, parent_id, node_id, new_subtree_root, height,
            height_old);
        // Assert insertion key accessed by mutable reference return.
        assert!(get_insertion_key_test(node_ref_mut) == insertion_key, 0);
        // Assert other returns.
        assert!(operation == INCREMENT, 0);
        assert!(side == RIGHT, 0);
        assert!(delta == 1, 0);
        // Assert child fields of parent.
        assert!(get_child_left_by_id_test(&avlq, parent_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, parent_id) == node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state updates/returns for:
    ///
    /// * Left height is greater than or equal to right height
    ///   pre-retrace.
    /// * Side is `LEFT`.
    /// * Operation is `DECREMENT`.
    /// * Left height is greater than or equal to right height
    ///   post-retrace.
    fun test_retrace_update_heights_1() {
        // Declare arguments.
        let tree_node = TreeNode{bits:
            (        3 as u128) << SHIFT_HEIGHT_LEFT   |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  };
        let side = LEFT;
        let operation = DECREMENT;
        let delta = 1;
        // Update heights, storing returns.
        let (height_left, height_right, height, height_old) =
            retrace_update_heights(&mut tree_node, side, operation, delta);
        // Assert returns.
        assert!(height_left == 2, 0);
        assert!(height_right == 1, 0);
        assert!(height == 2, 0);
        assert!(height_old == 3, 0);
        // Assert node state.
        assert!(get_height_left_test(&tree_node) == 2, 0);
        assert!(get_height_right_test(&tree_node) == 1, 0);
        // Unpack tree node, dropping bits.
        let TreeNode{bits: _} = tree_node;
    }

    #[test]
    /// Verify state updates/returns for:
    ///
    /// * Left height is not greater than or equal to right height
    ///   pre-retrace.
    /// * Side is `RIGHT`.
    /// * Operation is `INCREMENT`.
    /// * Left height is not greater than or equal to right height
    ///   post-retrace.
    fun test_retrace_update_heights_2() {
        // Declare arguments.
        let tree_node = TreeNode{bits:
            (        3 as u128) << SHIFT_HEIGHT_LEFT   |
            (        4 as u128) << SHIFT_HEIGHT_RIGHT  };
        let side = RIGHT;
        let operation = INCREMENT;
        let delta = 1;
        // Update heights, storing returns.
        let (height_left, height_right, height, height_old) =
            retrace_update_heights(&mut tree_node, side, operation, delta);
        // Assert returns.
        assert!(height_left == 3, 0);
        assert!(height_right == 5, 0);
        assert!(height == 5, 0);
        assert!(height_old == 4, 0);
        // Assert node state.
        assert!(get_height_left_test(&tree_node) == 3, 0);
        assert!(get_height_right_test(&tree_node) == 5, 0);
        // Unpack tree node, dropping bits.
        let TreeNode{bits: _} = tree_node;
    }

    #[test]
    /// Verify returns/state updates for
    /// `retrace_rebalance_rotate_left()` reference rotation 1.
    fun test_rotate_left_1() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let tree_3_id = node_z_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        4 as u128) << SHIFT_INSERTION_KEY |
            (        2 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_z_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        6 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_x_id as u128) << SHIFT_PARENT        |
            (tree_3_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, tree_3_id, TreeNode{bits:
            (        8 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        // Rebalance via left rotation, storing new subtree root node ID
        // and height.
        let (node_z_id_return, node_z_height_return) =
            retrace_rebalance(&mut avlq, node_x_id, node_z_id, false);
        // Assert returns.
        assert!(node_z_id_return == node_z_id, 0);
        assert!(node_z_height_return == 1, 0);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 4, 0);
        assert!(get_height_left_by_id_test(&avlq, node_x_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_x_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_x_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_x_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_x_id)
                == (NIL as u64), 0);
        // Assert state for node z.
        assert!(get_insertion_key_by_id_test(&avlq, node_z_id) == 6, 0);
        assert!(get_height_left_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_z_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_z_id) == node_x_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_z_id) == tree_3_id, 0);
        // Assert state for tree 3.
        assert!(get_insertion_key_by_id_test(&avlq, tree_3_id) == 8, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_3_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_3_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_3_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_3_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_3_id)
                == (NIL as u64), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns/state updates for
    /// `retrace_rebalance_rotate_left()` reference rotation 2.
    fun test_rotate_left_2() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let tree_3_id = node_z_id - 1;
        let tree_2_id = tree_3_id - 1;
        let node_a_id = tree_2_id - 1;
        let node_b_id = node_a_id - 1;
        let node_c_id = node_b_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram, with heights
        // not yet updated via retrace.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        5 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (        2 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_a_id as u128) << SHIFT_PARENT        |
            (node_z_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        7 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_x_id as u128) << SHIFT_PARENT        |
            (tree_2_id as u128) << SHIFT_CHILD_LEFT    |
            (tree_3_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, tree_2_id, TreeNode{bits:
            (        6 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_3_id, TreeNode{bits:
            (        8 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, node_a_id, TreeNode{bits:
            (        3 as u128) << SHIFT_INSERTION_KEY |
            (        2 as u128) << SHIFT_HEIGHT_LEFT   |
            (        3 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_b_id as u128) << SHIFT_CHILD_LEFT    |
            (node_z_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_b_id, TreeNode{bits:
            (        2 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (node_a_id as u128) << SHIFT_PARENT        |
            (node_c_id as u128) << SHIFT_CHILD_LEFT    });
        table_with_length::add(tree_nodes_ref_mut, node_c_id, TreeNode{bits:
            (        1 as u128) << SHIFT_INSERTION_KEY |
            (node_b_id as u128) << SHIFT_PARENT        });
        // Set root node ID.
        set_root_test(&mut avlq, node_a_id);
        // Retrace from node x, rebalancing via right rotation.
        retrace(&mut avlq, node_x_id, DECREMENT, LEFT);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 5, 0);
        assert!(get_height_left_by_id_test(&avlq, node_x_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_x_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_x_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_x_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_x_id) == tree_2_id, 0);
        // Assert state for node z.
        assert!(get_insertion_key_by_id_test(&avlq, node_z_id) == 7, 0);
        assert!(get_height_left_by_id_test(&avlq, node_z_id) == 2, 0);
        assert!(get_height_right_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_z_id) == node_a_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_z_id) == node_x_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_z_id) == tree_3_id, 0);
        // Assert state for tree 3.
        assert!(get_insertion_key_by_id_test(&avlq, tree_3_id) == 8, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_3_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_3_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_3_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_3_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_3_id)
                == (NIL as u64), 0);
        // Assert state for tree 2.
        assert!(get_insertion_key_by_id_test(&avlq, tree_2_id) == 6, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_2_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_2_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_2_id) == node_x_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_2_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_2_id)
                == (NIL as u64), 0);
        // Assert state for node a.
        assert!(get_insertion_key_by_id_test(&avlq, node_a_id) == 3, 0);
        assert!(get_height_left_by_id_test(&avlq, node_a_id) == 2, 0);
        assert!(get_height_right_by_id_test(&avlq, node_a_id) == 3, 0);
        assert!(get_parent_by_id_test(&avlq, node_a_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_a_id) == node_b_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_a_id) == node_z_id, 0);
        // Assert state for node b.
        assert!(get_insertion_key_by_id_test(&avlq, node_b_id) == 2, 0);
        assert!(get_height_left_by_id_test(&avlq, node_b_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_b_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_b_id) == node_a_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_b_id) == node_c_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_b_id)
                == (NIL as u64), 0);
        // Assert state for node c.
        assert!(get_insertion_key_by_id_test(&avlq, node_c_id) == 1, 0);
        assert!(get_height_left_by_id_test(&avlq, node_c_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_c_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_c_id) == node_b_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_c_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_c_id)
                == (NIL as u64), 0);
        // Assert root.
        assert!(get_root_test(&avlq) == node_a_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns/state updates for
    /// `retrace_rebalance_rotate_left_right()` reference rotation 1.
    fun test_rotate_left_right_1() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let node_y_id = node_z_id - 1;
        let tree_1_id = node_y_id - 1;
        let tree_3_id = tree_1_id - 1;
        let tree_4_id = tree_3_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        8 as u128) << SHIFT_INSERTION_KEY |
            (        3 as u128) << SHIFT_HEIGHT_LEFT   |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_z_id as u128) << SHIFT_CHILD_LEFT    |
            (tree_4_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        2 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (        2 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_x_id as u128) << SHIFT_PARENT        |
            (tree_1_id as u128) << SHIFT_CHILD_LEFT    |
            (node_y_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_y_id, TreeNode{bits:
            (        6 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_z_id as u128) << SHIFT_PARENT        |
            (tree_3_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, tree_1_id, TreeNode{bits:
            (        1 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_3_id, TreeNode{bits:
            (        7 as u128) << SHIFT_INSERTION_KEY |
            (node_y_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_4_id, TreeNode{bits:
            (        9 as u128) << SHIFT_INSERTION_KEY |
            (node_x_id as u128) << SHIFT_PARENT        });
        // Rebalance via left-right rotation, storing new subtree root
        // node ID and height.
        let (node_y_id_return, node_y_height_return) =
            retrace_rebalance(&mut avlq, node_x_id, node_z_id, true);
        // Assert returns.
        assert!(node_y_id_return == node_y_id, 0);
        assert!(node_y_height_return == 2, 0);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 8, 0);
        assert!(get_height_left_by_id_test(&avlq, node_x_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_x_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_x_id) == node_y_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_x_id) == tree_3_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_x_id) == tree_4_id, 0);
        // Assert state for node y.
        assert!(get_insertion_key_by_id_test(&avlq, node_y_id) == 6, 0);
        assert!(get_height_left_by_id_test(&avlq, node_y_id) == 2, 0);
        assert!(get_height_right_by_id_test(&avlq, node_y_id) == 2, 0);
        assert!(get_parent_by_id_test(&avlq, node_y_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_y_id) == node_z_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_y_id) == node_x_id, 0);
        // Assert state for node z.
        assert!(get_insertion_key_by_id_test(&avlq, node_z_id) == 2, 0);
        assert!(get_height_left_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_z_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_z_id) == node_y_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_z_id) == tree_1_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_z_id)
                == (NIL as u64), 0);
        // Assert state for tree 1.
        assert!(get_insertion_key_by_id_test(&avlq, tree_1_id) == 1, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_1_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        // Assert state for tree 3.
        assert!(get_insertion_key_by_id_test(&avlq, tree_3_id) == 7, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_3_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_3_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_3_id) == node_x_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_3_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_3_id)
                == (NIL as u64), 0);
        // Assert state for tree 4.
        assert!(get_insertion_key_by_id_test(&avlq, tree_4_id) == 9, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_4_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_4_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_4_id) == node_x_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_4_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_4_id)
                == (NIL as u64), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns/state updates for
    /// `retrace_rebalance_rotate_left_right()` reference rotation 2.
    fun test_rotate_left_right_2() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let node_y_id = node_z_id - 1;
        let tree_1_id = node_y_id - 1;
        let tree_2_id = tree_1_id - 1;
        let tree_4_id = tree_2_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        8 as u128) << SHIFT_INSERTION_KEY |
            (        3 as u128) << SHIFT_HEIGHT_LEFT   |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_z_id as u128) << SHIFT_CHILD_LEFT    |
            (tree_4_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        2 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (        2 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_x_id as u128) << SHIFT_PARENT        |
            (tree_1_id as u128) << SHIFT_CHILD_LEFT    |
            (node_y_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_y_id, TreeNode{bits:
            (        6 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (node_z_id as u128) << SHIFT_PARENT        |
            (tree_2_id as u128) << SHIFT_CHILD_LEFT    });
        table_with_length::add(tree_nodes_ref_mut, tree_1_id, TreeNode{bits:
            (        1 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_2_id, TreeNode{bits:
            (        5 as u128) << SHIFT_INSERTION_KEY |
            (node_y_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_4_id, TreeNode{bits:
            (        9 as u128) << SHIFT_INSERTION_KEY |
            (node_x_id as u128) << SHIFT_PARENT        });
        // Rebalance via left-right rotation, storing new subtree root
        // node ID and height.
        let (node_y_id_return, node_y_height_return) =
            retrace_rebalance(&mut avlq, node_x_id, node_z_id, true);
        // Assert returns.
        assert!(node_y_id_return == node_y_id, 0);
        assert!(node_y_height_return == 2, 0);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 8, 0);
        assert!(get_height_left_by_id_test(&avlq, node_x_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_x_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_x_id) == node_y_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_x_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_x_id) == tree_4_id, 0);
        // Assert state for node y.
        assert!(get_insertion_key_by_id_test(&avlq, node_y_id) == 6, 0);
        assert!(get_height_left_by_id_test(&avlq, node_y_id) == 2, 0);
        assert!(get_height_right_by_id_test(&avlq, node_y_id) == 2, 0);
        assert!(get_parent_by_id_test(&avlq, node_y_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_y_id) == node_z_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_y_id) == node_x_id, 0);
        // Assert state for node z.
        assert!(get_insertion_key_by_id_test(&avlq, node_z_id) == 2, 0);
        assert!(get_height_left_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_z_id) == node_y_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_z_id) == tree_1_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_z_id) == tree_2_id, 0);
        // Assert state for tree 1.
        assert!(get_insertion_key_by_id_test(&avlq, tree_1_id) == 1, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_1_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        // Assert state for tree 2.
        assert!(get_insertion_key_by_id_test(&avlq, tree_2_id) == 5, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_2_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_2_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_2_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_2_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_2_id)
                == (NIL as u64), 0);
        // Assert state for tree 4.
        assert!(get_insertion_key_by_id_test(&avlq, tree_4_id) == 9, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_4_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_4_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_4_id) == node_x_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_4_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_4_id)
                == (NIL as u64), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns/state updates for
    /// `retrace_rebalance_rotate_right()` reference rotation 1.
    fun test_rotate_right_1() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let tree_1_id = node_z_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram, with heights
        // not yet updated via retrace.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        8 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (node_z_id as u128) << SHIFT_CHILD_LEFT    });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        6 as u128) << SHIFT_INSERTION_KEY |
            (node_x_id as u128) << SHIFT_PARENT        |
            (tree_1_id as u128) << SHIFT_CHILD_LEFT    });
        table_with_length::add(tree_nodes_ref_mut, tree_1_id, TreeNode{bits:
            (        4 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        // Set root node ID.
        set_root_test(&mut avlq, node_z_id);
        // Retrace from node z, rebalancing via right rotation.
        retrace(&mut avlq, node_z_id, INCREMENT, LEFT);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 8, 0);
        assert!(get_height_left_by_id_test(&avlq, node_x_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_x_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_x_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_x_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_x_id)
                == (NIL as u64), 0);
        // Assert state for node z.
        assert!(get_insertion_key_by_id_test(&avlq, node_z_id) == 6, 0);
        assert!(get_height_left_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_z_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_z_id) == tree_1_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_z_id) == node_x_id, 0);
        // Assert state for tree 1.
        assert!(get_insertion_key_by_id_test(&avlq, tree_1_id) == 4, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_1_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        // Assert root.
        assert!(get_root_test(&avlq) == node_z_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns/state updates for
    /// `retrace_rebalance_rotate_right()` reference rotation 2.
    fun test_rotate_right_2() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let tree_1_id = node_z_id - 1;
        let tree_2_id = tree_1_id - 2;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        7 as u128) << SHIFT_INSERTION_KEY |
            (        2 as u128) << SHIFT_HEIGHT_LEFT   |
            (NIL       as u128) << SHIFT_PARENT        |
            (node_z_id as u128) << SHIFT_CHILD_LEFT    });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        4 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_x_id as u128) << SHIFT_PARENT        |
            (tree_1_id as u128) << SHIFT_CHILD_LEFT    |
            (tree_2_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, tree_1_id, TreeNode{bits:
            (        3 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_2_id, TreeNode{bits:
            (        5 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        // Rebalance via right rotation, storing new subtree root node
        // ID and height.
        let (node_z_id_return, node_z_height_return) =
            retrace_rebalance(&mut avlq, node_x_id, node_z_id, true);
        // Assert returns.
        assert!(node_z_id_return == node_z_id, 0);
        assert!(node_z_height_return == 2, 0);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 7, 0);
        assert!(get_height_left_by_id_test(&avlq, node_x_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_x_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_x_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_x_id) == tree_2_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_x_id)
                == (NIL as u64), 0);
        // Assert state for node z.
        assert!(get_insertion_key_by_id_test(&avlq, node_z_id) == 4, 0);
        assert!(get_height_left_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_z_id) == 2, 0);
        assert!(get_parent_by_id_test(&avlq, node_z_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_z_id) == tree_1_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_z_id) == node_x_id, 0);
        // Assert state for tree 1.
        assert!(get_insertion_key_by_id_test(&avlq, tree_1_id) == 3, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_1_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        // Assert state for tree 2.
        assert!(get_insertion_key_by_id_test(&avlq, tree_2_id) == 5, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_2_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_2_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_2_id) == node_x_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_2_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_2_id)
                == (NIL as u64), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns/state updates for
    /// `retrace_rebalance_rotate_right_left()` reference rotation 1.
    fun test_rotate_right_left_1() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let node_y_id = node_z_id - 1;
        let tree_1_id = node_y_id - 1;
        let tree_2_id = tree_1_id - 1;
        let tree_4_id = tree_2_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        2 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (        3 as u128) << SHIFT_HEIGHT_RIGHT  |
            (tree_1_id as u128) << SHIFT_CHILD_LEFT    |
            (node_z_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        8 as u128) << SHIFT_INSERTION_KEY |
            (        2 as u128) << SHIFT_HEIGHT_LEFT   |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_x_id as u128) << SHIFT_PARENT        |
            (node_y_id as u128) << SHIFT_CHILD_LEFT    |
            (tree_4_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_y_id, TreeNode{bits:
            (        4 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (node_z_id as u128) << SHIFT_PARENT        |
            (tree_2_id as u128) << SHIFT_CHILD_LEFT    });
        table_with_length::add(tree_nodes_ref_mut, tree_1_id, TreeNode{bits:
            (        1 as u128) << SHIFT_INSERTION_KEY |
            (node_x_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_2_id, TreeNode{bits:
            (        3 as u128) << SHIFT_INSERTION_KEY |
            (node_y_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_4_id, TreeNode{bits:
            (        9 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        // Rebalance via right-left rotation, storing new subtree root
        // node ID and height.
        let (node_y_id_return, node_y_height_return) =
            retrace_rebalance(&mut avlq, node_x_id, node_z_id, false);
        // Assert returns.
        assert!(node_y_id_return == node_y_id, 0);
        assert!(node_y_height_return == 2, 0);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 2, 0);
        assert!(get_height_left_by_id_test(&avlq, node_x_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_x_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_x_id) == node_y_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_x_id) == tree_1_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_x_id) == tree_2_id, 0);
        // Assert state for node y.
        assert!(get_insertion_key_by_id_test(&avlq, node_y_id) == 4, 0);
        assert!(get_height_left_by_id_test(&avlq, node_y_id) == 2, 0);
        assert!(get_height_right_by_id_test(&avlq, node_y_id) == 2, 0);
        assert!(get_parent_by_id_test(&avlq, node_y_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_y_id) == node_x_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_y_id) == node_z_id, 0);
        // Assert state for node z.
        assert!(get_insertion_key_by_id_test(&avlq, node_z_id) == 8, 0);
        assert!(get_height_left_by_id_test(&avlq, node_z_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_z_id) == node_y_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_z_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, node_z_id) == tree_4_id, 0);
        // Assert state for tree 1.
        assert!(get_insertion_key_by_id_test(&avlq, tree_1_id) == 1, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_1_id) == node_x_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        // Assert state for tree 2.
        assert!(get_insertion_key_by_id_test(&avlq, tree_2_id) == 3, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_2_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_2_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_2_id) == node_x_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_2_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_2_id)
                == (NIL as u64), 0);
        // Assert state for tree 4.
        assert!(get_insertion_key_by_id_test(&avlq, tree_4_id) == 9, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_4_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_4_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_4_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_4_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_4_id)
                == (NIL as u64), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns/state updates for
    /// `retrace_rebalance_rotate_right_left()` reference rotation 2.
    fun test_rotate_right_left_2() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let node_y_id = node_z_id - 1;
        let tree_1_id = node_y_id - 1;
        let tree_3_id = tree_1_id - 1;
        let tree_4_id = tree_3_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        2 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (        3 as u128) << SHIFT_HEIGHT_RIGHT  |
            (tree_1_id as u128) << SHIFT_CHILD_LEFT    |
            (node_z_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        8 as u128) << SHIFT_INSERTION_KEY |
            (        2 as u128) << SHIFT_HEIGHT_LEFT   |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_x_id as u128) << SHIFT_PARENT        |
            (node_y_id as u128) << SHIFT_CHILD_LEFT    |
            (tree_4_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, node_y_id, TreeNode{bits:
            (        4 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_RIGHT  |
            (node_z_id as u128) << SHIFT_PARENT        |
            (tree_3_id as u128) << SHIFT_CHILD_RIGHT   });
        table_with_length::add(tree_nodes_ref_mut, tree_1_id, TreeNode{bits:
            (        1 as u128) << SHIFT_INSERTION_KEY |
            (node_x_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_3_id, TreeNode{bits:
            (        5 as u128) << SHIFT_INSERTION_KEY |
            (node_y_id as u128) << SHIFT_PARENT        });
        table_with_length::add(tree_nodes_ref_mut, tree_4_id, TreeNode{bits:
            (        9 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        // Rebalance via right-left rotation, storing new subtree root
        // node ID and height.
        let (node_y_id_return, node_y_height_return) =
            retrace_rebalance(&mut avlq, node_x_id, node_z_id, false);
        // Assert returns.
        assert!(node_y_id_return == node_y_id, 0);
        assert!(node_y_height_return == 2, 0);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 2, 0);
        assert!(get_height_left_by_id_test(&avlq, node_x_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_x_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, node_x_id) == node_y_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_x_id) == tree_1_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_x_id)
                == (NIL as u64), 0);
        // Assert state for node y.
        assert!(get_insertion_key_by_id_test(&avlq, node_y_id) == 4, 0);
        assert!(get_height_left_by_id_test(&avlq, node_y_id) == 2, 0);
        assert!(get_height_right_by_id_test(&avlq, node_y_id) == 2, 0);
        assert!(get_parent_by_id_test(&avlq, node_y_id) == (NIL as u64), 0);
        assert!(get_child_left_by_id_test(&avlq, node_y_id) == node_x_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_y_id) == node_z_id, 0);
        // Assert state for node z.
        assert!(get_insertion_key_by_id_test(&avlq, node_z_id) == 8, 0);
        assert!(get_height_left_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_height_right_by_id_test(&avlq, node_z_id) == 1, 0);
        assert!(get_parent_by_id_test(&avlq, node_z_id) == node_y_id, 0);
        assert!(get_child_left_by_id_test(&avlq, node_z_id) == tree_3_id, 0);
        assert!(get_child_right_by_id_test(&avlq, node_z_id) == tree_4_id, 0);
        // Assert state for tree 1.
        assert!(get_insertion_key_by_id_test(&avlq, tree_1_id) == 1, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_1_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_1_id) == node_x_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_1_id)
                == (NIL as u64), 0);
        // Assert state for tree 3.
        assert!(get_insertion_key_by_id_test(&avlq, tree_3_id) == 5, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_3_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_3_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_3_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_3_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_3_id)
                == (NIL as u64), 0);
        // Assert state for tree 4.
        assert!(get_insertion_key_by_id_test(&avlq, tree_4_id) == 9, 0);
        assert!(get_height_left_by_id_test(&avlq, tree_4_id) == 0, 0);
        assert!(get_height_right_by_id_test(&avlq, tree_4_id) == 0, 0);
        assert!(get_parent_by_id_test(&avlq, tree_4_id) == node_z_id, 0);
        assert!(get_child_left_by_id_test(&avlq, tree_4_id)
                == (NIL as u64), 0);
        assert!(get_child_right_by_id_test(&avlq, tree_4_id)
                == (NIL as u64), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns for reference diagram in `search()`.
    fun test_search() {
        // Init ascending AVL queue.
        let avlq = new<u8>(ASCENDING, 0, 0);
        // Assert returns for when empty.
        let (node_id, side_option) = search(&mut avlq, 12345);
        assert!(node_id == (NIL as u64), 0);
        assert!(option::is_none(&side_option), 0);
        // Manually set root.
        set_root_test(&mut avlq, 1);
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, 1, TreeNode{bits:
            (4  as u128) << SHIFT_INSERTION_KEY |
            (5  as u128) << SHIFT_CHILD_LEFT |
            (2  as u128) << SHIFT_CHILD_RIGHT});
        table_with_length::add(tree_nodes_ref_mut, 2, TreeNode{bits:
            (8  as u128) << SHIFT_INSERTION_KEY |
            (1  as u128) << SHIFT_PARENT |
            (4  as u128) << SHIFT_CHILD_LEFT |
            (3  as u128) << SHIFT_CHILD_RIGHT});
        table_with_length::add(tree_nodes_ref_mut, 3, TreeNode{bits:
            (10 as u128) << SHIFT_INSERTION_KEY |
            (2  as u128) << SHIFT_PARENT});
        table_with_length::add(tree_nodes_ref_mut, 4, TreeNode{bits:
            (6  as u128) << SHIFT_INSERTION_KEY |
            (2  as u128) << SHIFT_PARENT});
        table_with_length::add(tree_nodes_ref_mut, 5, TreeNode{bits:
            (2  as u128) << SHIFT_INSERTION_KEY |
            (1  as u128) << SHIFT_PARENT});
        // Assert returns in order from reference table.
        (node_id, side_option) = search(&mut avlq, 2);
        let node_ref = borrow_tree_node_test(&avlq, node_id);
        assert!(get_insertion_key_test(node_ref) == 2, 0);
        assert!(node_id == 5, 0);
        assert!(option::is_none(&side_option), 0);
        (node_id, side_option) = search(&mut avlq, 7);
        node_ref = borrow_tree_node_test(&avlq, node_id);
        assert!(get_insertion_key_test(node_ref) == 6, 0);
        assert!(node_id == 4, 0);
        assert!(*option::borrow(&side_option) == RIGHT, 0);
        (node_id, side_option) = search(&mut avlq, 9);
        node_ref = borrow_tree_node_test(&avlq, node_id);
        assert!(get_insertion_key_test(node_ref) == 10, 0);
        assert!(node_id == 3, 0);
        assert!(*option::borrow(&side_option) == LEFT, 0);
        (node_id, side_option) = search(&mut avlq, 4);
        node_ref = borrow_tree_node_test(&avlq, node_id);
        assert!(get_insertion_key_test(node_ref) == 4, 0);
        assert!(node_id == 1, 0);
        assert!(option::is_none(&side_option), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful state operations.
    fun test_set_get_head_tail_test() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        avlq.bits = 0; // Clear out all bits.
        // Declare head and tail keys, node IDs.
        let head_key = u_64(b"10000000000000000000000000000001");
        let tail_key = u_64(b"11000000000000000000000000000011");
        let head_node_id = u_64(b"10000000000001");
        let tail_node_id = u_64(b"11000000000011");
        // Set head and tail keys, node IDs.
        set_head_key_test(&mut avlq, head_key);
        set_tail_key_test(&mut avlq, tail_key);
        set_head_node_id_test(&mut avlq, head_node_id);
        set_tail_node_id_test(&mut avlq, tail_node_id);
        // Assert bit fields.
        assert!(avlq.bits == u_128_by_32(
            b"00000000000000000000000000000010",
            //                              ^ bit 97
            b"00000000000110000000000000000000",
            //    bit 84 ^^ bit 83
            b"00000000000111000000000011110000",
            //    bit 52 ^^ bits 38-51 ^^ bit 37
            b"00000000000000000000000011000000"), 0);
            //                         ^ bit 6
        // Assert getter returns.
        assert!(get_head_key_test(&avlq) == head_key, 0);
        assert!(get_tail_key_test(&avlq) == tail_key, 0);
        assert!(get_head_node_id_test(&avlq) == head_node_id, 0);
        assert!(get_tail_node_id_test(&avlq) == tail_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful state operations.
    fun test_set_get_root_test() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        avlq.bits = u_128_by_32( // Set all bits.
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111");
        avlq.root_lsbs = (u_64(b"11111111") as u8); // Set all bits.
        // Assert getter return.
        assert!(get_root_test(&avlq) == HI_NODE_ID, 0);
        let new_root = u_64(b"10000000000001"); // Declare new root.
        set_root_test(&mut avlq, new_root); // Set new root.
        // Assert getter return.
        assert!(get_root_test(&avlq) == new_root, 0);
        // Assert fields.
        assert!(avlq.bits == u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111100000"), 0);
        assert!(avlq.root_lsbs == (u_64(b"00000001") as u8), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify successful return values.
    fun test_u_128_64() {
        assert!(u_128(b"0") == 0, 0);
        assert!(u_128(b"1") == 1, 0);
        assert!(u_128(b"00") == 0, 0);
        assert!(u_128(b"01") == 1, 0);
        assert!(u_128(b"10") == 2, 0);
        assert!(u_128(b"11") == 3, 0);
        assert!(u_128(b"10101010") == 170, 0);
        assert!(u_128(b"00000001") == 1, 0);
        assert!(u_128(b"11111111") == 255, 0);
        assert!(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111"
        ) == HI_128, 0);
        assert!(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111110"
        ) == HI_128 - 1, 0);
        assert!(u_64(b"0") == 0, 0);
        assert!(u_64(b"0") == 0, 0);
        assert!(u_64(b"1") == 1, 0);
        assert!(u_64(b"00") == 0, 0);
        assert!(u_64(b"01") == 1, 0);
        assert!(u_64(b"10") == 2, 0);
        assert!(u_64(b"11") == 3, 0);
        assert!(u_64(b"10101010") == 170, 0);
        assert!(u_64(b"00000001") == 1, 0);
        assert!(u_64(b"11111111") == 255, 0);
        assert!(u_64_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111"
        ) == HI_64, 0);
        assert!(u_64_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111110"
        ) == HI_64 - 1, 0);
    }

    #[test]
    #[expected_failure(abort_code = 100)]
    /// Verify failure for non-binary-representative byte string.
    fun test_u_128_failure() {u_128(b"2");}

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for too many nodes.
    fun test_verify_node_count_fail() {
        // Attempt invalid invocation for one too many nodes.
        verify_node_count(u_64(b"100000000000000"));
    }

    #[test]
    /// Verify maximum node count passes check.
    fun test_verify_node_count_pass() {
        // Attempt valid invocation for max node count.
        verify_node_count(u_64(b"11111111111111"));
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}