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
        b // Return rather than unpack
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
        // Update root to index of first added node
        b.r = z_i;
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
        b // Return rather than unpack
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

// Right rotation <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// Red leaf insertion >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Insert key `k` and value `v` into BST `b` as a read leaf
    fun add_red_leaf<V>(
        b: &mut BST<V>,
        k: u64,
        v: V
    ) {
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
        add_red_leaf<u8>(&mut b, 2, 3); // Add node w/ key 2, value 3
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
        add_red_leaf<u8>(&mut b, 1, 3);
        b // Return rather than unpack (or signal to compiler as much)
    }

    #[test]
    /// Verify adding red leaf during left branching search
    fun add_red_leaf_left():
    BST<u8> {
        // Create BST with single key-value pair of (2, 3)
        let b = singleton<u8>(2, 3);
        // Add a red leaf with key-value pair (1, 4)
        add_red_leaf<u8>(&mut b, 1, 4);
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
        add_red_leaf<u8>(&mut b, 4, 5);
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
        add_red_leaf<u8>(&mut b, 1, 2);
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
        let b = singleton<u8>(1, 2);
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
        // Assert node does not register as having parent that is left
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
        // Assert node registers as having parent that is left child
        assert!(parent_is_l_child<u8>(&b, z_i), E_PARENT_L_C_INVALID);
        b // Return rather than unpack
    }

// Insertion cleanup helper functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}