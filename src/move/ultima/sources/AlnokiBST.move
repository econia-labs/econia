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

    /// Holder for BST in global storage, with query results
    struct AlnokiBST has key {
        bst: BST<u64>,
        result: u64,
    }

    /// Publish a BST holder with an empty BST to signing account
    public(script) fun alnoki_publish(
        account: &signer
    ) {
        move_to<AlnokiBST>(account, AlnokiBST{bst: empty<u64>(), result: 0});
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

    /// Get min key in BST, store value in result
    public(script) fun alnoki_min(
        account: &signer,
    ) acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &mut borrow_global_mut<AlnokiBST>(addr).bst;
        let result = min<u64>(bst);
        borrow_global_mut<AlnokiBST>(addr).result = result;
    }

    /// Get max key in BST, store value in result
    public(script) fun alnoki_max(
        account: &signer,
    ) acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &mut borrow_global_mut<AlnokiBST>(addr).bst;
        let result = max<u64>(bst);
        borrow_global_mut<AlnokiBST>(addr).result = result;
    }

    /// Get value corresponding to provided key, store in result
    public(script) fun alnoki_get(
        account: &signer,
        k: u64
    ) acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &mut borrow_global_mut<AlnokiBST>(addr).bst;
        let result = *get_ref<u64>(bst, k);
        borrow_global_mut<AlnokiBST>(addr).result = result;
    }

    /// Update result to 1 if BST has a node with the corresponding key
    public(script) fun alnoki_has_key(
        account: &signer,
        k: u64
    ) acquires AlnokiBST {
        let addr = Signer::address_of(account);
        let bst = &mut borrow_global_mut<AlnokiBST>(addr).bst;
        let result = if (has_key<u64>(bst, k)) 1 else 0;
        borrow_global_mut<AlnokiBST>(addr).result = result;
    }
}