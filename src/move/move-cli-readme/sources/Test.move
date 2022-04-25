module 0x2::Test {
    use Std::Signer;

    struct Resource has key {
        i: u64
    }

    public fun publish(
        account: &signer
    ) {
        move_to(account, Resource {i: 10})
    }

    public fun write(
        account: &signer,
        i: u64
    ) acquires Resource {
        borrow_global_mut<Resource>(Signer::address_of(account)).i = i;
    }

    public fun unpublish(
        account: &signer
    ) acquires Resource {
        let Resource {i: _} = move_from(Signer::address_of(account));
    }
}
