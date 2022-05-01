"""Aptos REST interface functionality"""

import requests
import time

from typing import Any, Dict, Optional, Tuple, Union
from ultima.account import Account, hex_leader
from ultima.defs import (
    account_fields,
    api_url_types,
    e_msgs,
    member_names as members,
    module_names as modules,
    msg_sig_start_byte as start_byte,
    named_addrs as n_addrs,
    networks,
    payload_fields as p_fields,
    resource_fields as r_fields,
    rest_codes,
    rest_path_elems,
    rest_post_headers as h_fields,
    rest_query_fields as q_fields,
    rest_response_fields,
    rest_urls,
    seps,
    tx_defaults,
    tx_fields,
    tx_sig_fields,
    tx_timeout_granularity,
    ultima_modules as ums
)

APT = ums.Coin.members.APT
"""APT coin symbol"""

USD = ums.Coin.members.USD
"""USD coin symbol"""

def move_trio(
    address: str,
    module: str,
    member: str
) -> str:
    """Return a fully-specified, formatted Move identifier

    Parameters
    ----------
    address : str
        Account address without leading hex specifier
    module : str
        Move Module
    member : str
        Module member

    Returns
    -------
    str
        Formatted Move identifier

    Example
    -------
    >>> from ultima.rest import move_trio
    >>> move_trio('1', 'TestCoin', 'Balance')
    '0x1::TestCoin::Balance'
    """
    return f'{hex_leader(address)}::{module}::{member}'

def typed_trio(
    trio: str,
    type: str
) -> str:
    """Return a Move trio with type specifier

    Parameters
    ----------
    trio : str
        A Move trio per :func:`~rest.move_trio`
    type : str
        Type specifier

    Returns
    -------
    str
        Move trio with type specifier

    Example
    -------
    >>> from ultima.rest import typed_trio
    >>> typed_trio('0x123::Module::member', 'type_specifier')
    '0x123::Module::member<type_specifier>'
    """
    return trio + seps.lt + type + seps.gt

def coin_typed_trios(
    ultima_addr: str,
    module: str,
    member: str
) -> list[str]:
    """Return APT and USD typed trios for the specified module member

    Parameters
    ----------
    ultima_addr: str
        Ultima account address, without leading hex specifier
    module : str
        An Ultima module per :data:`~defs.ultima_modules`
    member : str
        An Ultima module member per :data:`~defs.ultima_modules`

    Returns
    -------
    list of str
        A typed trio for each coin

    Example
    -------
    >>> from ultima.rest import coin_typed_trios
    >>> coin_typed_trios('1a2b3c', 'Foo', 'bar') \
    # doctest: +NORMALIZE_WHITESPACE
    ['0x1a2b3c::Foo::bar<0x1a2b3c::Coin::APT>',
     '0x1a2b3c::Foo::bar<0x1a2b3c::Coin::USD>']
    """
    untyped = move_trio(ultima_addr, module, member)
    [apt_t, usd_t] = [
        move_trio(ultima_addr, ums.Coin.name, coin) for coin in [APT, USD]
    ]
    return [typed_trio(untyped, coin_trio) for coin_trio in [apt_t, usd_t]]

def construct_script_payload(
    function: str,
    arguments: list[str] = [],
    type_arguments: list[str] = [],
) -> Dict[str, Any]:
    """Return a constructed script function payload

    Parameters
    ----------
    function : str
        A Move identifier per :func:`~rest.move_trio`
    arguments : list of str, optional
        Script arguments
    type_arguments : list of str, optional
        Script type arguments

    Returns
    -------
    dict from str to Any
        Constructed script payload

    Example
    -------
    >>> from ultima.rest import construct_script_payload as c
    >>> c('0x1::TestCoin::transfer', [f'0xf00', '123']) \
    # doctest: +NORMALIZE_WHITESPACE
    {'type': 'script_function_payload',
     'function': '0x1::TestCoin::transfer',
     'type_arguments': [],
     'arguments': ['0xf00', '123']}
    """
    return {
        p_fields.type: p_fields.script_function_payload,
        p_fields.function: function,
        p_fields.type_arguments: type_arguments,
        p_fields.arguments: arguments
    }

class Client:
    """Interface to Aptos blockchain REST API

    Parameters
    ----------
    network : str
        As specified in :data:`~defs.networks`

    Attributes
    ----------
    fullnode_url : str
        REST API url for fullnode interactions
    faucet_url : str
        REST API url for faucet

    Example
    -------
    >>> from ultima.defs import networks
    >>> from ultima.rest import Client
    >>> client = Client(networks.devnet)
    >>> client.fullnode_url
    'https://fullnode.devnet.aptoslabs.com'
    >>> client.faucet_url
    'https://faucet.devnet.aptoslabs.com'
    """

    def __init__(
        self,
        network: str = networks.devnet
    ) -> None:
        self.fullnode_url = rest_urls[network][api_url_types.fullnode]
        self.faucet_url = rest_urls[network][api_url_types.faucet]

    def construct_request_url(
        self,
        path_elems: list[str],
        query_pairs: dict[str, str] = None,
        faucet = False
    ) -> str:
        """Construct a REST request URL

        Parameters
        ----------
        path_elems : list of str
            Path elements to include in REST URL
        query_pairs : dict from str to str, optional
            Map from REST query string keys to values
        faucet : bool, optional
            Submit to faucet if True, otherwise to fullnode

        Returns
        -------
        str
            Constructed REST query URL

        Example
        -------
        >>> from ultima.defs import networks
        >>> from ultima.rest import Client
        >>> client = Client(networks.devnet)
        >>> client.construct_request_url(
        ...     ['foo', 'bar'],
        ...     query_pairs={'do_it': 'yes', 'say_it': 'no'},
        ...     faucet=True
        ... )
        'https://faucet.devnet.aptoslabs.com/foo/bar?do_it=yes&say_it=no'
        """
        url = f'{self.fullnode_url}'
        if faucet:
            url = f'{self.faucet_url}'
        for elem in path_elems:
            url = url + seps.sls + elem
        if query_pairs is not None:
            url = url + seps.qm
            for key in query_pairs:
                if not url.endswith(seps.qm):
                    url = url + seps.amp
                url = url + key + seps.eq + query_pairs[key]
        return url

    def get_request_response(
        self,
        path_elems: list[str],
        query_pairs: dict[str, str] = None,
        faucet: bool = False,
    ) -> object:
        """Construct and submit REST request, returning response

        Parameters
        ----------
        path_elems : list of str
            Path elements to include in REST URL
        query_pairs : dict from str to str, optional
            Map from REST query string keys to values
        faucet : bool, optional
            Submit to faucet if True, otherwise to fullnode

        Returns
        -------
        requests.models.Response
            Response from the REST API
        """
        return requests.get(
            self.construct_request_url(path_elems, query_pairs, faucet)
        )

    def run_request(
        self,
        path_elems: list[str],
        query_pairs: dict[str, str] = None,
        faucet: bool = False,
    ) -> Dict[str, Any]:
        """Submit REST request, assert success, return response

        Parameters
        ----------
        path_elems : list of str
            Path elements to include in REST URL
        query_pairs : dict from str to str, optional
            Map from REST query string keys to values
        faucet : bool, optional
            Submit to faucet if True, otherwise to fullnode

        Returns
        -------
        dict from str to Any
            REST request response JSON
        """
        response = self.get_request_response(path_elems, query_pairs, faucet)
        assert response.status_code == rest_codes.success, response.text
        return response.json()

    def get_post_response(
        self,
        path_elems: list[str],
        query_pairs: dict[str, str] = None,
        faucet: bool = False,
        json: Dict[str, Any] = None,
        headers: Dict[str, str] = None,
    ) -> object:
        """Construct and submit REST post, returning response

        Parameters
        ----------
        path_elems : list of str
            Path elements to include in REST URL
        query_pairs : dict from str to str, optional
            Map from REST query string keys to values
        faucet : bool, optional
            Submit to faucet if True, otherwise to fullnode
        json : dict from str to Any, optional
            JSON data
        headers : dict from str to str, optional
            Header values

        Returns
        -------
        requests.models.Response
            Response from the REST API
        """
        return requests.post(
            self.construct_request_url(path_elems, query_pairs, faucet),
            json=json,
            headers=headers
        )

    def run_post(
        self,
        path_elems: list[str],
        query_pairs: dict[str, str] = None,
        faucet: bool = False,
        json: Dict[str, Any] = None,
        headers: Dict[str, str] = None,
        status_code: int = rest_codes.success,
    ) -> Dict[str, Any]:
        """Submit REST post, assert given code, return response

        Parameters
        ----------
        path_elems : list of str
            Path elements to include in REST URL
        query_pairs : dict from str to str, optional
            Map from REST query string keys to values
        faucet : bool, optional
            Submit to faucet if True, otherwise to fullnode
        json : dict from str to Any, optional
            JSON data
        headers : dict from str to str, optional
            Header values
        code : str, optional
            Rest status code to assert

        Returns
        -------
        dict from str to Any
            REST post response JSON
        """
        response = self.get_post_response(
            path_elems,
            query_pairs,
            faucet,
            json,
            headers
        )
        assert response.status_code == status_code, response.text
        return response.json()

    def generate_tx(
        self,
        sender: str,
        payload: Dict[str, Any],
        max_gas_amount: int = tx_defaults.max_gas_amount,
        gas_unit_price: int = tx_defaults.gas_unit_price,
        gas_currency_code: str = tx_defaults.gas_currency_code,
        timeout_in_s: int = tx_defaults.timeout_in_s
    ) -> Dict[str, Any]:
        """Generate and return request for transaction

        Parameters
        ----------
        sender : str
            Signer of transaction
        payload : dict from str to Any
            Transaction payload data
        max_gas_amount : int, optional
            Maximum amount of gas to pay
        gas_unit_price : int, optional
            Unit price of gas
        gas_currency_code : str, optional
            Gas currency specifier
        timeout_in_s : int, optional
            How long to wait before transaction expires

        Returns
        -------
        dict from str to Any
            Transaction request
        """
        account_data = self.account(sender)
        seq_number = int(account_data[account_fields.sequence_number])
        timeout_stamp = str(int(time.time()) + timeout_in_s)
        return {
            tx_fields.sender: hex_leader(sender),
            tx_fields.sequence_number: str(seq_number),
            tx_fields.max_gas_amount: str(max_gas_amount),
            tx_fields.gas_unit_price: str(gas_unit_price),
            tx_fields.gas_currency_code: gas_currency_code,
            tx_fields.expiration_timestamp_secs: timeout_stamp,
            tx_fields.payload: payload
        }

    def sign_tx(
        self,
        account_from: Account,
        tx_request: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Sign transaction request in preparation for submission

        Parameters
        ----------
        account_from : ultima.account.Account
            Signing account
        tx_request : dict from str to Any
            Transaction request per
            :meth:`~rest.Client.generate_tx`

        Returns
        -------
        dict from str to Any
            Signed transaction request
        """
        response_json = self.run_post(
            [rest_path_elems.transactions, rest_path_elems.signing_message],
            json=tx_request
        )
        to_sign = bytes.fromhex(
            response_json[rest_response_fields.message][start_byte:]
        )
        signature = account_from.signing_key.sign(to_sign).signature
        tx_request[tx_fields.signature] = {
            tx_sig_fields.type: tx_sig_fields.ed25519_signature,
            tx_sig_fields.public_key: hex_leader(account_from.pub_key()),
            tx_sig_fields.signature: hex_leader(signature.hex())
        }
        return tx_request

    def submit_tx(
        self,
        tx: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Submit signed transaction to blockchain

        Parameters
        ----------
        tx : dict from str to Any
            Signed transaction

        Returns
        -------
        dict from str to Any
            REST post response JSON
        """
        return self.run_post(
            [rest_path_elems.transactions],
            headers={h_fields.content_type: h_fields.application_json},
            json=tx,
            status_code=rest_codes.processing
        )

    def tx_pending(
        self,
        tx_hash: str
    ) -> bool:
        """Return True if tx not found or if pending

        Parameters
        ----------
        tx_hash : str
            Transaction hash

        Returns
        -------
        True
            If transaction is not found or is pending
        """
        response = self.get_request_response([
            rest_path_elems.transactions,
            tx_hash
        ])
        if response.status_code == rest_codes.not_found:
            return True
        assert response.status_code == rest_codes.success, response.text
        return response.json()[rest_response_fields.type] == \
            rest_response_fields.pending_transaction

    def wait_for_tx(
        self,
        tx_hash: str,
        time_in_s: int = tx_defaults.timeout_in_s
    ) -> None:
        """Wait for transaction to clear

        Parameters
        ----------
        tx_hash : str
            Transaction hash
        time_in_s : int, optional
            How long to wait before failure
        """
        count = 0
        while self.tx_pending(tx_hash):
            assert count < time_in_s, e_msgs.tx_timeout
            time.sleep(tx_timeout_granularity)
            count += tx_timeout_granularity

    def submit_to_completion(
        self,
        signer: Account,
        payload: Dict[str, Any]
    ) -> str:
        """Construct and send transaction, wait until no longer pending

        Parameters
        ----------
        signer : ultima.account.Account
            Signing account
        payload : dict from str to Any
            Transaction payload data

        Returns
        -------
        str
            Completed transaction hash
        """
        tx_request = self.generate_tx(signer.address(), payload)
        signed_tx = self.sign_tx(signer, tx_request)
        result = self.submit_tx(signed_tx)
        tx_hash = str(result[rest_response_fields.hash])
        self.wait_for_tx(tx_hash)
        return tx_hash

    def run_script(
        self,
        signer: Account,
        trio_list: list[str],
        args: list[str] = [],
        type_args: list[str] = [],
    ) -> str:
        """Run script transaction and return transaction hash

        Parameters
        ----------
        signer : ultima.account.Account
            Signing account
        trio_list : list of str
            A list of identifiers to submit to :func:`~rest.move_trio`
        args : list of str, optional
            Script arguments
        type_args : list of str, optional
            Script type arguments

        Returns
        -------
        str
            Completed transaction hash
        """
        trio = move_trio(*trio_list)
        payload = construct_script_payload(trio, args, type_args)
        return self.submit_to_completion(signer, payload)

    def publish_modules(
        self,
        signer: Account,
        module_bcs: list[str]
    ) -> str:
        """Publish module bytecode to blockchain account

        Parameters
        ----------
        signer : ultima.account.Account
            Signing account
        module_bcs : list of str
            List of bytecode hexstrings without leading hex specifier

        Returns
        -------
        str
            Transaction hash
        """
        payload = {
            p_fields.type: p_fields.module_bundle_payload,
            p_fields.modules : [
                {p_fields.bytecode: hex_leader(bc)} for bc in module_bcs
            ]
        }
        return self.submit_to_completion(signer, payload)

    def account(
        self,
        account_address: str
    ) -> Dict[str, str]:
        """Return account sequence number and authentication key

        Parameters
        ----------
        account_address : str
            Account address

        Returns
        -------
        dict from str to str
            Account info
        """
        return self.run_request([rest_path_elems.accounts, account_address])

    def account_resources(
        self,
        account_address: str
    ) -> Dict[str, Any]:
        """Return all account resources

        Parameters
        ----------
        account_address : str
            Account address

        Returns
        -------
        dict from str to Any
            Account resources
        """
        return self.run_request([
            rest_path_elems.accounts,
            account_address,
            rest_path_elems.resources
        ])

    def tx_meta(
        self,
        tx_hash: str
    ) -> Dict[str, Any]:
        """Return transaction metadata

        Parameters
        ----------
        tx_hash : str
            The hash of the transaction to check

        Returns
        -------
        dict from str to Any
            Transaction metadata
        """
        return self.run_request([rest_path_elems.transactions, tx_hash])

    def tx_successful(
        self,
        tx_hash: str
    ) -> bool:
        """Return if transaction was successful

        Parameters
        ----------
        tx_hash : str
            Transaction hash

        Returns
        -------
        bool
            True if successful, false if not
        """
        return self.tx_meta(tx_hash)[tx_fields.success] == True

    def testcoin_balance(
        self,
        account_address: str
    ) -> Optional[int]:
        """Return TestCoin balance associated with account

        Parameters
        ----------
        account_address : str
            Address to check TestCoin balance of

        Returns
        -------
        int or None
            Amount of TestCoin if address has balance, None if not
        """
        resources = self.account_resources(account_address)
        balance_trio = \
            move_trio(n_addrs.Std, modules.TestCoin, members.Balance)
        for resource in resources:
            if resource[r_fields.type] == balance_trio:
                return int(resource[r_fields.data][r_fields.coin]\
                    [r_fields.value])
        return None

    def mint_testcoin(
        self,
        auth_key: str,
        amount: int
    ) -> str:
        """Create account if necessary, fund with TestCoin

        Parameters
        ----------
        auth_key : str
            Account authentication key
        amount : int
            Amount of TestCoin to request from faucet

        Returns
        -------
        str
            Minting transaction hash
        """
        response_json = self.run_post(
            [rest_path_elems.mint],
            {q_fields.amount: str(amount), q_fields.auth_key: auth_key},
            faucet=True
        )
        tx_hash = response_json[0]
        self.wait_for_tx(tx_hash)
        return tx_hash

    def transfer_testcoin(
        self,
        signer: Account,
        recipient: str,
        amount: int
    ) -> str:
        """Transfer TestCoin between accounts

        Parameters
        ----------
        signer : ultima.account.Account
            Signing account of sender
        recipient : str
            Receiving address
        amount : int
            Amount of TestCoin to transfer

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [n_addrs.Std, modules.TestCoin, members.transfer],
            [hex_leader(recipient), str(amount)]
        )

class UltimaClient(Client):
    """Aptos REST API interface with Ultima-specific functionality"""

    def get_typed_resource_data(
        self,
        addr: str,
        ultima_addr: str,
        module: str,
        member: str
    ) -> Tuple[
        Union[Dict[str, Any], None],
        Union[Dict[str, Any], None],
    ]:
        """Return date of typed account resource for member specifier

        Parameters
        ----------
        addr: str
            Address to check resources at
        ultima_addr: str
            Ultima account address, without leading hex specifier
        module : str
            An Ultima module per :data:`~defs.ultima_modules`
        member : str
            An Ultima module member per :data:`~defs.ultima_modules`

        Returns
        -------
        dict from str to Any or None
            APT resource data
        dict from str to Any or None
            USD resource data
        """
        [APT_tt, USD_tt] = coin_typed_trios(ultima_addr, module, member)
        result  = {APT: None, USD: None}
        for resource in self.account_resources(addr):
            for (key, tt) in [(APT, APT_tt), (USD, USD_tt)]:
                if resource[r_fields.type] == tt:
                    result[key] = resource[r_fields.data]
        return result[APT], result[USD]

    def publish_ultima_balances(
        self,
        signer: Account,
        ultima_addr: str
    ) -> str:
        """Publish empty APT and USD balance resources to an account

        Parameters
        ----------
        signer : ultima.account.Account
            Signing account to publish under
        ultima_addr: str
            Ultima account address, without leading hex specifier

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [ultima_addr, ums.Coin.name, ums.Coin.members.publish_balances]
        )

    def account_ultima_coin_balances(
        self,
        addr: str,
        ultima_addr: str
    ) -> Dict[str, Any]:
        """Return APT and USD coin holdings at given address

        Parameters
        ----------
        addr : str
            Address to check balances of
        ultima_addr: str
            Ultima account address, without leading hex specifier

        Returns
        -------
        dict from str to Any
            Holdings, in subunits, for each coin, if a balance has been
            initialized for the account
        """
        result = {APT: None, USD: None}
        APT_d, USD_d = self.get_typed_resource_data(
            addr,
            ultima_addr,
            ums.Coin.name,
            ums.Coin.members.Balance
        )
        coin = ums.Coin.fields.coin
        subunits = ums.Coin.fields.subunits
        for key, data in [(APT, APT_d), (USD, USD_d)]:
            if data is not None:
                result[key] = data[coin][subunits]
        return result

    def airdrop_ultima_coins(
        self,
        ultima_signer: Account,
        addr: str,
        apt_subunits: int = 0,
        usd_subunits: int = 0
    ) -> str:
        """Airdrop APT and USD coins to given address

        Parameters
        ----------
        ultima_signer : ultima.account.Account
            Airdrop authority, which should be Ultima account
        addr : str
            Address to mint to
        apt_subunits : int, optional
            Subunits of APT to mint
        usd_subunits : int, optional
            Subunits of USD to mint

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            ultima_signer,
            [ultima_signer.address(), ums.Coin.name, ums.Coin.members.airdrop],
            [addr, str(apt_subunits), str(usd_subunits)]
        )

    def transfer_ultima_coins(
        self,
        sender: Account,
        recipient: str,
        ultima_addr: str,
        apt_subunits: int = 0,
        usd_subunits: int = 0
    ) -> str :
        """Transfer APT and USD

        Parameters
        ----------
        sender : ultima.account.Account
            Account sending coins
        recipient : str
            Address to send to
        ultima_addr: str
            Ultima account address, without leading hex specifier
        apt_subunits : int, optional
            Subunits of APT to mint
        usd_subunits : int, optional
            Subunits of USD to mint

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            sender,
            [ultima_addr, ums.Coin.name, ums.Coin.members.transfer_both_coins],
            [recipient, str(apt_subunits), str(usd_subunits)]
        )

    def init_account(
        self,
        signer: Account,
        ultima_addr: str,
    ) -> str:
        """Initialize user account

        Parameters
        ----------
        signer: ultima.account.Account
            Account initializing an Ultima-specific Ultima::User::Account
        ultima_addr: str
            Ultima account address, without leading hex specifier

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [ultima_addr, ums.User.name, ums.User.members.init_account],
        )

    def deposit_coins(
        self,
        signer: Account,
        ultima_addr: str,
        apt_subunits: int,
        usd_subunits: int
    ) -> str:
        """Deposit coins from `Ultima::Coin::Balance` into collateral

        Parameters
        ----------
        signer: ultima.account.Account
            Account initializing an Ultima-specific Ultima::User::Account
        ultima_addr: str
            Ultima account address, without leading hex specifier
        apt_subunits : int
            Subunits of APT to deposit
        usd_subunits : int, optional
            Subunits of USD to deposit

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [ultima_addr, ums.User.name, ums.User.members.deposit_coins],
            [str(apt_subunits), str(usd_subunits)]
        )

    def withdraw_coins(
        self,
        signer: Account,
        ultima_addr: str,
        apt_subunits: int,
        usd_subunits: int
    ) -> str:
        """Withdraw coins from collateral into `Ultima::Coin::Balance`

        Parameters
        ----------
        signer: ultima.account.Account
            Account initializing an Ultima-specific Ultima::User::Account
        ultima_addr: str
            Ultima account address, without leading hex specifier
        apt_subunits : int
            Subunits of APT to deposit
        usd_subunits : int, optional
            Subunits of USD to deposit

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [ultima_addr, ums.User.name, ums.User.members.withdraw_coins],
            [str(apt_subunits), str(usd_subunits)]
        )

    def collateral_balances(
        self,
        addr: str,
        ultima_addr: str
    ) -> Dict[str, Any]:
        """Return APT and USD collateral balances

        Parameters
        ----------
        addr : str
            Address to check balances of
        ultima_addr: str
            Ultima account address, without leading hex specifier

        Returns
        -------
        dict from str to Any
            Holdings and available amount, in subunits, for each coin,
            if a collateral resource has been initialized for the
            account
        """
        result = {APT: None, USD: None}
        APT_d, USD_d = self.get_typed_resource_data(
            addr,
            ultima_addr,
            ums.User.name,
            ums.User.members.Collateral
        )
        available = ums.User.fields.available
        holdings = ums.User.fields.holdings
        subunits = ums.Coin.fields.subunits
        for key, data in [(APT, APT_d), (USD, USD_d)]:
            if data is not None:
                result[key] = {
                    holdings: data[holdings][subunits],
                    available: data[available]
                }
        return result