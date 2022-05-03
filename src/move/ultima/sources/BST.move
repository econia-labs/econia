/// Red-black binary search tree
module Ultima::BST {

    //use Std::Vector;

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

    /// Contains a vector of `Node`, each with a `key` field, such that
    /// each `Node` is stored at an index in `nodes` identical to the
    /// storage index of its corresponding value, per `MockBST.values`.
    struct Keys has store {
        root: u64, // Index of root node
        nodes: vector<Node>, // Nodes
    }

    /// A single node in the tree, containing a key but not a
    /// corresponding value. Ideally, values from the key-value pair
    /// would simply be stored in a `value` field of type
    /// `vector<ValueType>`, with `Node` taking the generically-typed
    /// form `Node<phantom ValueType>`. But this kind of dynamic typing
    /// is forbidden in Move, so values must be stored per the data
    /// structure speficied by `MockBST`.
    struct Node has store {
        key: u64, // Key
        color: bool, // Black or red
        parent: u64, // Parent node index
        left: u64, // Left child node index
        right: u64, // Right child node index
        metadata: u8, // Color, nullity specifications
    }

    /// A mock value resource type for modelling and testing
    struct MockValueType {
        field: u8
    }

    /// A mock instantiation of a binary search tree containing
    /// key-value pairs, where each `Node` in `keys` corresponds to the
    /// `MockValueType` in `values` at the same  vector index.
    /// Ideally, values would more simply be stored as fields within
    /// each `Node`, but Move's typing constraints prohibit this data
    /// structure.
    struct MockBST {
        keys: Keys,
        values: vector<MockValueType>
    }
}
