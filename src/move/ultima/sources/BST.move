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
    const NIL: u64 = 0xffffffffffffffff;
    /// Maximum number of nodes that can be kept in the tree, equivalent
    /// to `NIL` - 1
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
    const E_R_ROTATE_NO_L_CHILD: u64 = 8;
    const E_R_ROTATE_RELATIONSHIP: u64 = 9;
    const E_R_ROTATE_ROOT: u64 = 10;

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
        BST{r: 0, t: v_s<N<V>>(N<V>{k, c: B, p: NIL, l: NIL, r: NIL, v})}
    }

    #[test]
    /// Verify singleton initialized with correct values
    fun singleton_success():
    vector<N<u8>> {
        // Initialize singleton BST with key 1 and value 2
        let s = singleton<u8>(1, 2);
        // Assert singleton has length 1
        assert!(length<u8>(&s) == 1, E_SINGLETON_NOT_EMPTY);
        // Unpack the BST root value and nodes vector
        let BST{r, t} = s;
        // Assert index of root node is 0
        assert!(r == 0, E_SINGLETON_R_VAL);
        // Pop and unpack last node from the tree's vector of nodes
        let N{k, c, p, l, r, v} = v_po_b<N<u8>>(&mut t);
        // Assert values in the node are as expected
        assert!(k == 1, E_SINGLETON_N_VAL);
        assert!(c == B, E_SINGLETON_N_VAL);
        assert!(p == NIL, E_SINGLETON_N_VAL);
        assert!(l == NIL, E_SINGLETON_N_VAL);
        assert!(r == NIL, E_SINGLETON_N_VAL);
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

// Helper functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return vector index of parent to node at index `n_i`, within
    /// BST `b``
    fun get_p<V>(
        b: &BST<V>,
        n_i: u64
    ): u64 {
        v_b<N<V>>(&b.t, n_i).p
    }

    /// Return vector index of left child to node at index `n_i`, within
    /// BST `b`
    fun get_l<V>(
        b: &BST<V>,
        n_i: u64
    ): u64 {
        v_b<N<V>>(&b.t, n_i).l
    }

    /// Return vector index of right child to node at index `n_i`,
    /// within BST `b`
    fun get_r<V>(
        b: &BST<V>,
        n_i: u64
    ): u64 {
        v_b<N<V>>(&b.t, n_i).r
    }

    /// Return mutable reference to node at vector index `n_i` in BST
    /// `b`
    fun get_m<V>(
        b: &mut BST<V>,
        n_i: u64
    ): &mut N<V> {
        v_b_m<N<V>>(&mut b.t, n_i)
    }

    /// Set node at vector index `n_i` to have parent at index `p_i`,
    /// within BST `b`
    fun set_p<V>(
        b: &mut BST<V>,
        n_i: u64,
        p_i: u64
    ) {
        v_b_m<N<V>>(&mut b.t, n_i).p = p_i;
    }

    /// Set node at vector index `n_i` to have left child at index
    /// `l_i`, within BST `b`
    fun set_l<V>(
        b: &mut BST<V>,
        n_i: u64,
        l_i: u64
    ) {
        v_b_m<N<V>>(&mut b.t, n_i).l = l_i;
    }

    /// Set node at vector index `n_i` to have right child at index
    /// `l_i`, within BST `b`
    fun set_r<V>(
        b: &mut BST<V>,
        n_i: u64,
        r_i: u64
    ) {
        v_b_m<N<V>>(&mut b.t, n_i).r = r_i;
    }

// Helper functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

/* Left rotation >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

     (z) 10                            (z) 10
         / \                               / \
    (x) 5  15                         (y) 7  15
       / \         Left rotate           / \
      2   7 (y)       on x          (x) 5   8
         / \        -------->          / \
    (w) 6   8                         2   6 (w)

*/

    /// Left rotate on the node with the given vector index
    fun l_rotate<V>(
        x_i: u64, // Index of node to left rotate on
        b: &mut BST<V>
    ) {
        // Get index of x's right child (y)
        let y_i = get_r<V>(b, x_i);
        // Assert x actually has a right child
        assert!(y_i != NIL, E_L_ROTATE_NO_R_CHILD);
        // Get index of y's left child (w)
        let w_i = get_l<V>(b, y_i);
        // Set x's right child as w
        set_r<V>(b, x_i, w_i);
        if (w_i != NIL) { // If y has a left child (if w is not null)
            // Set w's parent to be x
            set_p<V>(b, w_i, x_i);
        };
        // Swap the parent relationship between x and z to y
        parent_child_swap(x_i, y_i, b);
        // Set y's left child as x
        set_l<V>(b, y_i, x_i);
    }

    /// Replace the bidirectional relationship between `x` and its
    /// parent with a relationship between `y` and the same parent,
    /// updating `x` to recognize `y` as a parent
    fun parent_child_swap<V>(
        x_i: u64,
        y_i: u64,
        b: &mut BST<V>
    ) {
        // Get index of x's parent (z)
        let z_i = get_p<V>(b, x_i);
        // Set y's parent as z
        set_p<V>(b, y_i, z_i);
        if (z_i == NIL) { // If x is the root node
            b.r = y_i; // Set y as the new root node
        } else { // If x is not the root node
            // Get mutable reference to z
            let z = get_m<V>(b, z_i);
            if (z.l == x_i) { // If x is a left child
                z.l = y_i; // Set z's new left child as y
            } else { // If x is a right child
                z.r = y_i; // Set z's new right child as y
            }
        };
        // Set x's parent as y
        set_p<V>(b, x_i, y_i);
    }

/*
       (z) 10                             (z) 10
           /         Left rotate             /
      (x) 5              on x           (y) 7
           \          -------->            /
            7 (y)                     (x) 5
           /                               \
          6 (w)                             6 (w)
*/

    #[test]
    /// Verify successful left rotation
    fun l_rotate_success():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the pre-rotation tree above, ignoring color and value fields:
        // (10, 0, z), (5, 1, x), (7, 2, y), (6, 3, w)
        let z_i = 0;
        let x_i = 1;
        let y_i = 2;
        let w_i = 3;
        let z = N<u8>{k: 10, c: B, p: NIL, l: x_i, r: NIL, v: 0};
        let x = N<u8>{k:  5, c: B, p: z_i, l: NIL, r: y_i, v: 0};
        let y = N<u8>{k:  7, c: B, p: x_i, l: w_i, r: NIL, v: 0};
        let w = N<u8>{k:  6, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, z);
        v_pu_b<N<u8>>(&mut b.t, x);
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, w);
        // Perform a left rotation on x
        l_rotate<u8>(x_i, &mut b);
        // Verify root unchanged
        assert!(b.r == z_i, E_L_ROTATE_ROOT);
        // Verify z's l child is now y
        assert!(get_l<u8>(&b, z_i) == y_i, E_L_ROTATE_RELATIONSHIP);
        // Verify z has no other relationships
        assert!(get_r<u8>(&b, z_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        assert!(get_p<u8>(&b, z_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        // Verify y has l child x and parent z
        assert!(get_l<u8>(&b, y_i) == x_i, E_L_ROTATE_RELATIONSHIP);
        assert!(get_p<u8>(&b, y_i) == z_i, E_L_ROTATE_RELATIONSHIP);
        // Verify y has no r child
        assert!(get_r<u8>(&b, y_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        // Verify x has parent y and r child w
        assert!(get_p<u8>(&b, x_i) == y_i, E_L_ROTATE_RELATIONSHIP);
        assert!(get_r<u8>(&b, x_i) == w_i, E_L_ROTATE_RELATIONSHIP);
        // Verify x has no other relationships
        assert!(get_l<u8>(&b, x_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        // Verify w has parent x
        assert!(get_p<u8>(&b, w_i) == x_i, E_L_ROTATE_RELATIONSHIP);
        // Verify w has no other relationships
        assert!(get_l<u8>(&b, w_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        assert!(get_r<u8>(&b, w_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        // Return rather than unpack
        b
    }

/*
      (x) 5          Left rotate        (y) 7
           \             on x              /
            7 (y)     -------->       (x) 5
*/

    #[test]
    /// Verify successful left rotation for simple case
    fun l_rotate_simple():
    BST<u8> {
        // Initialize empty BST with u8 values
        let b = empty<u8>();
        // Define nodes, ignoring color and value fields
        let x_i = 0;
        let y_i = 1;
        let x = N<u8>{k: 5, c: B, p: NIL, l: NIL, r: y_i, v: 0};
        let y = N<u8>{k: 7, c: B, p: x_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, x);
        v_pu_b<N<u8>>(&mut b.t, y);
        // Perform a left rotation on x
        l_rotate<u8>(x_i, &mut b);
        // Verify root updated
        assert!(b.r == y_i, E_L_ROTATE_ROOT);
        // Verify x has parent y
        assert!(get_p<u8>(&b, x_i) == y_i, E_L_ROTATE_RELATIONSHIP);
        // Verify x has no other relationships
        assert!(get_l<u8>(&b, x_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        assert!(get_r<u8>(&b, x_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        // Verify y has l child x
        assert!(get_l<u8>(&b, y_i) == x_i, E_L_ROTATE_RELATIONSHIP);
        // Verify y has no other relationships
        assert!(get_p<u8>(&b, y_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        assert!(get_r<u8>(&b, y_i) == NIL, E_L_ROTATE_RELATIONSHIP);
        // Return rather than unpack
        b
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify left rotation aborts without node having right child
    fun l_rotate_fail(): BST<u8> {
        // Create solo node at vector index 0, having key 1 and value 2
        let b = singleton<u8>(1, 2);
        // Attempt invalid rotation about the node
        l_rotate<u8>(0, &mut b);
        b
    }


/* Right rotation <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

         (z) 10                        (z) 10
             / \                           / \
        (x) 7  15     Right rotate    (y) 5  15
           / \            on x           / \
      (y) 5   8        -------->        2   7 (x)
         / \                               / \
        2   6 (w)                         6   8 (w)

*/

// Right rotation <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    /// Right rotate on the node with the given vector index
    fun r_rotate<V>(
        x_i: u64, // Index of node to right rotate on
        b: &mut BST<V>
    ) {
        // Get index of x's left child (y)
        let y_i = get_l<V>(b, x_i);
        // Assert x actually has a left child
        assert!(y_i != NIL, E_R_ROTATE_NO_L_CHILD);
        // Get index of y's right child (w)
        let w_i = get_r<V>(b, y_i);
        // Set x's left child as w
        set_l<V>(b, x_i, w_i);
        if (w_i != NIL) { // If y has a right child (if w is not null)
            // Set w's parent to be x
            set_p<V>(b, w_i, x_i);
        };
        // Swap the parent relationship between x and its parent to y
        parent_child_swap(x_i, y_i, b);
        // Set y's right child as x
        set_r<V>(b, y_i, x_i);
    }

/*
         (z) 5                      (z) 5
              \                          \
           (x) 9     Right rotate     (y) 7
              /          on x              \
         (y) 7         ------->         (x) 9
              \                            /
           (w) 8                      (w) 8
*/

    #[test]
    /// Verify successful right rotation
    fun r_rotate_success():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes, ignoring color and value fields
        let z_i = 0;
        let x_i = 1;
        let y_i = 2;
        let w_i = 3;
        let z = N<u8>{k: 5, c: B, p: NIL, l: NIL, r: x_i, v: 0};
        let x = N<u8>{k: 9, c: B, p: z_i, l: y_i, r: NIL, v: 0};
        let y = N<u8>{k: 7, c: B, p: x_i, l: NIL, r: w_i, v: 0};
        let w = N<u8>{k: 8, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, z);
        v_pu_b<N<u8>>(&mut b.t, x);
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, w);
        // Perform a right rotation on x
        r_rotate<u8>(x_i, &mut b);
        // Verify root unchanged
        assert!(b.r == z_i, E_R_ROTATE_ROOT);
        // Verify z's r child is now y
        assert!(get_r<u8>(&b, z_i) == y_i, E_R_ROTATE_RELATIONSHIP);
        // Verify z has no other relationships
        assert!(get_l<u8>(&b, z_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        assert!(get_p<u8>(&b, z_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        // Verify y has r child x and parent z
        assert!(get_r<u8>(&b, y_i) == x_i, E_R_ROTATE_RELATIONSHIP);
        assert!(get_p<u8>(&b, y_i) == z_i, E_R_ROTATE_RELATIONSHIP);
        // Verify y has no left child
        assert!(get_l<u8>(&b, y_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        // Verify x has parent y and l child w
        assert!(get_p<u8>(&b, x_i) == y_i, E_R_ROTATE_RELATIONSHIP);
        assert!(get_l<u8>(&b, x_i) == w_i, E_R_ROTATE_RELATIONSHIP);
        // Verify x has no other relationships
        assert!(get_r<u8>(&b, x_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        // Verify w has parent x
        assert!(get_p<u8>(&b, w_i) == x_i, E_R_ROTATE_RELATIONSHIP);
        // Verify w has no other relationships
        assert!(get_l<u8>(&b, w_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        assert!(get_r<u8>(&b, w_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        // Return rather than unpack
        b
    }

/*
        (x) 7     Right rotate    (y) 5
           /          on x             \
      (y) 5         -------->      (x)  7
*/

    #[test]
    /// Verify successful left rotation for simple case
    fun r_rotate_simple():
    BST<u8> {
        // Initialize empty BST with u8 values
        let b = empty<u8>();
        // Define nodes, ignoring color and value fields
        let x_i = 0;
        let y_i = 1;
        let x = N<u8>{k:  7, c: B, p: NIL, l: y_i, r: NIL, v: 0};
        let y = N<u8>{k:  5, c: B, p: x_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, x);
        v_pu_b<N<u8>>(&mut b.t, y);
        // Perform a right rotation on x
        r_rotate<u8>(x_i, &mut b);
        // Verify root updated
        assert!(b.r == y_i, E_R_ROTATE_ROOT);
        // Verify x has parent y
        assert!(get_p<u8>(&b, x_i) == y_i, E_R_ROTATE_RELATIONSHIP);
        // Verify x has no other relationships
        assert!(get_l<u8>(&b, x_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        assert!(get_r<u8>(&b, x_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        // Verify y has r child x
        assert!(get_r<u8>(&b, y_i) == x_i, E_R_ROTATE_RELATIONSHIP);
        // Verify y has no other relationships
        assert!(get_l<u8>(&b, y_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        assert!(get_p<u8>(&b, y_i) == NIL, E_R_ROTATE_RELATIONSHIP);
        // Return rather than unpack
        b
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify right rotation aborts without node having left child
    fun r_rotate_fail(): BST<u8> {
        // Create solo node at vector index 0, having key 1 and value 2
        let b = singleton<u8>(1, 2);
        // Attempt invalid rotation about the node
        r_rotate<u8>(0, &mut b);
        b
    }
}