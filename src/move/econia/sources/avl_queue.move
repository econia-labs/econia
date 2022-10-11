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
                    next_msbs: (i >> BITS_PER_BYTE as u8),
                    next_lsbs: (i & HI_BYTE as u8)});
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
        avlq_ref.bits >> SHIFT_SORT_ORDER & (BIT_FLAG_ASCENDING as u128) ==
            (BIT_FLAG_ASCENDING as u128)
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Activate a list node and return its node ID.
    ///
    /// If inactive list node stack is empty, allocate a new list node,
    /// otherwise pop one off the inactive stack.
    ///
    /// If activated list node will be the only list node in a doubly
    /// linked list, then it will have to indicate for next and last
    /// node IDs a tree node, which will also have to be activated via
    /// `activate_tree_node()`. Hence error checking for the number of
    /// allocated tree nodes is performed here first, and is not
    /// re-performed in `activate_tree_node()`.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `solo`: If `true`, is only list node in corresponding doubly
    ///   linked list.
    /// * `last`: `ListNode.last_msbs` concatenated with
    ///   `ListNode.last_lsbs`. Overwritten if `solo` is `true`.
    /// * `next`: `ListNode.next_msbs` concatenated with
    ///   `ListNode.next_lsbs`. Overwritten if `solo` is `true`.
    /// * `value`: Insertion value for list node to activate.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of activated list node.
    ///
    /// # Assumptions
    ///
    /// * `last` and `next` are not set at any bits above 14.
    ///
    /// # Testing
    ///
    /// * `test_activate_list_node_not_solo()`
    /// * `test_activate_list_node_solo_empty_empty()`
    /// * `test_activate_list_node_solo_stacked_stacked()`
    fun activate_list_node<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        solo: bool,
        last: u64,
        next: u64,
        value: V
    ): u64 {
        // If only list node in doubly linked list, will need to
        // activate tree node having given list:
        if (solo) {
            // Get top of inactive tree nodes stack.
            let tree_node_id = ((HI_NODE_ID as u128) &
                (avlq_ref_mut.bits >> SHIFT_TREE_STACK_TOP) as u64);
            // If will need to allocate a new tree node:
            if (tree_node_id == (NIL as u64)) {
                tree_node_id = // Get new 1-indexed tree node ID.
                    table_with_length::length(&avlq_ref_mut.tree_nodes) + 1;
                // Verify tree nodes not over-allocated.
                verify_node_count(tree_node_id);
            };
            // Declare bitmask for flagging a tree node.
            let is_tree_node = (BIT_FLAG_TREE_NODE as u64) << SHIFT_NODE_TYPE;
            // Set last node ID as flagged tree node ID.
            last = tree_node_id | is_tree_node;
            // Set next node ID as flagged tree node ID.
            next = tree_node_id | is_tree_node;
        }; // Last and next arguments now overwritten if solo.
        // Mutably borrow insertion values table.
        let values_ref_mut = &mut avlq_ref_mut.values;
        // Split last and next arguments into byte fields.
        let (last_msbs, last_lsbs, next_msbs, next_lsbs) = (
            (last >> BITS_PER_BYTE as u8), (last & HI_BYTE as u8),
            (next >> BITS_PER_BYTE as u8), (next & HI_BYTE as u8));
        // Get top of inactive list nodes stack.
        let list_node_id = ((HI_NODE_ID as u128) &
            (avlq_ref_mut.bits >> SHIFT_LIST_STACK_TOP) as u64);
        // If will need to allocate a new list node:
        if (list_node_id == (NIL as u64)) {
            list_node_id = // Get new 1-indexed list node ID.
                table_with_length::length(&avlq_ref_mut.list_nodes) + 1;
            // Verify list nodes not over-allocated.
            verify_node_count(list_node_id);
            // Mutably borrow list nodes table.
            let list_nodes_ref_mut = &mut avlq_ref_mut.list_nodes;
            // Allocate a new list node with given fields.
            table_with_length::add(list_nodes_ref_mut, list_node_id, ListNode{
                last_msbs, last_lsbs, next_msbs, next_lsbs});
            // Allocate a new list node value option.
            table::add(values_ref_mut, list_node_id, option::some(value));
        } else { // If can pop inactive node off stack:
            // Mutably borrow list nodes table.
            let list_nodes_ref_mut = &mut avlq_ref_mut.list_nodes;
            // Mutably borrow inactive node at top of stack.
            let node_ref_mut = table_with_length::borrow_mut(
                list_nodes_ref_mut, list_node_id);
            let new_list_stack_top = // Get new list stack top node ID.
                ((node_ref_mut.next_msbs as u128) << BITS_PER_BYTE) |
                 (node_ref_mut.next_lsbs as u128);
            // Reassign inactive list node stack top bits:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out all bits via mask unset at relevant bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_LIST_STACK_TOP)) |
                // Mask in the new stack top bits.
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
        list_node_id // Return activated list node ID.
    }

    /// Activate a tree node and return its node ID.
    ///
    /// If inactive tree node stack is empty, allocate a new tree node,
    /// otherwise pop one off the inactive stack.
    ///
    /// Should only be called when `activate_list_node()` activates a
    /// solo list node in an AVL tree leaf.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `key`: Insertion key for activation node.
    /// * `parent`: Node ID of parent to actvation node.
    /// * `head_tail`: Node ID of sole list node in tree node's doubly
    ///   linked list.
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
    ///   via `activate_list_node()`.
    /// * `key` is not set at any bits above 31, and both other `u64`
    ///   fields are not set at any bits above 13.
    ///
    /// # Testing
    ///
    /// * `test_activate_tree_node_empty()`.
    /// * `test_activate_tree_node_stacked()`.
    fun activate_tree_node<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        key: u64,
        parent: u64,
        solo_node_id: u64
    ): u64 {
        // Pack field bits.
        let bits = (key as u128) << SHIFT_INSERTION_KEY |
            (parent as u128) << SHIFT_PARENT |
            (solo_node_id as u128) << SHIFT_LIST_HEAD |
            (solo_node_id as u128) << SHIFT_LIST_TAIL;
        // Get top of inactive tree nodes stack.
        let tree_node_id = ((HI_NODE_ID as u128) &
            (avlq_ref_mut.bits >> SHIFT_TREE_STACK_TOP) as u64);
        // If need to allocate new tree node:
        if (tree_node_id == (NIL as u64)) {
            tree_node_id = // Get new 1-indexed tree node ID.
                table_with_length::length(&avlq_ref_mut.tree_nodes) + 1;
            // Mutably borrow tree nodes table.
            let tree_nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
            table_with_length::add( // Allocate new packed tree node.
                tree_nodes_ref_mut, tree_node_id, TreeNode{bits})
        } else { // If can pop inactive node off stack:
            // Mutably borrow tree nodes table.
            let tree_nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
            // Mutably borrow inactive node at top of stack.
            let node_ref_mut = table_with_length::borrow_mut(
                tree_nodes_ref_mut, tree_node_id);
            // Get new inactive tree nodes stack top node ID.
            let new_tree_stack_top = node_ref_mut.bits & (HI_NODE_ID as u128);
            // Reassign inactive tree node stack top bits:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out all bits via mask unset at relevant bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_TREE_STACK_TOP)) |
                // Mask in the new stack top bits.
                (new_tree_stack_top << SHIFT_TREE_STACK_TOP);
            node_ref_mut.bits = bits; // Reassign activated node bits.
        };
        tree_node_id // Return activated tree node ID.
    }

    /// Search in AVL queue for closest match to seed key.
    ///
    /// Get node ID of root note, then start walking down nodes,
    /// branching left whenever the seed key is less than a node's key,
    /// right whenever the seed key is greater than a node's key, and
    /// returning when the seed key equals a node's key. Also return if
    /// there is no child to branch to on a given side.
    ///
    /// The "match" node is the node last walked before returning.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref`: Immutable reference to AVL queue.
    /// * `root_node_id`: Root tree node ID.
    /// * `seed_key`: Seed key to search for.
    ///
    /// # Returns
    ///
    /// * `u64`: Node ID of match node.
    /// * `&mut TreeNode`: Mutable reference to match node.
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
        avlq_ref_mut: &mut AVLqueue<V>,
        root_node_id: u64,
        seed_key: u64
    ): (
        u64,
        &mut TreeNode,
        Option<bool>
    ) {
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        // Begin walk at root node ID.
        let node_id = root_node_id;
        loop { // Begin walking down tree nodes:
            let node_ref_mut = // Mutably borrow node having given ID.
                table_with_length::borrow_mut(nodes_ref_mut, node_id);
            // Get insertion key encoded in search node's bits.
            let node_key = (node_ref_mut.bits >> SHIFT_INSERTION_KEY &
                (HI_INSERTION_KEY as u128) as u64);
            // If search key equals seed key, return node's ID, mutable
            // reference to it, and empty option.
            if (seed_key == node_key) return
                (node_id, node_ref_mut, option::none());
            // Get bitshift for child node ID and side based on
            // inequality comparison between seed key and node key.
            let (child_shift, child_side) = if (seed_key < node_key)
                (SHIFT_CHILD_LEFT, LEFT) else (SHIFT_CHILD_RIGHT, RIGHT);
            let child_id = (node_ref_mut.bits >> child_shift &
                (HI_NODE_ID as u128) as u64); // Get child node ID.
            // If no child on given side, return match node's ID,
            // mutable reference to it, and option with given side.
            if (child_id == (NIL as u64)) return
                (node_id, node_ref_mut, option::some(child_side));
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
    /// Return left child node ID indicated by given tree node.
    ///
    /// # Testing
    ///
    /// * `test_get_child_left_test()`
    fun get_child_left_test(
        tree_node_ref: &TreeNode
    ): u64 {
        (tree_node_ref.bits >> SHIFT_CHILD_LEFT & (HI_NODE_ID as u128) as u64)
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
        (tree_node_ref.bits >> SHIFT_CHILD_RIGHT & (HI_NODE_ID as u128) as u64)
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
        ((tree_node_ref.bits >> SHIFT_HEIGHT_LEFT) &
            (HI_HEIGHT as u128) as u8)
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
        ((tree_node_ref.bits >> SHIFT_HEIGHT_RIGHT) &
            (HI_HEIGHT as u128) as u8)
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
        ((tree_node_ref.bits >> SHIFT_INSERTION_KEY) &
            (HI_INSERTION_KEY as u128) as u64)
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
        (tree_node_ref.bits >> SHIFT_LIST_HEAD & (HI_NODE_ID as u128) as u64)
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
        let last_field = ((list_node_ref.last_msbs as u64) << BITS_PER_BYTE |
            (list_node_ref.last_lsbs as u64));
        let tree_node_flag = (last_field >> SHIFT_NODE_TYPE &
            (BIT_FLAG_TREE_NODE as u64) as u8); // Get tree node flag.
        // Return node ID, and if last node is a tree node.
        (last_field & HI_NODE_ID, tree_node_flag == BIT_FLAG_TREE_NODE)
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
        let next_field = ((list_node_ref.next_msbs as u64) << BITS_PER_BYTE |
            (list_node_ref.next_lsbs as u64));
        let tree_node_flag = (next_field >> SHIFT_NODE_TYPE &
            (BIT_FLAG_TREE_NODE as u64) as u8); // Get tree node flag.
        // Return node ID, and if next node is a tree node.
        (next_field & HI_NODE_ID, tree_node_flag == BIT_FLAG_TREE_NODE)
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
        (tree_node_ref.bits >> SHIFT_LIST_TAIL & (HI_NODE_ID as u128) as u64)
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
        ((avlq_ref.bits >> SHIFT_LIST_STACK_TOP) & (HI_NODE_ID as u128) as u64)
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
        ((tree_node_ref.bits & (HI_64 as u128) as u64) & HI_NODE_ID)
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
        ((avlq_ref.bits >> SHIFT_TREE_STACK_TOP) & (HI_NODE_ID as u128) as u64)
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
        (tree_node_ref.bits >> SHIFT_PARENT & (HI_NODE_ID as u128) as u64)
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
                r = r | 1 << (i as u8);
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
    /// Verify state updates for:
    ///
    /// * List node that is not solo.
    /// * Empty inactive tree node stack.
    /// * Empty inactive list node stack.
    fun test_activate_list_node_not_solo():
    AVLqueue<u8> {
        let list_node_id = 1; // Declare new list node ID.
        let avlq = new(ASCENDING, 0, 0); // Init AVL queue.
        let solo = false; // Declare list node that is not solo.
        let last = 321; // Declare virtual last field.
        // Declare virtual next field.
        let next_tree_node_id = 456;
        let next = next_tree_node_id |
            (BIT_FLAG_TREE_NODE as u64) << SHIFT_NODE_TYPE;
        let value = 123; // Declare insertion value.
        // Activate list node for given arguments.
        activate_list_node(&mut avlq, solo, last, next, value);
        // Assert inactive tree and list node stack tops.
        assert!(get_tree_top_test(&mut avlq) == (NIL as u64), 0);
        assert!(get_list_top_test(&mut avlq) == (NIL as u64), 0);
        // Immutably borrow list node.
        let list_node_ref = borrow_list_node_test(&avlq, list_node_id);
        // Assert last node ID indicates passed in argument.
        let (node_id, is_tree_node) = get_list_last_test(list_node_ref);
        assert!(node_id == last, 0);
        assert!(!is_tree_node, 0);
        // Assert next node ID indicates passed in argument.
        (node_id, is_tree_node) = get_list_next_test(list_node_ref);
        assert!(node_id == next_tree_node_id, 0);
        assert!(is_tree_node, 0);
        // Assert insertion value.
        assert!(get_value_test(&avlq, list_node_id) == value, 0);
        avlq // Return AVL queue.
    }

    #[test]
    /// Verify state updates for:
    ///
    /// * Solo list node.
    /// * Empty inactive tree node stack.
    /// * Empty inactive list node stack.
    fun test_activate_list_node_solo_empty_empty():
    AVLqueue<u8> {
        let tree_node_id = 1; // Declare new tree node ID.
        let list_node_id = 1; // Declare new list node ID.
        let avlq = new(ASCENDING, 0, 0); // Init AVL queue.
        let solo = true; // Declare solo list node.
        // Declare overwritten virtual last field.
        let last = (NIL as u64);
        // Declare overwritten virtual next field.
        let next = (NIL as u64);
        let value = 123; // Declare insertion value.
        // Activate list node for given arguments.
        activate_list_node(&mut avlq, solo, last, next, value);
        // Assert inactive tree and list node stack tops.
        assert!(get_tree_top_test(&mut avlq) == (NIL as u64), 0);
        assert!(get_list_top_test(&mut avlq) == (NIL as u64), 0);
        // Immutably borrow list node.
        let list_node_ref = borrow_list_node_test(&avlq, list_node_id);
        // Assert last node ID indicates new tree node.
        let (node_id, is_tree_node) = get_list_last_test(list_node_ref);
        assert!(node_id == tree_node_id, 0);
        assert!(is_tree_node, 0);
        // Assert next node ID indicates new tree node.
        (node_id, is_tree_node) = get_list_next_test(list_node_ref);
        assert!(node_id == tree_node_id, 0);
        assert!(is_tree_node, 0);
        // Assert insertion value.
        assert!(get_value_test(&avlq, list_node_id) == value, 0);
        avlq // Return AVL queue.
    }

    #[test]
    /// Verify state updates for:
    ///
    /// * Solo list node.
    /// * Non-empty inactive tree node stack.
    /// * Non-empty inactive list node stack.
    fun test_activate_list_node_solo_stacked_stacked():
    AVLqueue<u8> {
        let tree_node_id = 1234; // Declare new tree node ID.
        let list_node_id = 5678; // Declare new list node ID.
        // Init AVL queue.
        let avlq = new(ASCENDING, tree_node_id, list_node_id);
        let solo = true; // Declare solo list node.
        // Declare overwritten virtual last field.
        let last = (NIL as u64);
        let next = (NIL as u64); // Declare overwritten virtual next field.
        let value = 123; // Declare insertion value.
        // Activate list node for given arguments.
        activate_list_node(&mut avlq, solo, last, next, value);
        // Assert inactive tree and list node stack tops.
        assert!(get_tree_top_test(&mut avlq) == tree_node_id, 0);
        assert!(get_list_top_test(&mut avlq) == list_node_id - 1, 0);
        // Immutably borrow list node.
        let list_node_ref = borrow_list_node_test(&avlq, list_node_id);
        // Assert last node ID indicates new tree node.
        let (node_id, is_tree_node) = get_list_last_test(list_node_ref);
        assert!(node_id == tree_node_id, 0);
        assert!(is_tree_node, 0);
        // Assert next node ID indicates new tree node.
        (node_id, is_tree_node) = get_list_next_test(list_node_ref);
        assert!(node_id == tree_node_id, 0);
        assert!(is_tree_node, 0);
        // Assert insertion value.
        assert!(get_value_test(&avlq, list_node_id) == value, 0);
        avlq // Return AVL queue.
    }

    #[test]
    /// Verify state updates for empty inactive nodes stack.
    fun test_activate_tree_node_empty():
    AVLqueue<u8> {
        let tree_node_id = 1; // Declare tree node ID.
        // Init AVL queue.
        let avlq = new(ASCENDING, (NIL as u64), (NIL as u64));
        // Declare fields.
        let key = HI_INSERTION_KEY;
        let parent = HI_NODE_ID;
        let solo_node_id = HI_NODE_ID - 2;
        // Activate tree node, storing its node ID.
        let activated_node_id =
            activate_tree_node(&mut avlq, key, parent, solo_node_id);
        // Assert node ID.
        assert!(activated_node_id == tree_node_id, 0);
        // Assert inactive tree node stack top.
        assert!(get_tree_top_test(&mut avlq) == (NIL as u64), 0);
        // Immutably borrow tree nodes table.
        let tree_nodes_ref = &avlq.tree_nodes;
        // Assert number of allocated nodes.
        assert!(table_with_length::length(tree_nodes_ref) == tree_node_id, 0);
        // Immutably borrow tree node.
        let tree_node_ref = borrow_tree_node_test(&avlq, tree_node_id);
        // Assert packed fields.
        assert!(get_insertion_key_test(tree_node_ref) == key, 0);
        assert!(get_parent_test(tree_node_ref) == parent, 0);
        assert!(get_child_left_test(tree_node_ref) == (NIL as u64), 0);
        assert!(get_child_right_test(tree_node_ref) == (NIL as u64), 0);
        assert!(get_list_head_test(tree_node_ref) == solo_node_id, 0);
        assert!(get_list_tail_test(tree_node_ref) == solo_node_id, 0);
        assert!(get_tree_next_test(tree_node_ref) == (NIL as u64), 0);
        avlq // Return AVL queue.
    }

    #[test]
    /// Verify state updates for full inactive nodes stack.
    fun test_activate_tree_node_stacked():
    AVLqueue<u8> {
        let tree_node_id = 123; // Declare tree node ID.
        // Init AVL queue.
        let avlq = new(ASCENDING, tree_node_id, (NIL as u64));
        // Declare fields.
        let key = 456;
        let parent = 789;
        let solo_node_id = 321;
        // Activate tree node, storing its node ID.
        let activated_node_id =
            activate_tree_node(&mut avlq, key, parent, solo_node_id);
        // Assert node ID.
        assert!(activated_node_id == tree_node_id, 0);
        // Assert inactive tree node stack top.
        assert!(get_tree_top_test(&mut avlq) == tree_node_id - 1, 0);
        // Immutably borrow tree nodes table.
        let tree_nodes_ref = &avlq.tree_nodes;
        // Assert number of allocated nodes.
        assert!(table_with_length::length(tree_nodes_ref) == tree_node_id, 0);
        // Immutably borrow tree node.
        let tree_node_ref = borrow_tree_node_test(&avlq, tree_node_id);
        // Assert packed fields.
        assert!(get_insertion_key_test(tree_node_ref) == key, 0);
        assert!(get_parent_test(tree_node_ref) == parent, 0);
        assert!(get_child_left_test(tree_node_ref) == (NIL as u64), 0);
        assert!(get_child_right_test(tree_node_ref) == (NIL as u64), 0);
        assert!(get_list_head_test(tree_node_ref) == solo_node_id, 0);
        assert!(get_list_tail_test(tree_node_ref) == solo_node_id, 0);
        assert!(get_tree_next_test(tree_node_ref) == (NIL as u64), 0);
        avlq // Return AVL queue.
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
    fun test_get_list_top_test():
    AVLqueue<u8> {
        let avlq = AVLqueue{ // Create empty AVL queue.
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
        avlq // Return AVL queue.
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
    fun test_get_tree_top_test():
    AVLqueue<u8> {
        let avlq = AVLqueue{ // Create empty AVL queue.
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
        avlq // Return AVL queue.
    }

    #[test]
    /// Verify successful initialization for no node allocations.
    fun test_new_no_nodes(): (
        AVLqueue<u8>,
        AVLqueue<u8>
    ) {
        // Init ascending AVL queue.
        let avlq_ascending = new(ASCENDING, 0, 0);
        // Assert flagged ascending.
        assert!(is_ascending(&avlq_ascending), 0);
        // Assert null stack tops.
        assert!(get_list_top_test(&avlq_ascending) == (NIL as u64), 0);
        assert!(get_tree_top_test(&avlq_ascending) == (NIL as u64), 0);
        // Init descending AVL queue.
        let avlq_descending = new(DESCENDING, 0, 0);
        // Assert flagged descending.
        assert!(!is_ascending(&avlq_descending), 0);
        (avlq_ascending, avlq_descending) // Return both.
    }

    #[test]
    /// Verify successful initialization for allocating tree nodes.
    fun test_new_some_nodes(): (
        AVLqueue<u8>
    ) {
        // Init ascending AVL queue with two nodes each.
        let avlq = new(ASCENDING, 3, 2);
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
        avlq // Return AVL queue.
    }

    #[test]
    /// Verify successful initialization for allocating tree nodes.
    fun test_new_some_nodes_loop():
    AVLqueue<u8> {
        // Declare number of tree and list nodes to allocate.
        let (n_tree_nodes, n_list_nodes) = (1234, 321);
        // Init ascending AVL queue accordingly.
        let avlq = new(ASCENDING, n_tree_nodes, n_list_nodes);
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
        avlq // Return AVL queue.
    }

    #[test]
    /// Verify returns for reference diagram in `search()`.
    fun test_search():
    AVLqueue<u8> {
        // Init ascending AVL queue.
        let avlq = new(ASCENDING, 0, 0);
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
        let (node_id, node_ref_mut, side_option) = search(&mut avlq, 1, 2);
        assert!(get_insertion_key_test(node_ref_mut) == 2, 0);
        assert!(node_id == 5, 0);
        assert!(option::is_none(&side_option), 0);
        (node_id, node_ref_mut, side_option) = search(&mut avlq, 1, 7);
        assert!(get_insertion_key_test(node_ref_mut) == 6, 0);
        assert!(node_id == 4, 0);
        assert!(*option::borrow(&side_option) == RIGHT, 0);
        (node_id, node_ref_mut, side_option) = search(&mut avlq, 1, 9);
        assert!(get_insertion_key_test(node_ref_mut) == 10, 0);
        assert!(node_id == 3, 0);
        assert!(*option::borrow(&side_option) == LEFT, 0);
        (node_id, node_ref_mut, side_option) = search(&mut avlq, 1, 4);
        assert!(get_insertion_key_test(node_ref_mut) == 4, 0);
        assert!(node_id == 1, 0);
        assert!(option::is_none(&side_option), 0);
        avlq // Return AVL queue.
    }

    #[test]
    /// Verify successful check.
    fun test_is_ascending():
    AVLqueue<u8> {
        let avlq = AVLqueue{ // Create empty AVL queue.
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
        avlq // Return AVL queue.
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