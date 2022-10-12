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
        if (solo) retrace(avlq_ref_mut, match_node_id);
        // Rebalancer should accept null node ID and just return if at
        // root?
        // Check AVL queue head and tail.
    }
}