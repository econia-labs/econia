/// Red-black binary search tree
module Ultima::BST {

    use Std::Vector::{
        borrow as v_b,
        borrow_mut as v_b_m,
        destroy_empty as v_d_e,
        empty as v_e,
        is_empty as v_i_e,
        length as v_l,
        pop_back as v_po_b,
        push_back as v_pu_b,
        singleton as v_s,
    };

    /// So move builder doesn't raise error in non-test mode
    fun use_v_funcs() {
        v_i_e(&v_s<u8>(1));
        v_po_b<u8>(&mut v_s<u8>(1));
        v_pu_b<u8>(&mut v_s<u8>(1), 1);
    }

    #[test]
    fun invoke_use_v_funcs() {
        use_v_funcs();
    }

// Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Flag to indicate that there is no connected node for the given
    /// relationship field (`parent`, `left`, or `right`), analagous to
    /// a null pointer
    const X: u64 = 0xffffffffffffffff;
    /// Maximum number of nodes that can be kept in the tree, equivalent
    /// to `X` - 1
    const MAX_NODES: u64 = 0xfffffffffffffffe;
    /// Flag for black node
    const B: bool = true;
    /// Flag for red node
    const R: bool = false;

// Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    const E_NEW_NOT_EMPTY: u64 = 0;
    const E_SINGLETON_NOT_EMPTY: u64 = 1;
    const E_SINGLETON_R_VAL: u64 = 2;
    const E_SINGLETON_N_VAL: u64 = 3;
    const E_DESTROY_NOT_EMPTY: u64 = 4;
    const E_L_ROTATE_NO_R_CHILD: u64 = 5;
    const E_L_ROTATE_RELATIONSHIP: u64 = 6;
    const E_L_ROTATE_ROOT: u64 = 7;

// Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A node in the binary search tree, representing a key-value pair
    /// with a `u64` key and a value of type `V`
    struct N<V> has store {
        k: u64,  // Key
        c: bool, // Black or red
        p: u64,  // Parent node index
        l: u64,  // Left child node index
        r: u64,  // Right child node index
        v: V     // Value
    }

    /// A red-black binary search tree for key-value pairs with values
    /// of type `V`
    struct BST<V> has store {
        r: u64,         // Root node index
        t: vector<N<V>> // Nodes in the tree
    }

// Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


// Initialization >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return an empty BST with key-value pair values of type `V`
    public fun empty<V>():
    BST<V> {
        BST{r: 0, t: v_e<N<V>>()}
    }

    #[test]
    /// Verify new BST created empty
    fun empty_success():
    vector<N<u8>> {
        let BST{r, t} = empty<u8>();
        // Assert root set to 0
        assert!(r == 0, E_NEW_NOT_EMPTY);
        // Assert vector of nodes is empty
        assert!(v_i_e<N<u8>>(&t), E_NEW_NOT_EMPTY);
        // Return vector of nodes rather than destroy
        t
    }

    /// Return a BST with one node having key `k` and value `v`
    public fun singleton<V>(
        k: u64,
        v: V
    ):
    BST<V> {
        // Initialize first node to black, without parent or children
        BST{r: 0, t: v_s<N<V>>(N<V>{k, c: B, p: X, l: X, r: X, v})}
    }

    #[test]
    /// Verify singleton initialized with correct values
    fun singleton_success():
    vector<N<u64>> {
        // Initialize singleton BST with key 1 and value 2
        let s = singleton<u64>(1, 2);
        // Assert singleton has length 1
        assert!(length<u64>(&s) == 1, E_SINGLETON_NOT_EMPTY);
        // Unpack the BST root value and nodes vector
        let BST{r, t} = s;
        // Assert index of root node is 0
        assert!(r == 0, E_SINGLETON_R_VAL);
        // Pop and unpack last node from the tree's vector of nodes
        let N{k, c, p, l, r, v} = v_po_b<N<u64>>(&mut t);
        // Assert values in the node are as expected
        assert!(k == 1, E_SINGLETON_N_VAL);
        assert!(c == B, E_SINGLETON_N_VAL);
        assert!(p == X, E_SINGLETON_N_VAL);
        assert!(l == X, E_SINGLETON_N_VAL);
        assert!(r == X, E_SINGLETON_N_VAL);
        assert!(v == 2, E_SINGLETON_N_VAL);
        // Return tree's vector of nodes rather than unpack
        t
    }

// Initialization <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Checking size >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return number of nodes in the BST
    public fun length<V>(
        b: &BST<V>
    ): u64 {
        // Get vector length of the BST's vector of nodes
        v_l<N<V>>(&b.t)
    }

    /// Return true if the BST has no elements
    public fun is_empty<V>(
        b: &BST<V>
    ): bool {
        length(b) == 0
    }


// Checking size <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Destruction >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Destroy the empty BST `b`
    public fun destroy_empty<V>(
        b: BST<V>
    ) {
        assert!(is_empty(&b), E_DESTROY_NOT_EMPTY);
        let BST{r: _, t} = b;
        v_d_e(t);
    }

    #[test]
    /// Verify empty BST destruction
    fun destroy_empty_success() {
        let e = empty<u8>();
        destroy_empty<u8>(e)
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify cannot destroy non-empty BST
    fun destroy_empty_fail() {
        destroy_empty<u8>(singleton<u8>(1, 2));
    }
// Destruction <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

/* Left rotation --------------------------------------------------------------

         10                                10
         / \                               / \
    (x) 5  15                         (y) 7  15
       / \         Left rotate           / \
      2   7 (y)       on 5          (x) 5   8
         / \        -------->          / \
        6   8                         2   6

*/

    /// Left rotate on the node with the given vector index
    fun left_rotate<V>(
        x_i: u64, // Index of node to left rotate on (node 5 above)
        b: &mut BST<V>
    ) {
        // Get index of x's right child (node 7 above)
        let y_i = v_b<N<V>>(&b.t, x_i).r; // Can be X
        // Assert x actually has a right child
        assert!(y_i != X, E_L_ROTATE_NO_R_CHILD);
        // Get index of y's left child, as specified by y (node 6 above)
        let y_l_i = v_b<N<V>>(&b.t, y_i).l;
        // Set x's right child as y's left child
        v_b_m<N<V>>(&mut b.t, x_i).r = y_l_i;
        if (y_l_i != X) { // If y has a left child
            // Set the child's parent to be x
            v_b_m<N<V>>(&mut b.t, y_l_i).p = x_i;
        };
        // Set x's parent to have y as child where x used to be,
        // updating y to recognize the new parent, and updating x to
        // recognize y as its new parent
        parent_child_swap(x_i, y_i, b);
        // Set y's left child as x
        v_b_m<N<V>>(&mut b.t, y_i).l = x_i;
    }

    /// Replace the bidirectional relationship between `x` and its
    /// parent with a relationship between `y` and the same parent,
    /// updating `x` to recognize `y` as a parent
    fun parent_child_swap<V>(
        x_i: u64,
        y_i: u64,
        b: &mut BST<V>
    ) {
        // Get index of x's parent as specified by x
        let x_p_i = v_b<N<V>>(&b.t, x_i).p;
        // Set y's parent as x's parent
        v_b_m<N<V>>(&mut b.t, y_i).p = x_p_i;
        if (x_p_i == X) { // If x is the root node
            b.r = y_i; // Set y as the new root node
        } else { // If x is not the root node
            // Get mutable reference to x's parent
            let x_p = v_b_m<N<V>>(&mut b.t, x_p_i);
            if (x_p.l == x_i) { // If x is a left child
                x_p.l = y_i; // Set the parent's new left child as y
            } else { // If x is a right child
                x_p.r = y_i; // Set the parent's new right child as y
            }
        };
        // Set x's parent as y
        v_b_m<N<V>>(&mut b.t, x_i).p = y_i;
    }

/*
       (z) 10                             (z) 10
           /         Left rotate             /
      (x) 5              on 5           (y) 7
           \          -------->            /
           7 (y)                     (x) 5
*/

    #[test]
    /// Verify left rotation for simple case
    fun left_rotate_simple():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the pre-rotation tree above, ignoring color and value fields:
        // (10, 0, z), (5, 1, x), (7, 2, y)
        let z = N<u8>{k: 10, c: B, p: X, l: 1, r: X, v: 0};
        let z_i = 0;
        let x = N<u8>{k:  5, c: B, p: 0, l: X, r: 2, v: 0};
        let x_i = 1;
        let y = N<u8>{k:  7, c: B, p: 1, l: X, r: X, v: 0};
        let y_i = 2;
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, z);
        v_pu_b<N<u8>>(&mut b.t, x);
        v_pu_b<N<u8>>(&mut b.t, y);
        // Perform a left rotation on x
        left_rotate<u8>(x_i, &mut b);
        // Verify root unchanged
        assert!(b.r == z_i, E_L_ROTATE_ROOT);
        // Verify z's left child is now y
        assert!(v_b<N<u8>>(&b.t, z_i).l == y_i, E_L_ROTATE_RELATIONSHIP);
        // Verify z has no other relationships
        assert!(v_b<N<u8>>(&b.t, z_i).r ==   X, E_L_ROTATE_RELATIONSHIP);
        assert!(v_b<N<u8>>(&b.t, z_i).p ==   X, E_L_ROTATE_RELATIONSHIP);
        // Verify y has left child x and parent z
        assert!(v_b<N<u8>>(&b.t, y_i).l == x_i, E_L_ROTATE_RELATIONSHIP);
        assert!(v_b<N<u8>>(&b.t, y_i).p == z_i, E_L_ROTATE_RELATIONSHIP);
        // Verify y has no right child
        assert!(v_b<N<u8>>(&b.t, y_i).r ==   X, E_L_ROTATE_RELATIONSHIP);
        // Verify x has parent y
        assert!(v_b<N<u8>>(&b.t, x_i).p == y_i, E_L_ROTATE_RELATIONSHIP);
        // Verify x has no other relationships
        assert!(v_b<N<u8>>(&b.t, x_i).r ==   X, E_L_ROTATE_RELATIONSHIP);
        assert!(v_b<N<u8>>(&b.t, x_i).l ==   X, E_L_ROTATE_RELATIONSHIP);
        // Return rather than unpack
        b
    }

}