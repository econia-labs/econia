// APT and USD coin minting/transfer functionality
module Ultima::Coin {
    use Std::ASCII;
    use Std::Event;
    use Std::Signer;

    // Errors
    const E_ALREADY_HAS_BALANCE: u64 = 0;

    // Coin type specifiers
    struct APT {}
    struct USD {}

    // Scale for converting subunits to decimal (base-10 exponent)
    // With a scale of 3, for example, 1 subunit = 0.001 base unit
    const APT_SCALE: u8 = 6;
    const USD_SCALE: u8 = 6;

    // Generic coin type
    struct UltimaCoin<phantom CoinType> has store {
        subunits: u64 // Indivisible subunits (e.g. Satoshi for BTC)
    }

    // Represents balance of each address
    struct Balance<phantom CoinType> has key {
        coin: UltimaCoin<CoinType>
    }

    // Publish empty balance resource under signer's account
    // Must be called before minting/transferring to the account
    public(script) fun publish_balance<CoinType>(
        account: &signer
    ) {
        let empty_coin = UltimaCoin<CoinType>{subunits: 0};
        assert!(
            !exists<Balance<CoinType>>(Signer::address_of(account)),
            E_ALREADY_HAS_BALANCE
        );
        move_to(account, Balance<CoinType>{coin: empty_coin});
    }

    // Publish APT and USD balances under the signer's account
    public(script) fun publish_balances(
        account: &signer
    ) {
        publish_balance<APT>(account);
        publish_balance<USD>(account);
    }

    struct MessageChangeEvent has drop, store {
        from_message: ASCII::String,
        to_message: ASCII::String
    }

    struct MessageHolder has key {
        message: ASCII::String,
        message_change_events: Event::EventHandle<MessageChangeEvent>
    }

    public fun get_message(
        addr: address
    ): ASCII::String
    acquires MessageHolder {
        *&borrow_global<MessageHolder>(addr).message
    }
    /*
    /*
    ) {
        _ = addr;
    }
    */
    */

    public(script) fun set_message(
        account: signer,
        message_bytes: vector<u8>
    ) acquires MessageHolder {
        let message = ASCII::string(message_bytes);
        let account_addr = Signer::address_of(&account);
        if (!exists<MessageHolder>(account_addr)) {
            move_to(&account, MessageHolder {
                message,
                message_change_events:
                    Event::new_event_handle<MessageChangeEvent>(&account)
            })
        } else {
            let old_message_holder =
                borrow_global_mut<MessageHolder>(account_addr);
            let from_message = *&old_message_holder.message;
            Event::emit_event(
                &mut old_message_holder.message_change_events,
                MessageChangeEvent {
                    from_message,
                    to_message: copy message
                }
            );
            old_message_holder.message = message;
        }
    }
}