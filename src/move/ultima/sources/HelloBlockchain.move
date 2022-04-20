/*
Per https://aptos.dev/tutorials/your-first-move-module
*/
module HelloBlockchain::Message {
    use Std::ASCII;
    use Std::Errors;
    use Std::Event;
    use Std::Signer;

    struct MessageChangeEvent has drop, store {
        from_message: ASCII::String,
        to_message: ASCII::String
    }

    struct MessageHolder has key {
        message: ASCII::String,
        message_change_events: Event::EventHandle<MessageChangeEvent>
    }

    // No message
    const E_NO_MESSAGE: u64 = 0;

    public fun get_message(
        addr: address
    ): ASCII::String
    acquires MessageHolder {
        assert!(
            exists<MessageHolder>(addr),
            Errors::not_published(E_NO_MESSAGE)
        );
        *&borrow_global<MessageHolder>(addr).message
    }

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

    #[test(account = @0x1)]
    public(script) fun sender_can_set_message(
        account: signer
    ) acquires MessageHolder {
        let addr = Signer::address_of(&account);
        set_message(account, b"Hello, Blockchain");

        assert!(
            get_message(addr) == ASCII::string(b"Hello, Blockchain"),
            E_NO_MESSAGE
        );
    }
}