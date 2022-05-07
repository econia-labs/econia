/// Hackathon BST demo
module Ultima::AlnokiBST {
    use Std::Signer;
    use Ultima::BST::{
        BST,
        has_key,
        empty,
        get_ref,
        insert,
        max,
        min,
    };

    /// Holder for BST in global storage
    struct AlnokiBST has key {
        bst: BST<u64>
    }

    /// Publish a BST holder with an empty BST to signing account
    public(script) fun alnoki_publish(
        account: &signer
    ) {
        move_to<AlnokiBST>(account, AlnokiBST{bst: empty<u64>()});
    }

    /// Insert key-value pair to BST
    public(script) fun alnoki_insert(
        account: &signer,
        k: u64,
        v: u64
    ) acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &mut borrow_global_mut<AlnokiBST>(addr).bst;
        insert<u64>(bst, k, v);
    }

    /// Get min key in BST, return in tx
    public(script) fun alnoki_min(
        account: &signer,
    ): u64
    acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &borrow_global<AlnokiBST>(addr).bst;
        min<u64>(bst)
    }

    /// Get max key in BST, return in tx
    public(script) fun alnoki_max(
        account: &signer,
    ): u64
    acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &borrow_global<AlnokiBST>(addr).bst;
        max<u64>(bst)
    }

    /// Get value corresponding to provided key
    public(script) fun alnoki_get(
        account: &signer,
        k: u64
    ): u64
    acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &borrow_global<AlnokiBST>(addr).bst;
        *get_ref<u64>(bst, k)
    }

    /// Return true if BST has a node with the corresponding key
    public(script) fun alnoki_has_key(
        account: &signer,
        k: u64
    ): bool
    acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &borrow_global<AlnokiBST>(addr).bst;
        has_key<u64>(bst, k)
    }
}