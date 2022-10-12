module econia::funcs {


    fun insert<V>(
        avlq_ref_mut: &mut AVLqueue<V>
        key: u64,
        value: V
    ): u64 {
        // Assert key is 32 bits.

        // Search for key, storing match node ID, and side on which a
        // new leaf would be inserted relative to match node.
        let (match_node_id, new_leaf_side) = search(avlq_ref_mut, key);
        // If search returned null from the root or flags that a new
        // tree node will have to be created as child, flag that the
        // activated list node will be alone in a doubly linked list.
        let solo =
            match_node_id == (NIL as u64) || (option::is_some(&new_leaf_side)
        // If a solo list node, flag no anchor tree node yet activated,
        // otherwise set anchor tree node as match node.
        let anchor_tree_node_id = if (solo) (NIL as u64) else match_node_id;
        let list_node_id = // Activate list node, storing its node ID.
            activate_list_node(avlq_ref_mut, anchor_tree_node_id, value);
        // Get corresponding tree node: if solo list node, activate a
        // tree node and store its ID. Otherwise is the match node ID.
        let tree_node_id = if (solo) activate_tree_node(
            avlq_ref_mut, key, match_node_id, list_node_id, new_leaf_side);
            else match_node_id;

        // Activate tree node could just be to put it as child or as
        // root, then call the rebalancer.
        // Check AVL queue head and tail.
    }
}