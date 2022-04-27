// AptCoin and UsdCoin mint/transfer implementations

module Ultima::Coins {
    use Std::Signer;

    // Error codes
    const E_ALREADY_HAS_HOLDINGS: u64 = 0;
    const E_BALANCE_NOT_INIT_EMPTY: u64 = 1;
    const E_NOT_ULTIMA_SIGNER: u64 = 2;
    const E_WRONG_MINT_BALANCE: u64 = 3;
    const E_INSUFFICIENT_BALANCE: u64 = 4;
    const E_SAME_ADDRESS: u64 = 5;
    const E_WRONG_TRANSFER_AMOUNT: u64 = 6;

    // Coin type specifiers
    struct AptCoin {}
    struct UsdCoin {}

    // Generic coin type
    struct Coin<phantom CoinType> has store {
        subunits: u64
    }

    // Total holdings for a given user
    struct UltimaHoldings has key {
        apt: Coin<AptCoin>,
        usd: Coin<UsdCoin>
    }

    /* Publish an empty UltimaHoldings resource under an account address

    Must be called before minting/transferring to the account

    Parameters
    ----------
    account_ref : &signer
        Account to publish under

    Asserts
    -------
    E_ALREADY_HAS_HOLDINGS
        If a holdings resource is already published to given account
    */
    public fun publish_ultima_holdings(
        account_ref: &signer
    ) {
        let empty_apt = Coin<AptCoin>{subunits: 0};
        let empty_usd = Coin<UsdCoin>{subunits: 0};
        assert!(
            !exists<UltimaHoldings>(Signer::address_of(account_ref)),
            E_ALREADY_HAS_HOLDINGS
        );
        move_to(
            account_ref,
            UltimaHoldings{apt: empty_apt, usd: empty_usd}
        );
    }

    /* Return total holdings under an account address

    Parameters
    ----------
    owner : address
        Account to check holdings of

    Returns
    -------
    u64
        AptCoin subunits
    u64
        UsdCoin subunits

    Acquires
    --------
    UltimaHoldings
        Account's published AptCoin/UsdCoin holdings
    */
    public fun balance_of(
        owner: address
    ) : (
        u64,
        u64
    ) acquires UltimaHoldings {
        let apt_subunits = borrow_global<UltimaHoldings>(owner).apt.subunits;
        let usd_subunits = borrow_global<UltimaHoldings>(owner).usd.subunits;
        (apt_subunits, usd_subunits)
    }

    /* Deposit AptCoin and UsdCoin to given address

    Does not account for u64 overflow errors

    Parameters
    ----------
    addr : address
        Address to deposit to
    apt_coin: Coin<AptCoin>
        AptCoin to deposit
    usd_coin: Coin<UsdCoin>
        UsdCoin to deposit

    Acquires
    --------
    UltimaHoldings
        Account's published AptCoin/UsdCoin holdings
    */
    fun deposit(
        addr: address,
        apt_coin: Coin<AptCoin>,
        usd_coin: Coin<UsdCoin>
    ) acquires UltimaHoldings {
        let (apt_balance, usd_balance) = balance_of(addr);
        let apt_balance_ref_mut =
            &mut borrow_global_mut<UltimaHoldings>(addr).apt.subunits;
        let Coin{subunits: apt_subunits} = apt_coin;
        *apt_balance_ref_mut = apt_balance + apt_subunits;
        let usd_balance_ref_mut =
            &mut borrow_global_mut<UltimaHoldings>(addr).usd.subunits;
        let Coin{subunits: usd_subunits} = usd_coin;
        *usd_balance_ref_mut = usd_balance + usd_subunits;
    }

    /* Mint AptCoin and UsdCoin amount to the Ultima module address

    Can only be invoked by the Ultima module address

    Parameters
    ----------
    ultima_signer: signer
        The Ultima account
    apt_subunits: u64
        Amount of AptCoin subunits to mint
    usd_subunits: u64
        Amount of UsdCoin subunits to mint

    Acquires
    --------
    UltimaHoldings
        Account's published AptCoin/UsdCoin holdings

    Asserts
    -------
    E_NOT_ULTIMA_SIGNER
        If an arbitrary address tries to mint
    */
    public(script) fun mint(
        ultima_signer: signer,
        apt_subunits: u64,
        usd_subunits: u64
    ) acquires UltimaHoldings {
        assert!(
            Signer::address_of(&ultima_signer) == @Ultima,
            E_NOT_ULTIMA_SIGNER
        );
        deposit(
            Signer::address_of(&ultima_signer),
            Coin<AptCoin>{subunits: apt_subunits},
            Coin<UsdCoin>{subunits: usd_subunits}
        );
    }

    /* Withdraw AptCoin and UsdCoin from given address

    Parameters
    ----------
    addr : address
        Address to withdraw from
    apt_subunits : u64
        Amount of AptCoin to withdraw
    usd_subunits : u64
        Amount of UsdCoin to withdraw

    Returns
    -------
    Coin<AptCoin>
        AptCoin with specified amount of subunits
    Coin<UsdCoin>
        UsdCoin with specified amount of subunits

    Acquires
    --------
    UltimaHoldings
        Account's published AptCoin/UsdCoin holdings

    Asserts
    -------
    E_INSUFFICIENT_BALANCE
        If there is not enough to withdraw
    */
    fun withdraw(
        addr: address,
        apt_subunits: u64,
        usd_subunits: u64
    ) : (
        Coin<AptCoin>,
        Coin<UsdCoin>
    ) acquires UltimaHoldings {
        let (apt_balance, usd_balance) = balance_of(addr);
        assert!(apt_balance >= apt_subunits, E_INSUFFICIENT_BALANCE);
        assert!(usd_balance >= usd_subunits, E_INSUFFICIENT_BALANCE);
        let apt_balance_ref_m =
            &mut borrow_global_mut<UltimaHoldings>(addr).apt.subunits;
        *apt_balance_ref_m = apt_balance - apt_subunits;
        let usd_balance_ref_m =
            &mut borrow_global_mut<UltimaHoldings>(addr).usd.subunits;
        *usd_balance_ref_m = usd_balance - usd_subunits;
        (
            Coin<AptCoin>{subunits: apt_subunits},
            Coin<UsdCoin>{subunits: usd_subunits}
        )
    }

    /* Transfer AptCoin and UsdCoin between addresses

    Parameters
    ----------
    from : &signer
        Signer sending coins
    to : address
        Address recieving coins
    apt_subunits : u64
        Amount of AptCoin to transfer
    usd_subunits : u64
        Amount of UsdCoin to transfer

    Acquires
    --------
    UltimaHoldings
        Published AptCoin/UsdCoin holdings

    Asserts
    -------
    E_SAME_ADDRESS
        If sender and recipient are same address
    */
    public fun transfer(
        from: &signer,
        to: address,
        apt_subunits: u64,
        usd_subunits: u64,
    ) acquires UltimaHoldings {
        let from_addr = Signer::address_of(from);
        assert!(from_addr != to, E_SAME_ADDRESS);
        let (apt_coin, usd_coin) =
            withdraw(from_addr, apt_subunits, usd_subunits);
        deposit(to, apt_coin, usd_coin);
    }

    /* Verify that arbitrary user can properly initialize UltimaHoldings

    Parameters
    ----------
    account: signer
        Account to publish a holdings resource to

    Acquires
    --------
    UltimaHoldings
        Account's published AptCoin/UsdCoin holdings

    Asserts
    -------
    E_BALANCE_NOT_INIT_EMPTY
        If a balance is not initialized to 0
    */
    #[test(account = @TestUser1)]
    fun publish_balance_has_zero(
        account: signer
    ) acquires UltimaHoldings {
        let addr = Signer::address_of(&account);
        publish_ultima_holdings(&account);
        let(apt_subunits, usd_subunits) = balance_of(addr);
        assert!(apt_subunits == 0, E_BALANCE_NOT_INIT_EMPTY);
        assert!(usd_subunits == 0, E_BALANCE_NOT_INIT_EMPTY);
    }

    /* Verify error asserted when UltimaHoldings published twice

    Parameters
    ----------
    account: signer
        Account to publish a holdings resource to
    */
    #[test(account = @TestUser1)]
    #[expected_failure(abort_code = 0)]
    fun publish_holdings_twice_error(
        account: signer
    ) {
        publish_ultima_holdings(&account);
        publish_ultima_holdings(&account);
    }

    /* Verify Ultima address can mint AptCoin and UsdCoin to itself

    Parameters
    ----------
    ultima_signer: signer
        The Ultima account

    Acquires
    --------
    UltimaHoldings
        Account's published AptCoin/UsdCoin holdings

    Asserts
    -------
    E_WRONG_MINT_BALANCE
        If the wrong amount of AptCoin/UsdCoin is minted
    */
    #[test(ultima_signer = @Ultima)]
    public(script) fun mint_ultima(
        ultima_signer: signer
    ) acquires UltimaHoldings {
        let ultima_addr = Signer::address_of(&ultima_signer);
        publish_ultima_holdings(&ultima_signer);
        mint(ultima_signer, 123, 456);
        let(apt_subunits, usd_subunits) = balance_of(ultima_addr);
        assert!(apt_subunits == 123, E_WRONG_MINT_BALANCE);
        assert!(usd_subunits == 456, E_WRONG_MINT_BALANCE);
    }

    /* Verify unauthorized user cannot mint coins

    Parameters
    ----------
    not_ultima : signer
        Account that is not the Ultima address

    Acquires
    --------
    UltimaHoldings
        Account's published AptCoin/UsdCoin holdings
    */
    #[test(not_ultima = @TestUser1)]
    #[expected_failure(abort_code = 2)]
    public(script) fun unauthorized_minter(
        not_ultima: signer
    ) acquires UltimaHoldings {
        mint(not_ultima, 0, 0);
    }

    /* Verify Ultima address can mint and transfer to arbitrary user

    Parameters
    ----------
    not_ultima : signer
        arbitrary user address
    ultima_mint : signer
        Ultima address for minting transaction
    ultima_transfer : signer
        Ultima address for transfer transaction

    Asserts
    -------
    E_WRONG_TRANSFER_AMOUNT
        If wrong amount of a coin is in account post-transfer
    */
    #[test(
        not_ultima = @TestUser1,
        ultima_mint = @Ultima,
        ultima_transfer = @Ultima
    )]
    public(script) fun mint_and_transfer(
        not_ultima: signer,
        ultima_mint: signer,
        ultima_transfer: signer
    ) acquires UltimaHoldings {
        // Initialize both addresses to empty holdings
        publish_ultima_holdings(&not_ultima);
        publish_ultima_holdings(&ultima_mint);

        // Mint to Ultima address and transfer over
        let not_addr = Signer::address_of(&not_ultima);
        let ult_addr = Signer::address_of(&ultima_mint);
        mint(ultima_mint, 250, 1275);
        transfer(&ultima_transfer, not_addr, 100, 1000);
        let (not_apt, not_usd) = balance_of(not_addr);
        let (ult_apt, ult_usd) = balance_of(ult_addr);

        // Verify amounts
        assert!(not_apt == 100, E_WRONG_TRANSFER_AMOUNT);
        assert!(not_usd == 1000, E_WRONG_TRANSFER_AMOUNT);
        assert!(ult_apt == 150, E_WRONG_TRANSFER_AMOUNT);
        assert!(ult_usd == 275, E_WRONG_TRANSFER_AMOUNT);
    }
}
