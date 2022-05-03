// Red-black binary search tree
module Ultima::BST {

    use Ultima::Book::Price as V;

    // Node colors
    const R: bool = true; // Red
    const B: bool = false; // Black

    // Flag options
    const NO_CHILD: u64 = 0xffffffffffffffff;

    // Key-value pairs have same index within their respective vectors
    struct BST has store {
        r: u64, // Index of root node
        n: vector<N>, // Nodes
    }

    // Tree node
    struct N has store {
        k: u64, // Key
        v: V, // Value
        c: bool, // Color
        p: u64, // Parent node index
        l: u64, // Left child node index
        r: u64, // Right child node index
    }
}
