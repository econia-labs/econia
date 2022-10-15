/// AVL queue: a hybrid between an AVL tree and a queue.
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
    /// | 89-93  | Left height (see below)              |
    /// | 84-88  | Right height (see below)             |
    /// | 70-83  | Parent node ID                       |
    /// | 56-69  | Left child node ID                   |
    /// | 42-55  | Right child node ID                  |
    /// | 28-41  | List head node ID                    |
    /// | 14-27  | List tail node ID                    |
    /// | 0-13   | Next inactive node ID, when in stack |
    ///
    /// All fields except next inactive node ID are ignored when the
    /// node is in the inactive nodes stack.
    ///
    /// # Height
    ///
    /// Left or right height denotes the height of the node's left
    /// or right subtree, respectively, plus one. Subtree height is
    /// adjusted by one to avoid negative numbers, with the resultant
    /// value denoting the height of a tree rooted at the given node,
    /// accounting only for height to the given side:
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

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ascending AVL queue flag.
    const ASCENDING: bool = true;
    /// Balance factor bits in `TreeNode.bits` indicating balance factor
    /// of 0.
    const BALANCE_FACTOR_0: u8 = 0;
    /// Balance factor bits in `TreeNode.bits` indicating balance factor
    /// of -1. Generated in Python via `hex(int('10', 2))`.
    const BALANCE_FACTOR_NEG_1: u8 = 0x2;
    /// Balance factor bits in `TreeNode.bits` indicating balance factor
    /// of 1.
    const BALANCE_FACTOR_POS_1: u8 = 1;
    /// Bit flag denoting ascending AVL queue.
    const BIT_FLAG_ASCENDING: u8 = 1;
    /// Bit flag denoting a tree node.
    const BIT_FLAG_TREE_NODE: u8 = 1;
    /// Number of bits in a byte.
    const BITS_PER_BYTE: u8 = 8;
    /// Descending AVL queue flag.
    const DESCENDING: bool = false;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// `u128` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 128, 2))`.
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// All bits set in integer of width required to encode balance
    /// factor. Generated in Python via `hex(int('1' * 2, 2))`.
    const HI_BALANCE_FACTOR: u64 = 0x3;
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
    /// Flag for left direction.
    const LEFT: bool = true;
    /// Flag for null value when null defined as 0.
    const NIL: u8 = 0;
    /// $2^{14} - 1$, the maximum number of nodes that can be allocated
    /// for either node type.
    const N_NODES_MAX: u64 = 16383;
    /// Flag for right direction.
    const RIGHT: bool = false;
    /// Number of bits sort order is shifted in `AVLqueue.bits`.
    const SHIFT_SORT_ORDER: u8 = 126;
    /// Number of bits balance factor is shifted in `TreeNode.bits`.
    const SHIFT_BALANCE_FACTOR: u8 = 84;
    /// Number of bits left child node ID is shifted in `TreeNode.bits`.
    const SHIFT_CHILD_LEFT: u8 = 56;
    /// Number of bits right child node ID is shifted in
    /// `TreeNode.bits`.
    const SHIFT_CHILD_RIGHT: u8 = 42;
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
    /// Number of bits inactive tree node stack top is shifted in
    /// `AVLqueue.bits`.
    const SHIFT_TREE_STACK_TOP: u8 = 112;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

    /// Activate a list node and return its node ID.
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
    /// * `value`: Insertion value for list node to activate.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of activated list node.
    ///
    /// # Testing
    ///
    /// * `test_activate_list_node_not_solo()`
    /// * `test_activate_list_node_solo()`
    fun activate_list_node<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        anchor_tree_node_id: u64,
        value: V
    ): u64 {
        // Get virtual last and next fields for activated list node.
        let (last, next) = activate_list_node_get_last_next(
            avlq_ref_mut, anchor_tree_node_id);
        let list_node_id = // Assign fields, store activated node ID.
            activate_list_node_assign_fields(avlq_ref_mut, last, next, value);
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
            // Reassign its next LSBs to those of activated list node.
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
        list_node_id // Return activated list node ID.
    }

    /// Assign fields when activating a list node.
    ///
    /// Inner function for `activate_list_node()`.
    ///
    /// If inactive list node stack is empty, allocate a new list node,
    /// otherwise pop one off the inactive stack.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref`: Immutable reference to AVL queue.
    /// * `last`: Virtual last field from
    ///   `activate_list_node_get_last_next()`.
    /// * `next`: Virtual next field from
    ///   `activate_list_node_get_last_next()`.
    /// * `value`: Insertion value.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of activated list node.
    ///
    /// # Testing
    ///
    /// * `test_activate_list_node_assign_fields_allocate()`
    /// * `test_activate_list_node_assign_fields_stacked()`
    fun activate_list_node_assign_fields<V>(
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

    /// Get virtual last and next fields when activating a list node.
    ///
    /// Inner function for `activate_list_node()`.
    ///
    /// If activated list node will be the only list node in a doubly
    /// linked list, a "solo list node", then it will have to indicate
    /// for next and last node IDs a new tree node, which will also have
    /// to be activated via `activate_tree_node()`. Hence error checking
    /// for the number of allocated tree nodes is performed here first,
    /// and is not re-performed in `activate_tree_node()` for the case
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
    /// * `u64`: Virtual last field of activated list node.
    /// * `u64`: Virtual next field of activated list node.
    ///
    /// # Testing
    ///
    /// * `test_activate_list_node_get_last_next_new_tail()`
    /// * `test_activate_list_node_get_last_next_solo_allocate()`
    /// * `test_activate_list_node_get_last_next_solo_stacked()`
    fun activate_list_node_get_last_next<V>(
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
        let last; // Declare virtual last field for activated list node.
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

    /// Activate a tree node and return its node ID.
    ///
    /// If inactive tree node stack is empty, allocate a new tree node,
    /// otherwise pop one off the inactive stack.
    ///
    /// Should only be called when `activate_list_node()` activates the
    /// sole list node in new AVL tree node, thus checking the number
    /// of allocated tree nodes in `activate_list_node_get_last_next()`.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `key`: Insertion key for activated node.
    /// * `parent`: Node ID of parent to actvated node, `NIL` when
    ///   activated node is to become root.
    /// * `solo_node_id`: Node ID of sole list node in tree node's
    ///   doubly linked list.
    /// * `new_leaf_side`: None if activated node is root, `LEFT` if
    ///   activated node is left child of its parent, and `RIGHT` if
    ///   activated node is right child of its parent.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of activated tree node.
    ///
    /// # Assumptions
    ///
    /// * Node is a leaf in the AVL tree and has a single list node in
    ///   its doubly linked list.
    /// * The number of allocated tree nodes has already been checked
    ///   via `activate_list_node_get_last_next()`.
    /// * All `u64` fields correspond to valid node IDs.
    ///
    /// # Testing
    ///
    /// * `test_activate_tree_node_empty()`.
    /// * `test_activate_tree_node_stacked()`.
    fun activate_tree_node<V>(
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
            node_ref_mut.bits = bits; // Reassign activated node bits.
        };
        activate_tree_node_update_parent_edge( // Update parent edge.
            avlq_ref_mut, tree_node_id, parent, new_leaf_side);
        tree_node_id // Return activated tree node ID.
    }

    /// Update the parent edge for a tree node just activated.
    ///
    /// Inner function for `activate_tree_node()`.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `tree_node_id`: Node ID of tree node just activated in
    ///   `activate_tree_node()`.
    /// * `parent`: Node ID of parent to actvation node, `NIL` when
    ///   activated node is root.
    /// * `new_leaf_side`: None if activated node is root, `LEFT` if
    ///   activated node is left child of its parent, and `RIGHT` if
    ///   activated node is right child of its parent.
    ///
    /// # Testing
    ///
    /// * `test_activate_tree_node_update_parent_edge_left()`
    /// * `test_activate_tree_node_update_parent_edge_right()`
    /// * `test_activate_tree_node_update_parent_edge_root()`
    fun activate_tree_node_update_parent_edge<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        tree_node_id: u64,
        parent: u64,
        new_leaf_side: Option<bool>
    ) {
        if (option::is_none(&new_leaf_side)) { // If activating root:
            // Set root LSBs.
            avlq_ref_mut.root_lsbs = ((tree_node_id & HI_BYTE) as u8);
            // Reassign bits for root MSBs:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID >> BITS_PER_BYTE) as u128)) |
                // Mask in new bits.
                ((tree_node_id as u128) >> BITS_PER_BYTE)
        } else { // If activating child to existing node:
            // Mutably borrow tree nodes table.
            let tree_nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
            // Mutably borrow parent.
            let parent_ref_mut = table_with_length::borrow_mut(
                tree_nodes_ref_mut, parent);
            // Determine if activating left child.
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

    /// Rebalance a subtree, returning new root and height.
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
    fun rebalance<V>(
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
                rotate_left_right(avlq_ref_mut, node_x_id, node_z_id,
                                  node_z_child_right, node_z_height_left) else
                // Otherwise node z is not right-heavy so rotate right.
                rotate_right(avlq_ref_mut, node_x_id, node_z_id,
                              node_z_child_right, node_z_height_right))
            else // If node x is right-heavy:
            // If node z is left-heavy, rotate right-left
            (if (node_z_height_left > node_z_height_right)
                rotate_right_left(avlq_ref_mut, node_x_id, node_z_id,
                                  node_z_child_left, node_z_height_right) else
                // Otherwise node z is not left-heavy so rotate left.
                rotate_left(avlq_ref_mut, node_x_id, node_z_id,
                             node_z_child_left, node_z_height_left)))
    }

    /// Rotate left during rebalance.
    ///
    /// Inner function for `rebalance()`.
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
    ///
    /// Pre-rotation:
    ///
    /// >               4 <- node x
    /// >                \
    /// >                 7 <- node z
    /// >                / \
    /// >     tree 2 -> 6   8 <- tree 3
    ///
    /// Post-rotation:
    ///
    /// >                 7 <- node z
    /// >                / \
    /// >     node x -> 4   8 <- tree 3
    /// >                \
    /// >                 6 <- tree 2
    ///
    /// # Testing
    ///
    /// * `test_rotate_left_1()`
    /// * `test_rotate_left_2()`
    fun rotate_left<V>(
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
            (HI_NODE_ID as u128)) as u8); // Get node x parent field.
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
    /// Inner function for `rebalance()`.
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
    fun rotate_left_right<V>(
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
            (HI_NODE_ID as u128)) as u8); // Store node x parent field.
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
    /// Inner function for `rebalance()`.
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
    fun rotate_right<V>(
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
            (HI_NODE_ID as u128)) as u8); // Get node x parent field.
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
    /// Inner function for `rebalance()`.
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
    fun rotate_right_left<V>(
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
            (HI_NODE_ID as u128)) as u8); // Store node x parent field.
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
    /// * `u64`: Node ID of match node.
    /// * `Option<bool>`: None if match key equals seed key, `LEFT` if
    ///   seed key is less than match key but match node has no left
    ///   child, `RIGHT` if seed key is greater than match key but match
    ///   node has no right child.
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
    /// Verify return and state updates for allocating new list node.
    fun test_activate_list_node_assign_fields_allocate() {
        let avlq = new(ASCENDING, 0, 0); // Init AVL queue.
        // Declare inputs.
        let value = 123;
        let last = 456;
        let next = 789;
        // Assign fields to activated list node, store its ID.
        let list_node_id = activate_list_node_assign_fields(
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
    /// Verify return and state updates for activating stack top.
    fun test_activate_list_node_assign_fields_stacked() {
        let stack_top_id = 321;
        let avlq = new(ASCENDING, 0, stack_top_id); // Init AVL queue.
        // Declare inputs.
        let value = 123;
        let last = 456;
        let next = 789;
        // Assign fields to activated list node, store its ID.
        let list_node_id = activate_list_node_assign_fields(
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
    fun test_activate_list_node_get_last_next_new_tail() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        let anchor_tree_node_id = 15; // Declare anchor tree node ID.
        let old_list_tail = 31; // Declare old list tail node ID.
        // Manually add anchor tree node to tree nodes table.
        table_with_length::add(&mut avlq.tree_nodes, anchor_tree_node_id,
            TreeNode{bits: (old_list_tail as u128) << SHIFT_LIST_TAIL});
        let (last, next) = // Get virtual last and next fields.
            activate_list_node_get_last_next(&avlq, anchor_tree_node_id);
        // Assert last and next fields.
        assert!(last == u_64(b"11111"), 0);
        assert!(next == u_64(b"100000000001111"), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns for solo list node and allocated tree node.
    fun test_activate_list_node_get_last_next_solo_allocate() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        let (last, next) = // Get virtual last and next fields.
            activate_list_node_get_last_next(&avlq, (NIL as u64));
        // Assert last and next fields.
        assert!(last == u_64(b"100000000000001"), 0);
        assert!(next == u_64(b"100000000000001"), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns for solo list node and tree node on stack.
    fun test_activate_list_node_get_last_next_solo_stacked() {
        let avlq = new<u8>(ASCENDING, 7, 0); // Init AVL queue.
        let (last, next) = // Get virtual last and next fields.
            activate_list_node_get_last_next(&avlq, (NIL as u64));
        // Assert last and next fields.
        assert!(last == u_64(b"100000000000111"), 0);
        assert!(next == u_64(b"100000000000111"), 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify return, state updates for solo list node.
    fun test_activate_list_node_solo() {
        // Declare tree node ID and list node IDs at top of
        // inactive stacks.
        let tree_node_id = 123;
        let list_node_id = 456;
        // Init AVL queue.
        let avlq = new(ASCENDING, tree_node_id, list_node_id);
        let value = 100; // Declare insertion value.
        let list_node_id_return =
            activate_list_node(&mut avlq, (NIL as u64), value);
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
    /// Verify return, state updates for list node that is not solo.
    fun test_activate_list_node_not_solo() {
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
        let list_node_id_return =
            activate_list_node(&mut avlq, anchor_tree_node_id, value);
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
    /// Verify state update for activating tree node with empty stack.
    fun test_activate_tree_node_empty() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        let tree_node_id = 1; // Declare activated tree node ID.
        let solo_node_id = 789; // Declare solo list node ID.
        let key = 321; // Declare insertion key.
        // Activate new tree node, storing its tree node ID.
        let tree_node_id_return = activate_tree_node(
            &mut avlq, key, (NIL as u64), solo_node_id, option::none());
        // Assert activated tree node ID.
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
    /// Verify state update for activating tree node with stack.
    fun test_activate_tree_node_stacked() {
        let tree_node_id = 123; // Declare activated tree node ID.
        // Init AVL queue.
        let avlq = new<u8>(ASCENDING, tree_node_id, 0);
        let solo_node_id = 789; // Declare solo list node ID.
        let key = 321; // Declare insertion key.
        // Activate new tree node, storing its tree node ID.
        let tree_node_id_return = activate_tree_node(
            &mut avlq, key, (NIL as u64), solo_node_id, option::none());
        // Assert activated tree node ID.
        assert!(tree_node_id_return == tree_node_id, 0);
        // Assert new tree node state.
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
    /// Verify state update for activating left child.
    fun test_activate_tree_node_update_parent_edge_left() {
        let tree_node_id = 1234; // Declare activated tree node ID.
        let parent = 321;
        let avlq = new<u8>(ASCENDING, parent, 0); // Init AVL queue.
        // Declare empty new leaf side.
        let new_leaf_side = option::some(LEFT);
        // Update parent to activated node.
        activate_tree_node_update_parent_edge(
            &mut avlq, tree_node_id, parent, new_leaf_side);
        // Assert update to parent's child field.
        assert!(get_child_left_by_id_test(&avlq, parent) == tree_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state update for activating right child.
    fun test_activate_tree_node_update_parent_edge_right() {
        let tree_node_id = 1234; // Declare activated tree node ID.
        let parent = 321;
        let avlq = new<u8>(ASCENDING, parent, 0); // Init AVL queue.
        // Declare empty new leaf side.
        let new_leaf_side = option::some(RIGHT);
        // Update parent to activated node.
        activate_tree_node_update_parent_edge(
            &mut avlq, tree_node_id, parent, new_leaf_side);
        // Assert update to parent's child field.
        assert!(get_child_right_by_id_test(&avlq, parent) == tree_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify state update for activating root.
    fun test_activate_tree_node_update_parent_edge_root() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        let tree_node_id = 1234; // Declare activated tree node ID.
        let parent = (NIL as u64); // Declare parent as root flag.
        // Declare empty new leaf side.
        let new_leaf_side = option::none();
        // Assert null root.
        assert!(get_root_test(&avlq) == (NIL as u64), 0);
        // Update parent for activated root node.
        activate_tree_node_update_parent_edge(
            &mut avlq, tree_node_id, parent, new_leaf_side);
        // Assert root update.
        assert!(get_root_test(&avlq) == tree_node_id, 0);
        drop_avlq_test(avlq); // Drop AVL queue.
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
    /// Verify returns/state updates for reference rotation 1.
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
            rebalance(&mut avlq, node_x_id, node_z_id, false);
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
    /// Verify returns/state updates for reference rotation 2.
    fun test_rotate_left_2() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let tree_3_id = node_z_id - 1;
        let tree_2_id = tree_3_id - 2;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        4 as u128) << SHIFT_INSERTION_KEY |
            (        2 as u128) << SHIFT_HEIGHT_RIGHT  |
            (NIL       as u128) << SHIFT_PARENT        |
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
        // Rebalance via left rotation, storing new subtree root node ID
        // and height.
        let (node_z_id_return, node_z_height_return) =
            rebalance(&mut avlq, node_x_id, node_z_id, false);
        // Assert returns.
        assert!(node_z_id_return == node_z_id, 0);
        assert!(node_z_height_return == 2, 0);
        // Assert state for node x.
        assert!(get_insertion_key_by_id_test(&avlq, node_x_id) == 4, 0);
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
        // Assert state for tree 2.
        assert!(get_insertion_key_by_id_test(&avlq, tree_2_id) == 6, 0);
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
    /// Verify returns/state updates for reference rotation 1.
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
            rebalance(&mut avlq, node_x_id, node_z_id, true);
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
    /// Verify returns/state updates for reference rotation 2.
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
            rebalance(&mut avlq, node_x_id, node_z_id, true);
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
    /// Verify returns/state updates for reference rotation 1.
    fun test_rotate_right_1() {
        let avlq = new<u8>(ASCENDING, 0, 0); // Init AVL queue.
        // Declare node/tree IDs.
        let node_x_id = HI_NODE_ID;
        let node_z_id = node_x_id - 1;
        let tree_1_id = node_z_id - 1;
        // Mutably borrow tree nodes table.
        let tree_nodes_ref_mut = &mut avlq.tree_nodes;
        // Manually insert nodes from reference diagram.
        table_with_length::add(tree_nodes_ref_mut, node_x_id, TreeNode{bits:
            (        8 as u128) << SHIFT_INSERTION_KEY |
            (        2 as u128) << SHIFT_HEIGHT_LEFT   |
            (node_z_id as u128) << SHIFT_CHILD_LEFT    });
        table_with_length::add(tree_nodes_ref_mut, node_z_id, TreeNode{bits:
            (        6 as u128) << SHIFT_INSERTION_KEY |
            (        1 as u128) << SHIFT_HEIGHT_LEFT   |
            (node_x_id as u128) << SHIFT_PARENT        |
            (tree_1_id as u128) << SHIFT_CHILD_LEFT    });
        table_with_length::add(tree_nodes_ref_mut, tree_1_id, TreeNode{bits:
            (        4 as u128) << SHIFT_INSERTION_KEY |
            (node_z_id as u128) << SHIFT_PARENT        });
        // Rebalance via right rotation, storing new subtree root node
        // ID and height.
        let (node_z_id_return, node_z_height_return) =
            rebalance(&mut avlq, node_x_id, node_z_id, true);
        // Assert returns.
        assert!(node_z_id_return == node_z_id, 0);
        assert!(node_z_height_return == 1, 0);
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
        drop_avlq_test(avlq); // Drop AVL queue.
    }

    #[test]
    /// Verify returns/state updates for reference rotation 2.
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
            rebalance(&mut avlq, node_x_id, node_z_id, true);
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
    /// Verify returns/state updates for reference rotation 1.
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
            rebalance(&mut avlq, node_x_id, node_z_id, false);
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
    /// Verify returns/state updates for reference rotation 2.
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
            rebalance(&mut avlq, node_x_id, node_z_id, false);
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
    fun test_verify_new_node_id_pass() {
        // Attempt valid invocation for max node count.
        verify_node_count(u_64(b"11111111111111"));
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}