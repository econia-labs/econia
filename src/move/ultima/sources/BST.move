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
    /// Flag for checking left branch conditions
    const LEFT: bool = true;
    /// Flag for checking right branch conditions
    const RIGHT: bool = false;

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
    const E_INSERTION_DUPLICATE: u64 = 11;
    const E_INSERT_ROOT_NOT_EMPTY: u64 = 12;
    const E_RED_LEAF_LENGTH: u64 = 13;
    const E_RED_LEAF_ROOT_INDEX: u64 = 14;
    const E_RED_LEAF_KEY: u64 = 15;
    const E_RED_LEAF_COLOR: u64 = 16;
    const E_RED_LEAF_P: u64 = 17;
    const E_RED_LEAF_L: u64 = 18;
    const E_RED_LEAF_R: u64 = 19;
    const E_RED_LEAF_V: u64 = 19;
    const E_RED_PARENT_INVALID: u64 = 20;
    const E_PARENT_L_C_INVALID: u64 = 21;
    const E_R_UNCLE_N_P_L_C: u64 = 22;
    const E_R_UNCLE_INVALID: u64 = 23;
    const E_CLEANUP_COLOR_INVALID: u64 = 24;
    const E_CLEANUP_RELATION_ERROR: u64 = 25;
    const E_PARENT_R_C_INVALID: u64 = 26;
    const E_L_UNCLE_N_P_L_C: u64 = 27;
    const E_L_UNCLE_INVALID: u64 = 28;
    const E_EMPTY_NOT_NIL_MIN: u64 = 29;
    const E_MIN_INVALID: u64 = 30;
    const E_MAX_INVALID: u64 = 31;
    const E_GET_I_ERROR: u64 = 32;

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
        BST{r: NIL, t: v_e<N<V>>()}
    }

    #[test]
    /// Verify new BST created empty
    fun empty_success():
    vector<N<u8>> {
        let BST{r, t} = empty<u8>();
        // Assert root set to NIL
        assert!(r == NIL, E_NEW_NOT_EMPTY);
        // Assert vector of nodes is empty
        assert!(v_i_e<N<u8>>(&t), E_NEW_NOT_EMPTY);
        t // Return rather than unpack
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
        // Assert singleton has count 1
        assert!(count<u8>(&s) == 1, E_SINGLETON_NOT_EMPTY);
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
        t // Return tree's vector of nodes rather than unpack
    }

// Initialization <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Checking size >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return number of nodes in the BST
    public fun count<V>(
        b: &BST<V>
    ): u64 {
        v_l<N<V>>(&b.t) // Return length of the BST's vector of nodes
    }

    /// Return true if the BST has no elements
    public fun is_empty<V>(
        b: &BST<V>
    ): bool {
        count(b) == 0
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

    // Return immutable reference to node at vector index `n_i` within
    // BST `b`
    fun borrow<V>(
        b: &BST<V>,
        n_i: u64
    ): &N<V> {
        v_b<N<V>>(&b.t, n_i)
    }

    /// Return mutable reference to node at vector index `n_i` in BST
    /// `b`
    fun borrow_mut<V>(
        b: &mut BST<V>,
        n_i: u64
    ): &mut N<V> {
        v_b_m<N<V>>(&mut b.t, n_i)
    }

    // Return color of node at vector index `n_i` within BST `b``
    fun get_c<V>(
        b: &BST<V>,
        n_i: u64
    ): bool {
        v_b<N<V>>(&b.t, n_i).c
    }

    // Return true if node at vector index `n_i` within BST `b`` is red
    fun is_red<V>(
        b: &BST<V>,
        n_i: u64
    ): bool {
        get_c<V>(b, n_i) == R
    }

    // Return true if node at vector index `n_i` within BST `b`` is
    // black
    fun is_black<V>(
        b: &BST<V>,
        n_i: u64
    ): bool {
        get_c<V>(b, n_i) == B
    }

    /// Return key of node at vector index `n_i` within BST `b`
    fun get_k<V>(
        b: &BST<V>,
        n_i: u64
    ): u64 {
        v_b<N<V>>(&b.t, n_i).k
    }

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

    /// Set node at vector index `n_i` within BST `b` to have color `c`
    fun set_c<V>(
        b: &mut BST<V>,
        n_i: u64,
        c: bool
    ) {
        v_b_m<N<V>>(&mut b.t, n_i).c = c;
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

    /// Left rotate on the node with vector index `n_i` in BST `b`
    fun l_rotate<V>(
        b: &mut BST<V>,
        x_i: u64, // Index of node to left rotate on
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
            let z = borrow_mut<V>(b, z_i);
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
        // Update root to index of first added node
        b.r = z_i;
        // Perform a left rotation on x
        l_rotate<u8>(&mut b, x_i);
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
        b // Return rather than unpack
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
        l_rotate<u8>(&mut b, x_i);
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
        b // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify left rotation aborts without node having right child
    fun l_rotate_fail(): BST<u8> {
        // Create solo node at vector index 0, having key 1 and value 2
        let b = singleton<u8>(1, 2);
        // Attempt invalid rotation about the node
        l_rotate<u8>(&mut b, 0);
        b
    }

// Left rotation <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

/* Right rotation >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

         (z) 10                        (z) 10
             / \                           / \
        (x) 7  15     Right rotate    (y) 5  15
           / \            on x           / \
      (y) 5   8        -------->        2   7 (x)
         / \                               / \
        2   6 (w)                         6   8 (w)

*/

    /// Right rotate on node with vector index `n_i` in BST `b`
    fun r_rotate<V>(
        b: &mut BST<V>,
        x_i: u64 // Index of node to right rotate on
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
        // Update root to index of first added node
        b.r = z_i;
        // Perform a right rotation on x
        r_rotate<u8>(&mut b, x_i);
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
        b // Return rather than unpack
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
        r_rotate<u8>(&mut b, x_i);
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
        b // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 8)]
    /// Verify right rotation aborts without node having left child
    fun r_rotate_fail(): BST<u8> {
        // Create solo node at vector index 0, having key 1 and value 2
        let b = singleton<u8>(1, 2);
        // Attempt invalid rotation about the node
        r_rotate<u8>(&mut b, 0);
        b
    }

// Right rotation <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Red leaf insertion >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Insert key `k` and value `v` into BST `b` as a read leaf,
    /// returning vector index of inserted node
    fun add_red_leaf<V>(
        b: &mut BST<V>,
        k: u64,
        v: V
    ): u64 {
        // Index of node that would have as a leaf a node with key `k`
        let p_i = search_parent_index<V>(b, k);
        // Set index of insertion node to length of nodes vector, since
        // appending to the end of it
        let n_i = count<V>(b);
        if (p_i == NIL) { // If inserting at root
            // Assert vector of nodes in tree is empty
            assert!(is_empty<V>(b), E_INSERT_ROOT_NOT_EMPTY);
            b.r = n_i; // Set tree root to index of node (which is 0)
        } else { // If not inserting at root
            let p_k = get_k<V>(b, p_i); // Get key of parent node
            if (k < p_k) { // If insertion key less than parent key
                // Set parent's left child to insertion node
                set_l(b, p_i, n_i);
            // Since parent index search aborts for equality, only other
            // option is that insertion key is greater than parent key
            } else { // If insertion key is greater than parent key
                // Set parent's right child to insertion node
                set_r(b, p_i, n_i);
            }
        };
        // Append red leaf to tree's nodes vector
        v_pu_b<N<V>>(&mut b.t, N<V>{k, c: R, p: p_i, l: NIL, r: NIL, v});
        n_i
    }

    /// Search nodes from root of BST `b`, returning index of parent
    /// node that would have as a leaf a node with key `k`
    fun search_parent_index<V>(
        b: &BST<V>,
        k: u64
    ): u64 {
        let p_i = NIL; // Assume inserting at root, without a parent
        let s_i = b.r; // Index of search node, starting from root
        while (s_i != NIL) { // While search inspects an actual node
            p_i = s_i; // Set parent index to search index
            let s_k = get_k(b, s_i); // Get key of search node
            // Abort if insertion key equals search key
            if (k == s_k) { abort E_INSERTION_DUPLICATE
            // If insertion key less than search key
            } else if (k < s_k) {
                s_i = get_l(b, s_i); // Run next search to left
            } else { // If insertion key greater than search key
                s_i = get_r(b, s_i); // Run next search to right
            }
        };
        p_i
    }

    #[test]
    /// Verify read leaf added at root
    fun add_red_leaf_root():
    BST<u8> {
        let b = empty<u8>(); // Initialize empty BST
        // Add node w/ key 2, value 3
        let _ = add_red_leaf<u8>(&mut b, 2, 3);
        let n_i = 0; // Assume node index of 0
        // Assert BST has a count of 1
        assert!(count<u8>(&b) == 1, E_RED_LEAF_LENGTH);
        // Assert BST root set to proper node index
        assert!(b.r == n_i, E_RED_LEAF_ROOT_INDEX);
        // Assert node inserted with key 2
        assert!(get_k<u8>(&b, n_i) == 2, E_RED_LEAF_KEY);
        // Assert node inserted with color red
        assert!(is_red<u8>(&b, n_i), E_RED_LEAF_COLOR);
        // Assert inserted without parent or children
        assert!(get_p<u8>(&b, n_i) == NIL, E_RED_LEAF_P);
        assert!(get_l<u8>(&b, n_i) == NIL, E_RED_LEAF_L);
        assert!(get_r<u8>(&b, n_i) == NIL, E_RED_LEAF_R);
        // Assert inserted with correct value
        assert!(borrow<u8>(&b, n_i).v == 3, E_RED_LEAF_V);
        b // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 11)]
    /// Verify insertion aborted for duplicate values
    fun add_red_leaf_duplicate():
    BST<u8> {
        // Create BST with single key-value pair of (1, 2)
        let b = singleton<u8>(1, 2);
        // Try to add a red leaf with key 1
        let _ = add_red_leaf<u8>(&mut b, 1, 3);
        b // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    /// Verify adding red leaf during left branching search
    fun add_red_leaf_left():
    BST<u8> {
        // Create BST with single key-value pair of (2, 3)
        let b = singleton<u8>(2, 3);
        // Add a red leaf with key-value pair (1, 4)
        let _ = add_red_leaf<u8>(&mut b, 1, 4);
        // Assert BST has a count of 2
        assert!(count<u8>(&b) == 2, E_RED_LEAF_LENGTH);
        // Assert BST root set to proper node index
        assert!(b.r == 0, E_RED_LEAF_ROOT_INDEX);
        // Assert fields for first inserted node
        assert!(get_k<u8>(&b, 0) == 2, E_RED_LEAF_KEY);
        assert!(is_black<u8>(&b, 0), E_RED_LEAF_COLOR);
        assert!(get_p<u8>(&b, 0) == NIL, E_RED_LEAF_P);
        assert!(get_l<u8>(&b, 0) == 1, E_RED_LEAF_L);
        assert!(get_r<u8>(&b, 0) == NIL, E_RED_LEAF_R);
        assert!(borrow<u8>(&b, 0).v == 3, E_RED_LEAF_V);
        // Assert fields for red leaf added to left
        assert!(get_k<u8>(&b, 1) == 1, E_RED_LEAF_KEY);
        assert!(is_red<u8>(&b, 1), E_RED_LEAF_COLOR);
        assert!(get_p<u8>(&b, 1) == 0, E_RED_LEAF_P);
        assert!(get_l<u8>(&b, 1) == NIL, E_RED_LEAF_L);
        assert!(get_r<u8>(&b, 1) == NIL, E_RED_LEAF_R);
        assert!(borrow<u8>(&b, 1).v == 4, E_RED_LEAF_V);
        b // Return rather than unpack
    }

    #[test]
    /// Verify adding red leaf during right branching search
    fun add_red_leaf_right():
    BST<u8> {
        // Create BST with single key-value pair of (2, 3)
        let b = singleton<u8>(2, 3);
        // Add a red leaf with key-value pair (4, 5)
        let _ = add_red_leaf<u8>(&mut b, 4, 5);
        // Assert BST has a count of 2
        assert!(count<u8>(&b) == 2, E_RED_LEAF_LENGTH);
        // Assert BST root set to proper node index
        assert!(b.r == 0, E_RED_LEAF_ROOT_INDEX);
        // Assert fields for first inserted node
        assert!(get_k<u8>(&b, 0) == 2, E_RED_LEAF_KEY);
        assert!(is_black<u8>(&b, 0), E_RED_LEAF_COLOR);
        assert!(get_p<u8>(&b, 0) == NIL, E_RED_LEAF_P);
        assert!(get_l<u8>(&b, 0) == NIL, E_RED_LEAF_L);
        assert!(get_r<u8>(&b, 0) == 1, E_RED_LEAF_R);
        assert!(borrow<u8>(&b, 0).v == 3, E_RED_LEAF_V);
        // Assert fields for red leaf added to left
        assert!(get_k<u8>(&b, 1) == 4, E_RED_LEAF_KEY);
        assert!(is_red<u8>(&b, 1), E_RED_LEAF_COLOR);
        assert!(get_p<u8>(&b, 1) == 0, E_RED_LEAF_P);
        assert!(get_l<u8>(&b, 1) == NIL, E_RED_LEAF_L);
        assert!(get_r<u8>(&b, 1) == NIL, E_RED_LEAF_R);
        assert!(borrow<u8>(&b, 1).v == 5, E_RED_LEAF_V);
        b // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 12)]
    // Verify unable to insert as root when vector of nodes is empty
    fun add_red_leaf_not_empty():
    BST<u8> {
        let b = empty<u8>(); // Create empty BST
        // Add invalid node without updating root
        let n = N<u8>{k:1, c: B, p: NIL, l: NIL, r: NIL, v: 0};
        v_pu_b<N<u8>>(&mut b.t, n);
        // Try to add red leaf
        let _ = add_red_leaf<u8>(&mut b, 1, 2);
        b // Return rather than unpack (or signal to compiler as much)
    }

// Red leaf insertion <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Insertion cleanup helper functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return true if node at vector index `n_i` within BST `b` has a
    /// red parent
    fun has_red_parent<V>(
        b: &BST<V>,
        n_i: u64
    ): bool {
        let p_i = get_p<V>(b, n_i); // Index of parent
        // Short-circuit logic will not try to check parent color if no
        // parent
        (p_i != NIL && is_red<V>(b, p_i))
    }

    /// Return true if node at vector index `n_i` within BST `b` has a
    /// a parent that is a left child
    fun parent_is_l_child<V>(
        b: &BST<V>,
        n_i: u64
    ): bool {
        let p_i = get_p<V>(b, n_i); // Index of parent
        if (p_i != NIL) { // If n has a parent
            let g_p_i = get_p<V>(b, p_i); // Index of grandparent
            if (g_p_i != NIL) { // If n has a grandparent
                // Return true if grandparent's l child is parent
                if (get_l<V>(b, g_p_i) == p_i) return true
            }
        };
        false
    }

    /// Return true if node at vector index `n_i` within BST `b` has a
    /// a parent that is a right child
    fun parent_is_r_child<V>(
        b: &BST<V>,
        n_i: u64
    ): bool {
        let p_i = get_p<V>(b, n_i); // Index of parent
        if (p_i != NIL) { // If n has a parent
            let g_p_i = get_p<V>(b, p_i); // Index of grandparent
            if (g_p_i != NIL) { // If n has a grandparent
                // Return true if grandparent's r child is parent
                if (get_r<V>(b, g_p_i) == p_i) return true
            }
        };
        false
    }

    /// Return node vector index of right child of grandparent to node
    /// `n_i` in BST `b`. Should only be called if node has parent that
    /// is a left child
    fun right_uncle<V>(
        b: &BST<V>,
        n_i: u64
    ): u64 {
        assert!(parent_is_l_child<V>(b, n_i), E_R_UNCLE_N_P_L_C);
        let p_i = get_p<V>(b, n_i); // Index of parent
        let g_p_i = get_p<V>(b, p_i); // Index of grandparent
        // Return grandparent's right child
        get_r<V>(b, g_p_i)
    }

    /// Return node vector index of left child of grandparent to node
    /// `n_i` in BST `b`. Should only be called if node has parent that
    /// is a right child
    fun left_uncle<V>(
        b: &BST<V>,
        n_i: u64
    ): u64 {
        assert!(parent_is_r_child<V>(b, n_i), E_L_UNCLE_N_P_L_C);
        let p_i = get_p<V>(b, n_i); // Index of parent
        let g_p_i = get_p<V>(b, p_i); // Index of grandparent
        // Return grandparent's left child
        get_l<V>(b, g_p_i)
    }

    /// Return vector index of uncle to node at `n_i`, on a given side
    fun uncle_on_side<V>(
        b: &BST<V>,
        n_i: u64,
        s: bool
    ): u64 {
        if (s == LEFT) {
            return left_uncle<V>(b, n_i)
        } else {
            return right_uncle<V>(b, n_i)
        }
    }

    /// Rotate on vector at index `n_i` to given side
    fun rotate_to_side<V>(
        b: &mut BST<V>,
        n_i: u64,
        s: bool
    ) {
        if (s == LEFT) {
            return l_rotate<V>(b, n_i)
        } else {
            return r_rotate<V>(b, n_i)
        }
    }

    /// Determine if node at index `n_i` is a child of parent at index
    /// `p_i`, for the given side
    fun is_child_on_side<V>(
        b: &mut BST<V>,
        n_i: u64,
        p_i: u64,
        s: bool
    ): bool {
        if (s == LEFT) {
            return get_l<V>(b, p_i) == n_i
        } else {
            return get_r<V>(b, p_i) == n_i
        }
    }

    #[test]
    /// Verify return of true when node has a red parent
    fun has_red_parent_true():
    BST<u8> {
        // Create singleton BST with key-value pair (1, 2)
        let b = singleton<u8>(1, 2);
        // Set color of singleton node as red, and l child as next node
        set_c<u8>(&mut b, 0, R);
        set_l<u8>(&mut b, 0, 1);
        // Append red leaf node with first node as parent
        let l = N<u8>{k: 10, c: R, p: 0, l: NIL, r: NIL, v: 0};
        v_pu_b<N<u8>>(&mut b.t, l);
        // Assert appended red leaf registers as having red parent
        assert!(has_red_parent<u8>(&b, 1), E_RED_PARENT_INVALID);
        b // Return rather than unpack
    }

    #[test]
    /// Verify return of false when node does not have a red parent
    fun has_red_parent_false():
    BST<u8> {
        // Create singleton BST with key-value pair (1, 2)
        let b = singleton<u8>(1, 2); // Color defaults to black
        // Set r child as next node
        set_l<u8>(&mut b, 0, 1);
        // Append red leaf node with first node as parent
        let l = N<u8>{k: 10, c: R, p: 0, l: NIL, r: NIL, v: 0};
        v_pu_b<N<u8>>(&mut b.t, l);
        // Assert appended red leaf registers as not having red parent
        assert!(!has_red_parent<u8>(&b, 1), E_RED_PARENT_INVALID);
        b // Return rather than unpack
    }

    #[test]
    /// Verify return of false when node does not have a red parent
    fun has_red_parent_short_circuit():
    BST<u8> {
        // Create singleton BST with key-value pair (1, 2)
        let b = singleton<u8>(1, 2);
        // Assert singleton root node registers as not having red parent
        assert!(!has_red_parent<u8>(&b, 0), E_RED_PARENT_INVALID);
        b // Return rather than unpack
    }

    #[test]
    /// Verify return of false for root node
    fun parent_is_l_child_root():
    BST<u8> {
        // Create singleton BST with key-value pair (1, 2)
        let b = singleton<u8>(1, 2);
        // Assert root node does not register as having parent that is
        // left child
        assert!(!parent_is_l_child<u8>(&b, 0), E_PARENT_L_C_INVALID);
        b // Return rather than unpack
    }

    #[test]
    /// Verify return of false for root node
    fun parent_is_r_child_root():
    BST<u8> {
        // Create singleton BST with key-value pair (1, 2)
        let b = singleton<u8>(1, 2);
        // Assert root node does not register as having parent that is
        // right child
        assert!(!parent_is_r_child<u8>(&b, 0), E_PARENT_R_C_INVALID);
        b // Return rather than unpack
    }

/*
      6 (y)
       \
        7 (z)
*/

    #[test]
    /// Verify return of false for no grandparent
    fun parent_is_l_child_no_gp():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the tree above, ignoring color and value fields:
        // (6, 0, y), (7, 1, z)
        let y_i = 0;
        let z_i = 1;
        let y = N<u8>{k: 6, c: B, p: NIL, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 7, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Assert node does not register as having parent that is left
        // child
        assert!(!parent_is_l_child<u8>(&b, z_i), E_PARENT_L_C_INVALID);
        b // Return rather than unpack
    }

    #[test]
    /// Verify return of false for no grandparent, same diagram as for
    /// left case
    fun parent_is_r_child_no_gp():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the tree above, ignoring color and value fields:
        // (6, 0, y), (7, 1, z)
        let y_i = 0;
        let z_i = 1;
        let y = N<u8>{k: 6, c: B, p: NIL, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 7, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Assert node does not register as having parent that is right
        // child
        assert!(!parent_is_r_child<u8>(&b, z_i), E_PARENT_R_C_INVALID);
        b // Return rather than unpack
    }

/*
    5 (w)
     \
      6 (y)
       \
        7 (z)
*/

    #[test]
    /// Verify return of false for parent as right child
    fun parent_is_l_child_r():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the tree above, ignoring color and value fields:
        // (5, 0, w), (6, 1, y), (7, 2, z)
        let w_i = 0;
        let y_i = 1;
        let z_i = 2;
        let w = N<u8>{k: 5, c: B, p: NIL, l: NIL, r: y_i, v: 0};
        let y = N<u8>{k: 6, c: B, p: w_i, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 7, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, w);
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Assert z does not register as having parent that is left
        // child
        assert!(!parent_is_l_child<u8>(&b, z_i), E_PARENT_L_C_INVALID);
        b // Return rather than unpack
    }

/*
       5 (w)
      /
      6 (y)
       \
        7 (z)
*/

    #[test]
    /// Verify return of false for parent as left child
    fun parent_is_r_child_l():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the tree above, ignoring color and value fields:
        // (5, 0, w), (6, 1, y), (7, 2, z)
        let w_i = 0;
        let y_i = 1;
        let z_i = 2;
        let w = N<u8>{k: 5, c: B, p: NIL, l: y_i, r: NIL, v: 0};
        let y = N<u8>{k: 6, c: B, p: w_i, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 7, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, w);
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Assert z does not register as having parent that is right
        // child
        assert!(!parent_is_r_child<u8>(&b, z_i), E_PARENT_R_C_INVALID);
        b // Return rather than unpack
    }

/*
        5 (w)
       /
      6 (y)
       \
        7 (z)
*/
    #[test]
    /// Verify return of true for parent as left child
    fun parent_is_l_child_success():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the tree above, ignoring color and value fields:
        // (5, 0, w), (6, 1, y), (7, 2, z)
        let w_i = 0;
        let y_i = 1;
        let z_i = 2;
        let w = N<u8>{k: 5, c: B, p: NIL, l: y_i, r: NIL, v: 0};
        let y = N<u8>{k: 6, c: B, p: w_i, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 7, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, w);
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Assert z registers as having parent that is left child
        assert!(parent_is_l_child<u8>(&b, z_i), E_PARENT_L_C_INVALID);
        b // Return rather than unpack
    }

/*
    5 (w)
     \
      6 (y)
       \
        7 (z)
*/

    #[test]
    /// Verify return of true for parent as right child
    fun parent_is_r_child_success():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the tree above, ignoring color and value fields:
        // (5, 0, w), (6, 1, y), (7, 2, z)
        let w_i = 0;
        let y_i = 1;
        let z_i = 2;
        let w = N<u8>{k: 5, c: B, p: NIL, l: NIL, r: y_i, v: 0};
        let y = N<u8>{k: 6, c: B, p: w_i, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 7, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, w);
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Assert z registers as having parent that is right child
        assert!(parent_is_r_child<u8>(&b, z_i), E_PARENT_R_C_INVALID);
        b // Return rather than unpack
    }

/*
            5 (w)
           / \
      (y) 3   7 (x)
         /
    (z) 2
*/
    #[test]
    /// Verify right uncle returned correctly
    fun right_uncle_success():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the tree above, ignoring color and value fields:
        // (5, 0, w), (3, 1, y), (7, 2, x), (2, 3, z)
        let w_i = 0;
        let y_i = 1;
        let x_i = 2;
        let z_i = 3;
        let w = N<u8>{k: 5, c: B, p: NIL, l: y_i, r: x_i, v: 0};
        let y = N<u8>{k: 3, c: B, p: w_i, l: z_i, r: NIL, v: 0};
        let x = N<u8>{k: 7, c: B, p: w_i, l: NIL, r: NIL, v: 0};
        let z = N<u8>{k: 2, c: B, p: y_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, w);
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, x);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Assert z's right uncle is returned as index of x
        assert!(right_uncle<u8>(&b, z_i) == x_i, E_R_UNCLE_INVALID);
        b // Return rather than unpack
    }

/*
            5 (w)
           / \
      (y) 3   7 (x)
               \
            (z) 2
*/
    #[test]
    /// Verify left uncle returned correctly
    fun left_uncle_success():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (key, index, symbol) schema per
        // the tree above, ignoring color and value fields:
        // (5, 0, w), (3, 1, y), (7, 2, x), (2, 3, z)
        let w_i = 0;
        let y_i = 1;
        let x_i = 2;
        let z_i = 3;
        let w = N<u8>{k: 5, c: B, p: NIL, l: y_i, r: x_i, v: 0};
        let y = N<u8>{k: 3, c: B, p: w_i, l: NIL, r: NIL, v: 0};
        let x = N<u8>{k: 7, c: B, p: w_i, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 2, c: B, p: x_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, w);
        v_pu_b<N<u8>>(&mut b.t, y);
        v_pu_b<N<u8>>(&mut b.t, x);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Assert z's left uncle is returned as index of y
        assert!(left_uncle<u8>(&b, z_i) == y_i, E_L_UNCLE_INVALID);
        b // Return rather than unpack
    }

    #[test]
    #[expected_failure(abort_code = 22)]
    /// Verify right uncle check fails if node does not have parent that
    /// is a left child
    fun right_uncle_p_n_l_c():
    BST<u8> {
        // Initialize a BST singleton with key value pair (1, 2)
        let b = singleton<u8>(1, 2);
        // Query the right uncle of the resultant root node
        right_uncle<u8>(&b, 0);
        b // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    #[expected_failure(abort_code = 27)]
    /// Verify left uncle check fails if node does not have parent that
    /// is a right child
    fun left_uncle_p_n_l_c():
    BST<u8> {
        // Initialize a BST singleton with key value pair (1, 2)
        let b = singleton<u8>(1, 2);
        // Query the right uncle of the resultant root node
        left_uncle<u8>(&b, 0);
        b // Return rather than unpack (or signal to compiler as much)
    }

// Insertion cleanup helper functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Insertion cleanup loop >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Starting at node `n_i`, cleanup property violations from
    /// `add_red_leaf()``
    fun insertion_cleanup<V>(
        b: &mut BST<V>,
        n_i: u64
    ) {
        while (has_red_parent<V>(b, n_i)) { // While node has red parent
            // If node's parent is a left child
            if (parent_is_l_child<V>(b, n_i)) { // I
                n_i = fix_violation_cases<V>(b, n_i, LEFT);
            // If node's parent is neither a left child nor a right
            // child, can be flagged as being a right child, since
            // mutation logic in `fix_violation_cases()` will not
            // execute in this case. Hence, if node's parent is not a
            // left child, simply flag as being a right child
            } else {
                n_i = fix_violation_cases<V>(b, n_i, RIGHT);
            };
        };
        let r_i = b.r; // Index of root
        set_c<V>(b, r_i, B); // Set root node to be black
    }

    /// Fix BST property violation cases observed from node having
    /// vector index `n_i` in BST `b`, depending on what kind of child
    /// the node's parent is. Return vector index for next node to try
    /// cleanup on
    fun fix_violation_cases<V>(
        b: &mut BST<V>,
        n_i: u64,
        s: bool // What kind of child red parent is, left or right
    ): u64 {
        let p_i = get_p<V>(b, n_i); // Index of parent
        let g_p_i = get_p<V>(b, p_i); // Grandparent index
        // Uncle to node on side opposite that of red parent's side as
        // a child
        let u_i = uncle_on_side<V>(b, n_i, !s);
        // If node actually has an uncle and the uncle is red
        if ((u_i != NIL) && (get_c<V>(b, u_i) == R)) {
            // Shift red up a level, conserving black height
            set_c<V>(b, p_i, B); // Set parent to black
            set_c<V>(b, u_i, B); // Set uncle to black
            set_c<V>(b, g_p_i, R); // Set grandparent to red
            n_i = g_p_i; // Repeat cleanup on newly-red grandparent
        } else { // If node does not have a red uncle
            // If node is a child on side opposite that of red parent
            if (is_child_on_side<V>(b, n_i, p_i, !s)) {
                n_i = p_i; // Mark parent node for new cleanup
                // Rotate on parent to side for which red parent is a
                // child
                rotate_to_side<V>(b, p_i, s);
                p_i = get_p<V>(b, n_i); // Get new parent
                g_p_i = get_p<V>(b, p_i); // Get new grandparent
                // Passes onto case of node as child on side same as
                // red parent's side, which is now the case
            }; // If cleanup node is child on same side as red parent
            set_c<V>(b, p_i, B); // Set parent color to black
            set_c<V>(b, g_p_i, R); // Set grandparent to red
            // Rotate on grandparent to side opposite that of red
            // parent's side as a child
            rotate_to_side(b, g_p_i, !s);
        };
        n_i
    }

/*
                  12 (g, B)                         12 (g, B)
                 /  \           Cleanup            /  \
        (p, R) 10    15 (u, R)  ------>   (p, B) 10    15 (u, B)
               /                                 /
      (z, R)  8                          (z, R) 8
*/

    #[test]
    /// Test insertion cleanup for red right uncle case, where red is
    /// shifted up one level in the tree (after which root is blackened)
    fun insertion_cleanup_r_uncle_shift_up_r():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (index, key, symbol, color)
        // schema per the above tree:, ignoring value fields
        // (0, 12, g, B), (1, 10, p, R), (2, 8, z, R), (3, 15, u, R)
        let g_i = 0;
        let p_i = 1;
        let z_i = 2;
        let u_i = 3;
        let g = N<u8>{k: 12, c: B, p: NIL, l: p_i, r: u_i, v: 0};
        let p = N<u8>{k: 10, c: R, p: g_i, l: z_i, r: NIL, v: 0};
        let z = N<u8>{k:  8, c: R, p: p_i, l: NIL, r: NIL, v: 0};
        let u = N<u8>{k: 15, c: R, p: g_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, g);
        v_pu_b<N<u8>>(&mut b.t, p);
        v_pu_b<N<u8>>(&mut b.t, z);
        v_pu_b<N<u8>>(&mut b.t, u);
        // Update root node to be node g
        b.r = g_i;
        // Run post-insertion cleanup starting at z
        insertion_cleanup<u8>(&mut b, z_i);
        // Assert post-shift colors for each node
        assert!(get_c<u8>(&b, g_i) == B, E_CLEANUP_COLOR_INVALID);
        assert!(get_c<u8>(&b, p_i) == B, E_CLEANUP_COLOR_INVALID);
        assert!(get_c<u8>(&b, z_i) == R, E_CLEANUP_COLOR_INVALID);
        assert!(get_c<u8>(&b, u_i) == B, E_CLEANUP_COLOR_INVALID);
        b // Return rather than unpack
   }

/*
                  12 (g, B)                         12 (g, B)
                 /  \           Cleanup            /  \
        (u, R) 10    15 (p, R)  ------>   (u, B) 10    15 (p, B)
                       \                                 \
                        16 (z, R)                         16 (z, R)
*/
    #[test]
    /// Test insertion cleanup for red left uncle case, where red is
    /// shifted up one level in the tree (after which root is blackened)
    fun insertion_cleanup_l_uncle_shift_up_r():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (index, key, symbol, color)
        // schema per the above tree:, ignoring value fields
        // (0, 12, g, B), (1, 10, u, R), (2, 16, z, R), (3, 15, p, R)
        let g_i = 0;
        let u_i = 1;
        let z_i = 2;
        let p_i = 3;
        let g = N<u8>{k: 12, c: B, p: NIL, l: p_i, r: u_i, v: 0};
        let u = N<u8>{k: 10, c: R, p: g_i, l: NIL, r: NIL, v: 0};
        let z = N<u8>{k: 16, c: R, p: p_i, l: NIL, r: NIL, v: 0};
        let p = N<u8>{k: 15, c: R, p: g_i, l: NIL, r: z_i, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, g);
        v_pu_b<N<u8>>(&mut b.t, u);
        v_pu_b<N<u8>>(&mut b.t, z);
        v_pu_b<N<u8>>(&mut b.t, p);
        // Update root node to be node g
        b.r = g_i;
        // Run post-insertion cleanup starting at z
        insertion_cleanup<u8>(&mut b, z_i);
        // Assert post-shift colors for each node
        assert!(get_c<u8>(&b, g_i) == B, E_CLEANUP_COLOR_INVALID);
        assert!(get_c<u8>(&b, p_i) == B, E_CLEANUP_COLOR_INVALID);
        assert!(get_c<u8>(&b, z_i) == R, E_CLEANUP_COLOR_INVALID);
        assert!(get_c<u8>(&b, u_i) == B, E_CLEANUP_COLOR_INVALID);
        b // Return rather than unpack
    }


/*
            12 (g, B)     Left rotate              12 (g, B)
           /  \               on p                /  \
  (p, R) 10    15 (u, B)    ------>      (z, R) 11    15 (u, B)
           \                                    /
    (z, R) 11                          (p, R) 10

    Right rotate                  11 (z, B)
    on g, recolor                /  \
     -------->          (p, R) 10    12 (g, R)
                                      \
                                      15 (u, B)
*/

    #[test]
    /// Test insertion cleanup for case where node has red parent that is
    /// left child, node does not have a red right uncle, and node is a
    /// right child
    fun insertion_cleanup_complex_1():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (index, key, symbol, color)
        // schema per the above tree:, ignoring value fields
        // (0, 12, g, B), (1, 10, p, R), (2, 11, z, R), (3, 15, u, B)
        let g_i = 0;
        let p_i = 1;
        let z_i = 2;
        let u_i = 3;
        let g = N<u8>{k: 12, c: B, p: NIL, l: p_i, r: u_i, v: 0};
        let p = N<u8>{k: 10, c: R, p: g_i, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 11, c: R, p: p_i, l: NIL, r: NIL, v: 0};
        let u = N<u8>{k: 15, c: B, p: g_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, g);
        v_pu_b<N<u8>>(&mut b.t, p);
        v_pu_b<N<u8>>(&mut b.t, z);
        v_pu_b<N<u8>>(&mut b.t, u);
        // Update root node to be node g
        b.r = g_i;
        // Run post-insertion cleanup starting at z
        insertion_cleanup<u8>(&mut b, z_i);
        // Assert node p is red, has parent z, and no other relations
        assert!(get_c<u8>(&b, p_i) ==   R, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, p_i) == z_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, p_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, p_i) == NIL, E_CLEANUP_RELATION_ERROR);
        // Assert node z is black, has no parent, children p and g
        assert!(get_c<u8>(&b, z_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, z_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, z_i) == p_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, z_i) == g_i, E_CLEANUP_RELATION_ERROR);
        // Assert node g is red, has parent z, r child u
        assert!(get_c<u8>(&b, g_i) ==   R, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, g_i) == z_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, g_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, g_i) == u_i, E_CLEANUP_RELATION_ERROR);
        // Assert node u is black, has parent g, no children
        assert!(get_c<u8>(&b, u_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, u_i) == g_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, u_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, u_i) == NIL, E_CLEANUP_RELATION_ERROR);
        b // Return rather than unpack
   }


/*
            12 (g, B)    Right rotate              12 (g, B)
           /  \               on p                /  \
  (u, B) 10    15 (p, R)    ------>      (u, B) 10    13 (z, R)
               /                                        \
      (z, R) 13                                   (p, R) 15

     Left rotate                  13 (z, B)
    on g, recolor                /  \
     -------->          (g, R) 12    15 (p, R)
                               /
                      (u, B) 10
*/

    #[test]
    /// Test insertion cleanup for case where node has red parent that is
    /// right child, node does not have a red left uncle, and node is a
    /// left child
    fun insertion_cleanup_complex_2():
    BST<u8> {
        // Initialize an empty BST with u8 values
        let b = empty<u8>();
        // Define nodes in the following (index, key, symbol, color)
        // schema per the above tree:, ignoring value fields
        // (0, 12, g, B), (1, 10, u, B), (2, 15, p, R), (3, 13, z, R)
        let g_i = 0;
        let u_i = 1;
        let p_i = 2;
        let z_i = 3;
        let g = N<u8>{k: 12, c: B, p: NIL, l: u_i, r: p_i, v: 0};
        let u = N<u8>{k: 10, c: B, p: g_i, l: NIL, r: NIL, v: 0};
        let p = N<u8>{k: 15, c: R, p: g_i, l: z_i, r: NIL, v: 0};
        let z = N<u8>{k: 13, c: R, p: p_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, g);
        v_pu_b<N<u8>>(&mut b.t, u);
        v_pu_b<N<u8>>(&mut b.t, p);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Update root node to be node g
        b.r = g_i;
        // Run post-insertion cleanup starting at z
        insertion_cleanup<u8>(&mut b, z_i);
        // Assert node u is black, has parent g, and no other relations
        assert!(get_c<u8>(&b, u_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, u_i) == g_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, u_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, u_i) == NIL, E_CLEANUP_RELATION_ERROR);
        // Assert node g is red, has parent z, and l child u only
        assert!(get_c<u8>(&b, g_i) ==   R, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, g_i) == z_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, g_i) == u_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, g_i) == NIL, E_CLEANUP_RELATION_ERROR);
        // Assert node z is black, has no parent, and children g and p
        assert!(get_c<u8>(&b, z_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, z_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, z_i) == g_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, z_i) == p_i, E_CLEANUP_RELATION_ERROR);
        // Assert node p is red, has parent z, and no children
        assert!(get_c<u8>(&b, p_i) ==   R, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, p_i) == z_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, p_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, p_i) == NIL, E_CLEANUP_RELATION_ERROR);
        b // Return rather than unpack
    }

    #[test]
    /// Test insertion cleanup for case where node has red parent that
    /// is neither a left nor a right child, and where node is left
    /// child to its parent
    fun insertion_cleanup_red_root_l_c():
    BST<u8> {
        // Initialize empty BST with u8 values
        let b = empty<u8>();
        // Define nodes w/ following (index, key, symbol, color) schema:
        // (0, 1, z, R), (1, 5, x, B), with x as l child of z, ignoring
        // value fields
        let (z_i, x_i) = (0, 1);
        let z = N<u8>{k: 1, c: R, p: NIL, l: x_i, r: NIL, v: 0};
        let x = N<u8>{k: 5, c: B, p: z_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, z);
        v_pu_b<N<u8>>(&mut b.t, x);
        // Update root node to be node z
        b.r = z_i;
        // Run post-insertion cleanup starting at z
        insertion_cleanup<u8>(&mut b, z_i);
        // Assert node z has been blackened but otherwise unchanged
        assert!(get_c<u8>(&b, z_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, z_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, z_i) == x_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, z_i) == NIL, E_CLEANUP_RELATION_ERROR);
        // Assert node x is unchanged
        assert!(get_c<u8>(&b, x_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, x_i) == z_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, x_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, x_i) == NIL, E_CLEANUP_RELATION_ERROR);
        b // Return rather than unpack
   }

    #[test]
    /// Test insertion cleanup for case where node has red parent that
    /// is neither a left nor a right child, and where node is right
    /// child to its parent
    fun insertion_cleanup_red_root_r_c():
    BST<u8> {
        // Initialize empty BST with u8 values
        let b = empty<u8>();
        // Define nodes w/ following (index, key, symbol, color) schema:
        // (0, 1, z, R), (1, 5, x, B), with x as r child of z, ignoring
        // value fields
        let (z_i, x_i) = (0, 1);
        let z = N<u8>{k: 1, c: R, p: NIL, l: NIL, r: x_i, v: 0};
        let x = N<u8>{k: 5, c: B, p: z_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, z);
        v_pu_b<N<u8>>(&mut b.t, x);
        // Update root node to be node z
        b.r = z_i;
        // Run post-insertion cleanup starting at z
        insertion_cleanup<u8>(&mut b, z_i);
        // Assert node z has been blackened but otherwise unchanged
        assert!(get_c<u8>(&b, z_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, z_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, z_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, z_i) == x_i, E_CLEANUP_RELATION_ERROR);
        // Assert node x is unchanged
        assert!(get_c<u8>(&b, x_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, x_i) == z_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, x_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, x_i) == NIL, E_CLEANUP_RELATION_ERROR);
        b // Return rather than unpack
    }

/*
            5 (w, B)
             \            Recolor and             7 (x, B)
              7 (x, R)     rotate to             / \
               \           left on w     (w, R) 5   9 (z, R)
         (z, R) 9           ------->
*/
    #[test]
    /// Test insertion cleanup for case where parent is red right child,
    /// node is child on side same as that of parent (right), and no
    /// red uncle
    fun insertion_cleanup_right_p_r_r_c_simple():
    BST<u8> {
        // Initialize empty BST with u8 values
        let b = empty<u8>();
        // Define nodes w/ following (index, key, symbol, color) schema
        // per above diagram, ignoring value fields:
        // (0, 5, w, B), (1, 7, x, R), (2, 9, z, R)
        let (w_i, x_i, z_i) = (0, 1, 2);
        let w = N<u8>{k: 5, c: B, p: NIL, l: NIL, r: x_i, v: 0};
        let x = N<u8>{k: 7, c: R, p: w_i, l: NIL, r: z_i, v: 0};
        let z = N<u8>{k: 9, c: R, p: x_i, l: NIL, r: NIL, v: 0};
        // Append nodes to the BST's tree node vector t
        v_pu_b<N<u8>>(&mut b.t, w);
        v_pu_b<N<u8>>(&mut b.t, x);
        v_pu_b<N<u8>>(&mut b.t, z);
        // Update root node to be node z
        b.r = w_i;
        // Run post-insertion cleanup starting at z
        insertion_cleanup<u8>(&mut b, z_i);
        // Assert black node x has no parent, children w and z
        assert!(get_c<u8>(&b, x_i) ==   B, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, x_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, x_i) == w_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, x_i) == z_i, E_CLEANUP_RELATION_ERROR);
        // Assert red node w has parent x and no children
        assert!(get_c<u8>(&b, w_i) ==   R, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, w_i) == x_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, w_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, w_i) == NIL, E_CLEANUP_RELATION_ERROR);
        // Assert red node z has parent x and no children
        assert!(get_c<u8>(&b, z_i) ==   R, E_CLEANUP_COLOR_INVALID);
        assert!(get_p<u8>(&b, z_i) == x_i, E_CLEANUP_RELATION_ERROR);
        assert!(get_l<u8>(&b, z_i) == NIL, E_CLEANUP_RELATION_ERROR);
        assert!(get_r<u8>(&b, z_i) == NIL, E_CLEANUP_RELATION_ERROR);
        b // Return rather than unpack
    }

// Insertion cleanup loop <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Insertion and querying >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Insert key-value pair with key `k` and value `v` into BST `b`
    public(script) fun insert<V>(
        b: &mut BST<V>,
        k: u64,
        v: V
    ) {
        // Append key-value pair as pre-cleanup red leaf
        let n_i = add_red_leaf<V>(b, k, v);
        // Check to make sure BST didn't overflow by adding one to the
        // count of nodes in the nodes vector, since the max possible
        // index value is reserved for NIL. This will trigger a u64
        // overflow error if attempting to add more than MAX_NODES
        let _check: u64 = count<V>(b) + 1;
        insertion_cleanup<V>(b, n_i); // Cleanup (rebalance) tree
    }

    /// Retern key at outermost position from search to either l or r
    fun limit<V>(
        b: &BST<V>,
        d: bool, // Direction to search
    ): u64 {
        if (is_empty<V>(b)) return NIL; // Return NIL flag if no keys
        let s_i = b.r; // Initialize search index to root node index
        // While there is another child to search for in given direction
        loop {
            // Get index of next node in given direction
            let next = if (d == LEFT) get_l<V>(b, s_i) else get_r<V>(b, s_i);
            if (next == NIL) break;
            s_i = next;
        };
        get_k<V>(b, s_i) // Return key of final node from search
    }

    /// Return minimum key in BST `b`
    public fun min<V>(
        b: &BST<V>
    ): u64 {
        limit<V>(b, LEFT)
    }

    /// Return maximum key in BST `b`
    public fun max<V>(
        b: &BST<V>
    ): u64 {
        limit<V>(b, RIGHT)
    }

    /// Return node vector index of key `k`, if is in BST `b`, otherwise
    /// return NIL
    public fun get_i<V>(
        b: &BST<V>,
        k: u64
    ): u64 {
        if (is_empty<V>(b)) return NIL; // Return NIL flag if no keys
        let s_i = b.r; // Initialize search index to root node index
        // While match not found, keep searching
        loop {
            let s_k = get_k<V>(b, s_i); // Get key of search node
            // Return search index if node has same key as `k`
            if (k == s_k) return s_i;
            // If key less than key of searched node look to L, else R
            s_i = if (k < s_k) get_l<V>(b, s_i) else get_r<V>(b, s_i);
            // Return NIL if no next node to search
            if (s_i == NIL) return NIL;
        }
    }

    #[test]
    /// Verify NIL return when searching empty BST
    fun min_empty_nil():
    BST<u8> {
        let b = empty<u8>();
        assert!(min<u8>(&b) == NIL, E_EMPTY_NOT_NIL_MIN);
        b // Return rather than unpack
    }

    #[test]
    /// Verify successful reporting of min after various insertions
    public(script) fun min_success():
    BST<u8> {
        // Append assorted keys out of order and verify minimum
        let b = singleton<u8>(3, 0); // Start with singleton
        // Ignore values, only consider keys
        insert(&mut b, 10, 0);
        insert(&mut b, 23, 0);
        insert(&mut b, 99, 0);
        insert(&mut b,  4, 0);
        insert(&mut b,  8, 0);
        insert(&mut b, 25, 0);
        insert(&mut b,  2, 0); // <------------------ min key
        insert(&mut b, 64, 0);
        insert(&mut b, 13, 0);
        insert(&mut b, 12, 0);
        insert(&mut b, 17, 0);
        assert!(min<u8>(&b) == 2, E_MIN_INVALID);
        b // Return rather than unpack
    }

    #[test]
    /// Verify successful reporting of max after various insertions
    public(script) fun max_success():
    BST<u8> {
        // Append assorted keys out of order and verify maximum
        let b = singleton<u8>(3, 0); // Start with singleton
        // Ignore values, only consider keys
        insert(&mut b, 10, 0);
        insert(&mut b, 23, 0);
        insert(&mut b, 99, 0); // <------------------ max key
        insert(&mut b,  4, 0);
        insert(&mut b,  8, 0);
        insert(&mut b, 25, 0);
        insert(&mut b,  2, 0);
        insert(&mut b, 64, 0);
        insert(&mut b, 13, 0);
        insert(&mut b, 12, 0);
        insert(&mut b, 17, 0);
        assert!(max<u8>(&b) == 99, E_MAX_INVALID);
        b // Return rather than unpack
    }

    #[test]
    /// Verify min and max reported as same value for singleton
    public(script) fun singleton_same():
    BST<u8> {
        let b = singleton<u8>(3, 0); // Start with singleton
        // Assert min and max for the BST yield same value
        assert!(min<u8>(&b) == 3, E_MIN_INVALID);
        assert!(max<u8>(&b) == 3, E_MAX_INVALID);
        b // Return rather than unpack
    }

    #[test]
    /// Verify correct index matches for various BST states
    public(script) fun get_i_success():
    BST<u8> {
        let b = empty<u8>(); // Start with empty BST
        // Assert NIL flag since empty
        assert!(get_i<u8>(&b, 0) == NIL, E_GET_I_ERROR); // Assert NIL flag
        insert(&mut b, 10, 0); // Add single element
        // Assert NIL flag for no match
        assert!(get_i<u8>(&b, 0) == NIL, E_GET_I_ERROR);
        // Assert index of 0 for match on first appended key
        assert!(get_i<u8>(&b, 10) == 0, E_GET_I_ERROR);
        insert(&mut b, 30, 0); // Add another element
        // Assert index of 1 for match on second appended key
        assert!(get_i<u8>(&b, 30) == 1, E_GET_I_ERROR);
        insert(&mut b, 5, 0); // Add another smaller element
        // Assert index of 2 for match on third appended key
        assert!(get_i<u8>(&b, 5) == 2, E_GET_I_ERROR);
        b // Return rather than unpack
    }

// Insertion and querying <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Update insert so cannot overwrite - quiet error?

}