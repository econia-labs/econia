/* Ultima atomic matching engine prototype

General formatting per Python PEP8 style guide
Function comments per NumPy docstring style guide
*/

module Ultima::Ultima {
    use Std::Signer;

    // Error codes
    const E_ALREADY_HAS_HOLDINGS: u64 = 0;
    const E_BALANCE_NOT_INIT_EMPTY: u64 = 1;
    const E_NOT_ULTIMA_SIGNER: u64 = 2;
    const E_WRONG_MINT_BALANCE: u64 = 3;

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
        Reference to account to publish under

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

    /* Deposit AptCoin and UsdCoin to given address

    Does not account for u64 overflow errors

    Parameters
    ----------
    addr : address
        Address to deposit to
    apt_subunits: u64
        Amount of AptCoin subunits to mint
    usd_subunits: u64
        Amount of UsdCoin subunits to mint

    Acquires
    --------
    UltimaHoldings
        Account's published AptCoin/UsdCoin holdings
    */
    fun deposit(
        addr: address,
        apt_subunits: u64,
        usd_subunits: u64
    ) acquires UltimaHoldings {
        let apt_holdings_ref_mut =
            &mut borrow_global_mut<UltimaHoldings>(addr).apt.subunits;
        *apt_holdings_ref_mut = *apt_holdings_ref_mut + apt_subunits;
        let usd_holdings_ref_mut =
            &mut borrow_global_mut<UltimaHoldings>(addr).usd.subunits;
        *usd_holdings_ref_mut = *usd_holdings_ref_mut + usd_subunits;
    }

    /* Mint AptCoin and UsdCoin amount to the Ultima module address

    Can only be invoked by the Ultima module address

    Parameters
    ----------
    ultima_signer: signer
        The Ultima module account
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
            apt_subunits,
            usd_subunits
        );
    }

    /* Verify Ultima address can mint AptCoin and UsdCoin to itself

    Parameters
    ----------
    ultima_signer: signer
        The Ultima module account

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
}