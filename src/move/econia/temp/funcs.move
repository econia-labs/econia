module econia::funcs {


    fun insert<V>(
        avlq_ref_mut: &mut AVLqueue<V>
        key: u64,
        value: V
    ): u64 {
        // Assert key is 32 bits.

        // Search for key, storing match node ID, and side on which a
        // new leaf would be inserted realtive to match node.
        let (match_node_id, new_leaf_side) = search(avlq_ref_mut, key);
        // Determine if inserting at root.
        let empty = (match_node_id == (NIL as u64));
        // Solo list node if empty or if search yields a new leaf side.
        let solo = if (empty || (option::is_some(&new_leaf_side))
        let list_node_id;
        // Assume virtual last and next fields will be
        let (last, next) = ((NIL as u64), (NIL as u64));
        if (!solo) { // If not inserting a solo node:
            // Immutably borrow tree nodes table.
            let tree_nodes_ref = &avlq_ref_mut.tree_nodes;
            // Immutably borrow match node.
            let match_node_ref = table_with_length::borrow(
                tree_nodes_ref, match_node_id);
            // Get parent insertion key, encode in virtual next field.
            // Get tail node ID, encode in last field.
            // Activate a list node accordingly.
            list_node_id = activate_list_node(
                avlq_ref_mut, solo, last, next, value);
            // Update the prior list node to have new list node as next
        } else {
            list_node_id = activate_list_node(
                avlq_ref_mut, (NIL as u64), (NIL as u64), next, value);
        }
            (

            )


        // If a solo list node, activate a tree node accordingly.
        if (solo) tree_node_id = activate_tree_node(avlq_ref_mut, key,
            match_node_id, list_node_id);
    }

}