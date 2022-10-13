module econia::funcs {


    fun insert<V>(
        avlq_ref_mut: &mut AVLqueue<V>
        key: u64,
        value: V
    ): u64 {
        // Assert insertion key is not too many bits.
        assert!(key < HI_INSERTION_KEY, E_INSERTION_KEY_TOO_LARGE);
        // Search for key, storing match node ID, and side on which a
        // new leaf would be inserted relative to match node.
        let (match_node_id, new_leaf_side) = search(avlq_ref_mut, key);
        // If search returned null from the root or flagged that a new
        // tree node will have to be activated as child, flag that the
        // activated list node will be alone in a doubly linked list.
        let solo =
            match_node_id == (NIL as u64) || (option::is_some(&new_leaf_side);
        // If a solo list node, flag no anchor tree node yet activated,
        // otherwise set anchor tree node as match node from search.
        let anchor_tree_node_id = if (solo) (NIL as u64) else match_node_id;
        let list_node_id = // Activate list node, storing its node ID.
            activate_list_node(avlq_ref_mut, anchor_tree_node_id, value);
        // Get corresponding tree node: if solo list node, activate a
        // tree node and store its ID. Otherwise tree node is match node
        // from search.
        let tree_node_id = if (solo) activate_tree_node(
            avlq_ref_mut, key, match_node_id, list_node_id, new_leaf_side);
            else match_node_id;
        // If just activated new tree node, retrace starting at the
        // parent to the activated tree node.
        if (solo) retrace(avlq_ref_mut, match_node_id, INCREMENT,
            *option::borrow(&new_leaf_side), 1);
        // Check AVL queue head and tail.
    }

    /// The `node_id` is a tree node that just underwent a
    /// modification to either its left or right height.
    fun retrace<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_id: u64,
        operation: bool, // INCREMENT or DECREMENT
        side: bool, // LEFT or RIGHT
        delta: u8
    ) {
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq_ref_mut.tree_nodes;
        // Mutably borrow node under consideration.
        let node_ref_mut =
            table_with_length::borrow_mut(nodes_ref_mut, node_id);
        loop {
            let bits = node_ref_mut.bits; // Get node's field bits.
            // Get node's left height, right height, and parent fields.
            let (height_left, height_right, parent) =
                ((((bits >> SHIFT_HEIGHT_LEFT) & HI_HEIGHT as u128) as u8),
                 (((bits >> SHIFT_HEIGHT_RIGHT) & HI_HEIGHT as u128) as u8),
                 (((bits >> SHIFT_PARENT) & (HI_NODE_ID as u128) as u64));
            let old_height = if (height_left >= height_right) height_left else
                height_right; // Get height of node before retracing.
            // Get height field and shift amount for operation side.
            let (height_field, height_shift) = if (side == LEFT)
                (height_left, SHIFT_HEIGHT_LEFT) else
                (height_right, SHIFT_HEIGHT_RIGHT) else
            // Get updated height field for side.
            let height_field if (operation == INCREMENT) height_field + delta
                else height_field - delta;
            // Reassign bits for corresponding height field.
            node_ref_mut.bits = bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID >> height_shift as u128))) |
                // Mask in new bits.
                (height_field >> BITS_PER_BYTE as u128)
            // Reassign local height to that of indicated field.
            if (side == LEFT) height_left = height_field else
                height_right = height_field;
            let height = if (height_left >= height_right) height_left else
                height_right; // Get height of node after retracing.
            // Return if node height unchanged by retrace.
            if (height == old_height) return;
            // Assume no rebalancing takes place, and thus that the node
            // remains the root of a corresponding subtree.
            let (rebalanced, new_subtree_root_node_id) = (false, node_id);
            if (height_left != height_right) { // If node not balanced:
                // Determine if node is left-heavy, and calculate the
                // imbalance of the node (the difference in height
                // between node's two subtrees).
                let (left_heavy, imbalance) = if (height_left > height_right)
                    (true, height_left - height_right),
                    (false, height_right - height_left);
                if (imbalance > 1) { // If imbalance greater than 1:
                    // Rebalance, storing node ID of new subtree root
                    // and new subtree height.
                    (new_subtree_root_node_id, height) = rebalance(
                        node_id, left_heavy);
                    rebalanced = true;
            }; // Subtree at node has been optionally rebalanced.
            // If subtree at root just rebalanced:
            if (parent == (NIL as u64) && rebalanced) {
                // Set root LSBs.
                avlq_ref_mut.root_lsbs = (new_child_to_parent & HI_BYTE as u8);
                // Reassign bits for root MSBs:
                avlq_ref_mut.bits = avlq_ref_mut.bits &
                    // Clear out field via mask unset at field bits.
                    (HI_128 ^ ((HI_NODE_ID >> BITS_PER_BYTE as u128))) |
                    // Mask in new bits.
                    (new_child_to_parent >> BITS_PER_BYTE as u128)
                return; // Stop looping.
            } else { // If not at root:
                node_ref_mut = // Mutably borrow parent node.
                    table_with_length::borrow_mut(nodes_ref_mut, parent);
                // Get parent's left child.
                let left_child = ((node_ref_mut.bits >> SHIFT_CHILD_LEFT) &
                    (HI_NODE_ID as u128) as u64);
                // Flag side on which retracing operation took place.
                side = if (left_child == node_id) LEFT else RIGHT;
                if (rebalanced) { // If subtree rebalanced:
                    // Get corresponding child field shift amount.
                    let child_shift = if (side == LEFT)
                        SHIFT_CHILD_LEFT else SHIFT_CHILD_RIGHT;
                    // Reassign bits for new child field.
                    node_ref_mut.bits = bits &
                        // Clear out field via mask unset at field bits.
                        (HI_128 ^ ((HI_NODE_ID >> child_shift as u128))) |
                        // Mask in new bits.
                        (new_subtree_root_node_id >> BITS_PER_BYTE as u128)
                }; // Parent-child edge updated.
                // Determine if retracing resulted in increment or
                // decrement to subtree height.
                operation = if (height >= old_height) INCREMENT else DECREMENT;
                // Determine change in subtree height.
                delta = if (INCREMENT) height - old_height else
                    old_height - height;
                // Store parent ID as node ID for next iteration.
                node_id = parent;
            }
        }
    }

// Rotate not update parent's child pointer, but update subtree root's
// parent pointer