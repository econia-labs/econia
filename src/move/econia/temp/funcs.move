module econia::funcs {

    /// Remove tree node from an AVL queue.
    ///
    /// Inner function for `remove()`.
    ///
    /// # Parameters
    ///
    /// * `avlq_ref_mut`: Mutable reference to AVL queue.
    /// * `node_x_id`: Mutable reference to node to remove.
    ///
    /// Here, node x refers to the node to remove from the tree. Node
    /// x may have a parent node or may be the tree root, and may have
    /// either 0, 1 or 2 children.
    ///
    /// >        |
    /// >        x
    /// >       / \
    ///
    /// # Case 1
    ///
    /// Node x has no children. Here, the parent to node x gets updated
    /// to have as its child on the corresponding side a null subtree.
    /// If node x has no parent the tree is completely cleared out,
    /// otherwise, a decrement retrace starts from node x's pre-removal
    /// parent on the corresponding side.
    ///
    /// # Case 2
    ///
    /// Node x has a single child node. Here, the parent to node x gets
    /// updated to have as its child on the corresponding side node x's
    /// sole child pre-removal. If node x has no parent the tree is
    /// completely cleared out, otherwise a decrement retrace starts
    /// from node x's pre-removal parent on the corresponding side.
    ///
    /// ## Left child
    ///
    /// Pre-removal:
    ///
    /// >     |
    /// >     x
    /// >    /
    /// >   l
    ///
    /// Post-removal:
    ///
    /// >     |
    /// >     l
    ///
    /// ## Right child
    ///
    /// Pre-removal:
    ///
    /// >     |
    /// >     x
    /// >      \
    /// >       r
    ///
    /// Post-removal:
    ///
    /// >     |
    /// >     r
    ///
    /// # Case 3
    ///
    /// Node x has two children. Handled by
    /// `remove_tree_node_with_children()`.
    fun remove_tree_node<V>(
        avlq_ref_mut: &mut AVLqueue<V>,
        node_x_id: u64
    ) {
        // Mutably borrow tree nodes table.
        let nodes_ref_mut = &mut avlq.tree_nodes;
        let node_x_ref_mut = table_with_length::borrow_mut(
            nodes_ref_mut, node_x_id); // Mutably borrow node x.
        let bits = node_x_ref_mut.bits; // Get node x bits.
        // Get node x's left height, right height, parent, and children
        // fields.
        let (node_x_height_left, node_x_height_right, node_x_parent
             node_x_child_left , node_x_child_right) =
            (((bits >> SHIFT_HEIGHT_LEFT ) & (HI_HEIGHT  as u128) as u8),
             ((bits >> SHIFT_HEIGHT_RIGHT) & (HI_HEIGHT  as u128) as u8),
             ((bits >> SHIFT_PARENT      ) & (HI_NODE_ID as u128) as u64),
             ((bits >> SHIFT_CHILD_LEFT  ) & (HI_NODE_ID as u128) as u64),
             ((bits >> SHIFT_CHILD_RIGHT ) & (HI_NODE_ID as u128) as u64));
        // Determine if node x has left child.
        let has_child_left  = node_x_child_left  != (NIL as u64);
        // Determine if node x has right child.
        let has_child_right = node_x_child_right != (NIL as u64);
        // Assume case 1: node x is leaf node replaced by null subtree,
        // requiring decrement retrace on side that node x was child.
        let (new_subtree_root, retrace_node_id) = ((NIL as u64), parent);
        let retrace_side; // Declare retrace side, looked up later.
        if (has_child_left ^ has_child_right) { // If only 1 child:
            new_subtree_root = if (has_child_left) node_x_child_left else
                node_x_child_right; // New subtree root is the child.
            // Mutably borrow child.
            let child_ref_mut = table_with_length::borrow_mut(
                nodes_ref_mut, new_subtree_root);
            // Reassign bits for new parent field.
            child_ref_mut.bits = child_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_PARENT)) |
                // Mask in new bits.
                ((node_x_parent as u128) << SHIFT_PARENT);
        }; // Case 2 done: decrement retrace at parent on node x's side.
        // If node x has left and right child remove node per case 3,
        // storing new subtree root, retrace node ID, and retrace side.
        if (has_child_left && has_child_right)
            (new_subtree_root, retrace_node_id, retrace_side) =
            remove_tree_node_with_children(
                avlq_ref_mut, node_x_height_left, node_x_height_right,
                node_x_parent, node_x_child_left, node_x_child_right);
        if (parent == (NIL as u64)) { // If node x was tree root:
            // Reassign bits for root MSBs:
            avlq_ref_mut.bits = avlq_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) >> BITS_PER_BYTE)) |
                // Mask in new bits.
                ((new_subtree_root as u128) >> BITS_PER_BYTE);
            avlq_ref_mut.root_lsbs = // Set AVL queue root LSBs.
                (new_subtree_root & HI_BYTE as u8);
        } else { // If node x was not root:
            // Mutably borrow node x's parent.
            let parent_ref_mut = table_with_length::borrow_mut(
                nodes_ref_mut, new_subtree_root);
            // Get parent's left child.
            let parent_left_child = (((parent_ref_mut.bits >> SHIFT_CHILD_LEFT)
                & (HI_NODE_ID as u128)) as u64);
            // Get child shift based on node x's side as a child.
            let child_shift = if (parent_left_child == node_x_id)
                SHIFT_CHILD_LEFT else SHIFT_CHILD_RIGHT;
            // Reassign bits for new child field.
            node_ref_mut.bits = node_ref_mut.bits &
                // Clear out field via mask unset at field bits.
                (HI_128 ^ ((HI_NODE_ID as u128) << child_shift)) |
                // Mask in new bits.
                ((new_subtree_root as u128) << child_shift)
            // If retrace node id is node x's parent, then case 1 or
            // case 2, so retrace side is side on which x was child.
            if (retrace_node_id == parent) retrace_side =
                if (parent_left_child == node_x_id) LEFT else RIGHT;
        }; // Parent edge updated, retrace side assigned if needed.
        if (retrace_node_id != (NIL as u64)) // Retrace if needed.
            retrace(avlq_ref_mut, retrace_node_id, DECREMENT, retrace_side);
        // Get inactive tree nodes stack top.
        let tree_top = (((avlq_ref_mut.bits >> SHIFT_TREE_STACK_TOP) &
            (HI_NODE_ID as u128)) as u64);
        // Set node x to indicate the next inactive tree node in stack.
        node_x_ref_mut.bits = (tree_top as u128);
        // Reassign bits for inactive tree node stack top:
        avlq_ref_mut.bits = avlq_ref_mut.bits &
            // Clear out field via mask unset at field bits.
            (HI_128 ^ ((HI_NODE_ID as u128) << SHIFT_TREE_STACK_TOP)) |
            // Mask in new bits.
            ((node_x_id as u128) << SHIFT_LIST_STACK_TOP);
    }

    /// Replace node x with its predecessor in preparation for retrace.
    ///
    /// Here, node x is the node to remove, having left child node l and
    /// right child node r.
    ///
    /// >           |
    /// >           x
    /// >          / \
    /// >         l   r
    ///
    /// # Case 1
    ///
    /// Node l does not have a right child, but has left child tree l
    /// which may or may not be empty.
    ///
    /// >           |
    /// >           x
    /// >          / \
    /// >         l   r
    /// >        /
    /// >     t_l
    ///
    /// Here, node l takes the place of node x, with node l's left
    /// height and right height set to those of node x pre-removal. Then
    /// a left decrement retrace is initiated at node l.
    ///
    /// >         |
    /// >         l
    /// >        / \
    /// >     t_l   r
    ///
    /// # Case 2
    ///
    /// Node l has a right child, with node y as the maximum node in the
    /// corresponding subtree. Node y has no right child, but has as its
    /// left child tree y, which may or may not be empty. Node y may or
    /// may not have node l as its parent.
    ///
    /// >           |
    /// >           x
    /// >          / \
    /// >         l   r
    /// >        / \
    /// >     t_l   ~
    /// >            \
    /// >             y
    /// >            /
    /// >         t_y
    ///
    /// Here, node y takes the place of node x, with node y's left
    /// height and right height updated to those of node x pre-removal.
    /// Tree y then takes the place of y, and a right decrement retrace
    /// is initiated at node y's pre-removal parent.
    ///
    /// >           |
    /// >           y
    /// >          / \
    /// >         l   r
    /// >        / \
    /// >     t_l   ~
    /// >            \
    /// >             t_y
    ///
    fun remove_tree_node_with_children(
        _avlq_ref_mut: &mut AVLqueue<V>,
        _node_x_id: u64,
        _node_x_height_left: u8,
        _node_x_height_right: u8,
        _node_x_parent: u64,
        _node_l_id: u64,
        _node_r_id: u64,
    ): (
        u64, // New subtree root
        u64, // Retrace node
        bool // Retrace side
    ) {
        (0, 0, true)
    }


}
