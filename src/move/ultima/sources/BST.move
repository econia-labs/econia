/// Red-black binary search tree
module Ultima::BST {
    use Std::Vector;

// Constants -----------------------------------------------------------

    // Error codes
    const E_ROOT_INIT: u64 = 0;
    const E_KEYS_INIT: u64 = 1;
    const E_VALS_INIT: u64 = 2;
    const E_DESTROY_KEYS_EMPTY: u64 = 3;
    const E_DESTROY_KEYS_NULL: u64 = 4;
    const E_DESTROY_VALS_EMPTY: u64 = 5;
    const E_L_ROTATE_NO_R_CHILD: u64 = 6;

    /// Flag to indicate that there is no connected node for the given
    /// relationship field (`parent`, `left`, or `right`), analagous to
    /// a null pointer
    const NULL: u64 = 0xffffffffffffffff;
    /// Maximum number of nodes that can be kept in the tree, equivalent
    /// to `NULL` - 1
    const MAX_NODES: u64 = 0xfffffffffffffffe;
    /// Flag for black node
    const BLACK: bool = true;
    /// Flag for red node
    const RED: bool = false;

// Constants -----------------------------------------------------------

// Structs -------------------------------------------------------------

    /// Contains a vector of `Node`, each with a `key` field, such that
    /// each `Node` is stored at an index in `nodes` identical to the
    /// storage index of its `key`'s corresponding value, per the
    /// recommended data structure template in `MockBST`.
    struct Keys has store {
        root: u64, // Index of root node
        nodes: vector<Node>, // Nodes
    }

    /// A single node in the tree, containing a key but not a
    /// corresponding value. Ideally, values from the key-value pair
    /// would simply be stored in a `Node.value` field of `ValueType`,
    /// with `Node` taking the generically-typed form
    /// `Node<phantom ValueType>`. But this kind of dynamic typing
    /// is forbidden in Move, so values must be stored per a data
    /// structure like that specified by `MockBST`.
    struct Node has store {
        key: u64, // Key
        color: bool, // Black or red
        parent: u64, // Parent node index
        left: u64, // Left child node index
        right: u64, // Right child node index
    }

    /// A mock resource type for modelling and testing key-value pair
    /// operations
    struct MockValueType has store {
        field: u8
    }

    /// A mock instantiation of a binary search tree containing
    /// key-value pairs, where each `Node` in `keys` corresponds to the
    /// `MockValueType` in `values` at the same vector index.
    /// Ideally, values would more simply be stored as fields within
    /// each `Node`, but Move's typing constraints prohibit this data
    /// structure. See `new_mock_bst()` for recommended initialization
    /// pattern, and `destroy_empty_mock_bst()` for recommended destruct
    /// pattern
    struct MockBST has store {
        keys: Keys,
        values: vector<MockValueType>
    }

// Structs -------------------------------------------------------------

// Initialization ------------------------------------------------------

    /// Return an empty `Keys` resource
    public fun new_keys(): Keys {
        Keys{root: NULL, nodes: Vector::empty<Node>()}
    }

    /// Return an empty vector of `ValueType`
    public fun new_values<ValueType: store>():
    vector<ValueType> {
        Vector::empty<ValueType>()
    }

    /// Return initialized BST per recommended initialization pattern:
    /// `YourBST{keys: new_keys(), values: new_values<YourValueType>()}`
    fun new_mock_bst():
    MockBST {
        MockBST{keys: new_keys(), values: new_values<MockValueType>()}
    }

    #[test]
    /// Verify that a Mock BST is initialized empty
    fun new_keys_success(): MockBST {
        let mock_bst = new_mock_bst();
        assert!(mock_bst.keys.root == NULL, E_ROOT_INIT);
        assert!(Vector::is_empty<Node>(&mock_bst.keys.nodes), E_KEYS_INIT);
        let v = &mock_bst.values;
        assert!(Vector::is_empty<MockValueType>(v), E_VALS_INIT);
        mock_bst

    }
// Initialization ------------------------------------------------------

// Destruction ---------------------------------------------------------

    /// Destroy a `Keys` resource, assuming it has null `root` and empty
    /// `nodes` vector
    fun destroy_empty_keys(
        keys: Keys
    ) {
        assert!(Vector::is_empty(&keys.nodes), E_DESTROY_KEYS_EMPTY);
        let Keys{root, nodes} = keys;
        assert!(root == NULL, E_DESTROY_KEYS_NULL);
        Vector::destroy_empty<Node>(nodes);
    }

    /// Destroy a vector of values assuming it is empty
    fun destroy_empty_values<ValueType>(
        values: vector<ValueType>
    ) {
        assert!(Vector::is_empty(&values), E_DESTROY_VALS_EMPTY);
        Vector::destroy_empty<ValueType>(values);
    }

    /// Destroy keys and values in an empty BST
    public fun destroy_empty_bst<ValueType>(
        keys: Keys,
        values: vector<ValueType>
    ) {
        destroy_empty_keys(keys);
        destroy_empty_values(values);
    }

    /// Destroy empty BST per recommended destruct pattern:
    /// `let YourBST{keys, values} = your_bst;
    /// destroy_empty_bst<YourValueType>(keys, values);`
    fun destroy_empty_mock_bst(
        mock_bst: MockBST,
    ) {
        let MockBST{keys, values} = mock_bst;
        destroy_empty_bst<MockValueType>(keys, values);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    /// Verify failure for trying to destroy non-empty `Keys` resource
    fun destroy_keys_not_empty() {
        let keys = new_keys();
        let node = Node{
            key: 1,
            color: RED,
            parent: NULL,
            left: NULL,
            right: NULL
        };
        Vector::push_back(&mut keys.nodes, node);
        destroy_empty_keys(keys);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    /// Verify failure for destroying `Keys` resource w/ non-NULL `root`
    fun destroy_keys_not_null() {
        let keys = new_keys();
        keys.root = 1;
        destroy_empty_keys(keys);
    }

    #[test]
    #[expected_failure(abort_code = 5)]
    /// Verify failure for attempting to destroy non-empty values vector
    fun destroy_vals_not_empty() {
        let values = new_values<MockValueType>();
        Vector::push_back<MockValueType>(&mut values, MockValueType{field: 0});
        destroy_empty_values(values);
    }

    #[test]
    /// Verify empty BST can be destroyed
    fun destroy_bst_completion() {
        let mock_bst = new_mock_bst();
        destroy_empty_mock_bst(mock_bst);
    }

// Destruction ---------------------------------------------------------

/* Left rotation -------------------------------------------------------

           10                                 10
           / \                                / \
      (x) 5  15                          (y) 7  15
         / \          Left rotate           / \
        2   7 (y)        on 5          (x) 5   8
           / \         -------->          / \
          6   8                          2   6
*/

/*

    /// Left rotate on the given node
    fun left_rotate(
        keys: &mut Keys,
        x: &mut Node // Node to left rotate on (5 above)
    ) {
        // Assert has a right child
        assert!(x.right != NULL, E_L_ROTATE_NO_R_CHILD);
        // Right child becomes new root of subtree (7 in above diagram)
        let y = Vector::borrow_mut<Node>(keys.nodes, x.right);
        let x_i = y.parent;
        *x.right = y.left;
        if (y.left != NULL) {
            *Vector::borrow_mut<Node>(keys.nodes, y.left).parent = x_i;
        }
    }
*/

// Rotation ------------------------------------------------------------

}