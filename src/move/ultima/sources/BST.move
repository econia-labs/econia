// Red-black binary search tree
module Ultima::BST {

    use Std::Vector;

    // Error codes
    const E_INCORRECT_EMPTY_ROOT: u64 = 0;
    const E_INCORRECT_EMPTY_NODES: u64 = 1;

    // Node colors
    const BLACK: bool = true; // Black
    const RED: bool = false; // Red

    // Flag to indicate no node for given relationship
    const NULL: u64 = 0xffffffffffffffff;

    // A tree containing a vector of nodes, each with a key value,
    // where each node is stored at an index in the vector identical to
    // that of the correspondent value from its key-value pair
    struct Tree has store {
        root: u64, // Index of root node
        nodes: vector<Node>, // Nodes
    }

    // A single node in the tree
    struct Node has store {
        key: u64, // Key
        color: bool, // Color
        parent: u64, // Parent node index
        left: u64, // Left child node index
        right: u64, // Right child node index
    }

    // Return an empty tree
    public fun empty():
    Tree {
        Tree{root: NULL, nodes: Vector::empty<Node>()}
    }

    /*
    // Update parent node during rotation
    fun replace_parents_child(
        parent: &mut Node,
        old_child: &mut Node,
        new_child: &mut Node
    )
    */

    /*
    // Function prototype to verify argument/return types
    public fun insert<V: store>(
        k: u64,
        v: &vector<V>,
        t: &T
    ) {
        k;
        v;
        t;
    }
    */

    // Verify empty tree properly created
    #[test]
    public fun empty_success(): Tree {
        let tree = empty();
        assert!(tree.root == NULL, E_INCORRECT_EMPTY_ROOT);
        assert!(Vector::is_empty<Node>(&tree.nodes), E_INCORRECT_EMPTY_NODES);
        t
    }
}
