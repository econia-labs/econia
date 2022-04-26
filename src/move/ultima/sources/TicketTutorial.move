// Per https://github.com/magnum6actual/Aptos-Tutorial

module TicketTutorial::Tickets {
   use Std::Signer;
   use Std::Vector;

   const E_NO_VENUE: u64 = 0;
   const E_NO_TICKETS: u64 = 1;
   const E_NO_ENVELOPE: u64 = 2;
   const E_INVALID_TICKET_COUNT: u64 = 3;
   const E_INVALID_TICKET: u64 = 4;
   const E_INVALID_PRICE: u64 = 5;
   const E_MAX_SEATS: u64 = 6;
   const E_INVALID_BALANCE: u64 = 7;

    struct ConcertTicket has key, store, drop {
        seat: vector<u8>,
        ticket_code: vector<u8>
    }

    struct Venue has key {
        available_tickets: vector<ConcertTicket>,
        max_seats: u64
    }

    public fun create_ticket(
        recipient: &signer,
        seat: vector<u8>,
        ticket_code: vector<u8>
    ) {
        move_to<ConcertTicket>(recipient, ConcertTicket {seat, ticket_code})
    }

    public fun init_venue(
        venue_owner: &signer,
        max_seats: u64
    ) {
        move_to<Venue>(
            venue_owner,
            Venue{
                available_tickets: Vector::empty<ConcertTicket>(),
                max_seats
            }
        )
        /* Alternatively, via two lines
        let available_tickets = Vector::empty<ConcertTicket>();
        move_to(venue_owner, Venue{available_tickets, max_seats})
        */
    }

    public fun available_ticket_count(
        venue_owner_addr: address
    ): u64 acquires Venue {
        Vector::length<ConcertTicket>(
            &borrow_global<Venue>(venue_owner_addr).available_tickets
        )
        /* Alternatively, via two lines
        let venue = borrow_global<Venue>(venue_owner_addr);
        Vector::length<ConcertTicket>(&venue.available_tickets)
        */
    }

    #[test(venue_owner = @0x1)]
    public(script) fun sender_can_buy_ticket(
        venue_owner: signer
    ) {
        init_venue(&venue_owner, 3); // Initialize the venue
        assert!(exists<Venue>(Signer::address_of(&venue_owner)), E_NO_VENUE)
    }

}