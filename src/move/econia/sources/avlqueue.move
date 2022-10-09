/// AVL queue: a hybrid between an AVL tree and a queue.
///
/// # References
///
/// * [Adelson-Velski and Landis 1962] (original paper)
/// * [Galles 2011] (interactive visualizer)
/// * [Wikipedia 2022]
///
/// [Adelson-Velski and Landis 1962]:
///     https://zhjwpku.com/assets/pdf/AED2-10-avl-paper.pdf
/// [Galles 2011]:
///     https://www.cs.usfca.edu/~galles/visualization/AVLtree.html
/// [Wikipedia 2022]:
///     https://en.wikipedia.org/wiki/AVL_tree
///
/// # Node IDs
///
/// Tree nodes and list nodes are each assigned a 0-indexed 14-bit
/// serial ID known as a node ID. Node ID `0b11111111111111` is reserved
/// for null, such that the maximum number of allocated nodes for each
/// node type is thus $2 ^ {14} - 1$.
///
/// # Access keys
///
/// | Bit(s) | Data                            |
/// |--------|---------------------------------|
/// | 61     | If set, ascending AVL queue     |
/// | 60     | If set, descending AVL queue    |
/// | 46-59  | Tree node ID                    |
/// | 32-45  | List node ID                    |
/// | 0-31   | Insertion key                   |
///
/// # Complete docgen index
///
/// The below index is automatically generated from source code:
module econia::avlqueue {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table::{Table};
    use aptos_std::table_with_length::{TableWithLength};
    use std::option::{Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// A hybrid between an AVL tree and a queue. See above.
    ///
    /// Most non-table fields stored compactly in `bits` as follows:
    ///
    /// | Bit(s)  | Data                                  |
    /// |---------|---------------------------------------|
    /// | 127     | If set, ascending AVL queue           |
    /// | 126     | If set, descending AVL queue          |
    /// | 112-125 | Tree node ID at top of inactive stack |
    /// | 98-111  | List node ID at top of inactive stack |
    /// | 84-97   | AVL queue head list node ID           |
    /// | 52-83   | AVL queue head insertion key          |
    /// | 38-51   | AVL queue tail list node ID           |
    /// | 6-37    | AVL queue tail insertion key          |
    /// | 0-5     | Bits 8-13 of tree root node ID        |
    ///
    /// Bits 0-7 of the tree root node ID are stored in `root_lsbs`.
    struct AVLqueue<V> has store {
        bits: u128,
        root_lsbs: u8,
        /// Map from tree node ID to tree node.
        tree_nodes: TableWithLength<u64, TreeNode>,
        /// Map from list node ID to list node.
        list_nodes: TableWithLength<u64, ListNode>,
        /// Map from list node ID to optional insertion value.
        insertion_values: Table<u64, Option<V>>
    }

    /// A tree node in an AVL queue.
    ///
    /// All fields stored compactly in `bits` as follows:
    ///
    /// | Bit(s) | Data                                 |
    /// |--------|--------------------------------------|
    /// | 87-118 | Insertion key                        |
    /// | 86     | If set, balance factor is 1          |
    /// | 85     | If set, balance factor is 0          |
    /// | 84     | If set, balance factor is -1         |
    /// | 70-83  | Parent node ID                       |
    /// | 56-69  | Left child node ID                   |
    /// | 42-55  | Right child node ID                  |
    /// | 28-41  | List head node ID                    |
    /// | 14-27  | List tail node ID                    |
    /// | 0-13   | Next inactive node ID, when in stack |
    struct TreeNode has store {
        bits: u128
    }

    /// A list node in an AVL queue.
    ///
    /// For compact storage, last and next values are split into two
    /// `u8` fields each: one for most-significant bits (`last_msbs`,
    /// `next_msbs`), and one for least-significant bits (`last_lsbs`,
    /// `next_lsbs`).
    ///
    /// When set at bit 14, the 16-bit concatenated result of `_msbs`
    /// and `_lsbs` fields, in either case, refers to a tree node ID: If
    /// `last_msbs` and `last_lsbs` indicate a tree node ID, then the
    /// list node is the head of the list at the given tree node. If
    /// `next_msbs` and `next_lsbs` indicate a tree node ID, then the
    /// list node is the tail of the list at the given tree node.
    ///
    /// If not set at bit 14, the corresponding node ID is either the
    /// last or the next list node in the doubly linked list.
    ///
    /// In only the case of the next node ID, if set at bit 15 and bit
    /// 14, the next node is the next inactive list node in the
    /// inactive list nodes stack.
    struct ListNode has store {
        last_msbs: u8,
        last_lsbs: u8,
        next_msbs: u8,
        next_lsbs: u8
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}