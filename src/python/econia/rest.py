"""Aptos REST interface functionality"""

import pandas as pd
import requests
import time

from decimal import Decimal as dec
from math import trunc
from typing import Any, Dict, Optional, Tuple, Union
from econia.account import Account, hex_leader
from econia.defs import (
    account_fields,
    api_url_types,
    coin_scales,
    e_msgs,
    econia_bool_maps as ebms,
    econia_modules as ems,
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
    test_coins,
    tx_defaults,
    tx_fields,
    tx_sig_fields,
    tx_timeout_granularity
)

APT = test_coins.APT.name
"""str: APT coin symbol"""

USD = test_coins.USD.name
"""str: USD coin symbol"""

Buy = ebms.side[True]
"""str: Order side buy indicator"""

Sell = ebms.side[False]
"""str: Order side sell indicator"""

scale_map = {APT: coin_scales.APT, USD: coin_scales.USD}
"""Map from coin symbol to scale"""

def get_side_bool(
    text: str,
) -> bool:
    """Return bool corresponding to 'Buy' or 'Sell'

    Parameters
    ----------
    text : str
        'Buy' or 'Sell'

    Returns
    -------
    bool
        True for 'Buy', False, for 'Sell'
    """
    return [k for k in ebms.side.keys() if ebms.side[k] == text][0]

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
    >>> from econia.rest import move_trio
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
    >>> from econia.rest import typed_trio
    >>> typed_trio('0x123::Module::member', 'type_specifier')
    '0x123::Module::member<type_specifier>'
    """
    return trio + seps.lt + type + seps.gt

def coin_typed_trios(
    econia_addr: str,
    module: str,
    member: str
) -> list[str]:
    """Return APT and USD typed trios for the specified module member

    Parameters
    ----------
    econia_addr: str
        Econia account address, without leading hex specifier
    module : str
        An Econia module per :data:`~defs.econia_modules`
    member : str
        An Econia module member per :data:`~defs.econia_modules`

    Returns
    -------
    list of str
        A typed trio for each coin, APT first

    Example
    -------
    >>> from econia.rest import coin_typed_trios
    >>> coin_typed_trios('1a2b3c', 'Foo', 'bar') \
    # doctest: +NORMALIZE_WHITESPACE
    ['0x1a2b3c::Foo::bar<0x1a2b3c::Coin::APT>',
     '0x1a2b3c::Foo::bar<0x1a2b3c::Coin::USD>']
    """
    untyped = move_trio(econia_addr, module, member)
    [apt_t, usd_t] = [
        move_trio(econia_addr, ems.Coin.name, coin) for coin in [APT, USD]
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
    >>> from econia.rest import construct_script_payload as c
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

def subs(
    units: Union[str, int],
    coin: str
) -> int:
    """Get integer subunits for specified amount of given coin

    Parameters
    ----------
    units : str or int
        Amount, in base units
    coin : str
        USD or APT

    Returns
    -------
    int
        Corresponding number of subunits

    Example
    -------
    >>> from econia.rest import subs
    >>> # Input as decimal str
    >>> subs('1.123', 'USD')
    1123000000000
    >>> # Input as int
    >>> subs(109, 'APT')
    109000000
    >>> # Truncating excess digits
    >>> subs('1.12345678', 'APT')
    1123456
    """
    assert type(units) == str or type(units) == int, e_msgs.decimal
    return trunc(int(dec(units) * 10 ** scale_map[coin]))

def units(
    subunits: int,
    coin: str
) -> dec:
    """Return base units corresponding to int subunits for given coin

    Parameters
    ----------
    subunits : int
        Number of subunits
    coin : str
        'APT' or 'USD'

    Returns
    -------
    decimal.Decimal
        Corresponding number of base units

    Example
    -------
    >>> from econia.rest import units
    >>> units(1234567, 'USD')
    Decimal('0.000001234567')
    >>> units(123456789, 'APT')
    Decimal('123.456789')
    """
    return dec(subunits) / (10 ** scale_map[coin])

def base_price(
    subunit_price: int
) -> dec:
    """Covert subunit price (USD subunits per APT subunit) to base price

    Parameters
    ----------
    subunit_price : int
        Limit price, in USD subunits, for one subunit of APT

    Returns
    -------
    decimal.Decimal
        Base price, quoted in USD per APT

    Example
    -------
    >>> from econia.rest import base_price
    >>> base_price(12345678)
    Decimal('12.345678')
    >>> base_price(150000000)
    Decimal('150')
    """
    return dec(subunit_price) * dec(10 ** scale_map[APT]) / \
        dec(10 ** scale_map[USD])

def subunit_price(
    base_price: Union[str, int],
) -> int:
    """Convert base price (USD per APT) to subunit price

    Parameters
    ----------
    base_price : str or int
        Amount of base units of USD per base unit of APT

    Returns
    -------
    subunit_price : int
        Price, in USD subunits per APT subunit

    Example
    -------
    >>> from econia.rest import subunit_price
    >>> subunit_price(123)
    123000000
    >>> subunit_price('4565.78023')
    4565780230
    """
    assert type(base_price) == str or type(base_price) == int, e_msgs.decimal
    return int(trunc(dec(base_price) * dec(10 ** scale_map[USD]) / \
        dec(10 ** scale_map[APT])))

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
    >>> from econia.defs import networks
    >>> from econia.rest import Client
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
        >>> from econia.defs import networks
        >>> from econia.rest import Client
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
        account_from : econia.account.Account
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
        signer : econia.account.Account
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
        signer : econia.account.Account
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

    def publish_module(
        self,
        signer: Account,
        module_bc: str,
    ) -> str:
        """Publish module bytecode to blockchain account

        Parameters
        ----------
        signer : econia.account.Account
            Signing account
        module_bcs : list of str
            Bytecode hexstring without leading hex specifier

        Returns
        -------
        str
            Transaction hash
        """
        payload = {
            p_fields.type: p_fields.module_bundle_payload,
            p_fields.modules : [{p_fields.bytecode: hex_leader(module_bc)}]
        }
        return self.submit_to_completion(signer, payload)

    def publish_modules(
        self,
        signer: Account,
        module_bcs: list[str]
    ) -> list[str]:
        """Publish multiple modules' bytecode as a single transaction

        Parameters
        ----------
        signer : econia.account.Account
            Signing account
        module_bcs : list of str
            List of bytecode hexstrings without leading hex specifier

        Returns
        -------
        list of str
            Transaction hashes for serialized loading
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

    def get_trio_data(
        self,
        trio: str,
        addr: str,
    ) -> Optional[Dict[str, Any]]:
        """Get resource data at the address for given trio

        Parameters
        ----------
        trio : str
            A Move trio per :func:`~rest.move_trio`
        addr: str
            Address to check resources at

        Returns
        -------
        dict from str to Any, or None
            Resource data for given trio
        """
        for resource in self.account_resources(addr):
            if resource[r_fields.type] == trio:
                return resource[r_fields.data]
        return None

    def tx_meta(
        self,
        tx_hash: str
    ) -> Dict[str, Any]:
        """Return transaction metadata

        Parameters
        ----------
        tx_hash : str
            Transaction hash, with leading hex specifier

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
            Transaction hash, with leading hex specifier

        Returns
        -------
        bool
            True if successful, false if not
        """
        return self.tx_meta(tx_hash)[tx_fields.success] == True

    def tx_version_number(
        self,
        tx_hash: str
    ) -> int:
        """Return transaction version number

        Parameters
        ----------
        tx_hash : str
            Transaction hash, with leading hex specifier

        Returns
        -------
        int
            Transaction version number
        """
        return int(self.tx_meta(tx_hash)[tx_fields.version])

    def tx_vn_url(
        self,
        tx_hash: str
    ) -> int:
        """Return link to transaction version number on explorer

        Parameters
        ----------
        tx_hash : str
            transaction hash, with leading hex specifier

        Returns
        -------
        str
            Compact URL to explorer for given tx
        """
        version_number = self.tx_version_number(tx_hash)
        tx_explorer_base = rest_urls[networks.devnet][api_url_types.explorer] \
            + seps.sls + rest_path_elems.txn + seps.sls
        return tx_explorer_base + str(version_number)

    def tx_vn_url_print(
        self,
        tx_hash: str
    ) -> None:
        """Print link to transaction version number on explorer

        Parameters
        ----------
        tx_hash : str
            transaction hash, with leading hex specifier
        """
        print(self.tx_vn_url(tx_hash))

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
        amount: int = tx_defaults.faucet_mint_val
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
        signer : econia.account.Account
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

class EconiaClient(Client):
    """Aptos REST API interface with Econia-specific functionality"""

    def get_resource_data(
        self,
        addr: str,
        econia_addr: str,
        module: str,
        member: str
    ) -> Optional[Dict[str, Any]]:
        """Get resource data at the address for given specifiers

        Parameters
        ----------
        addr: str
            Address to check resources at
        econia_addr: str
            Econia account address, without leading hex specifier
        module : str
            An Econia module per :data:`~defs.econia_modules`
        member : str
            An Econia module member per :data:`~defs.econia_modules`

        Returns
        -------
        dict from str to Any, or None
            Resource data for given member specifiers
        """
        return self.get_trio_data(move_trio(econia_addr, module, member), addr)

    def get_typed_resource_data(
        self,
        addr: str,
        econia_addr: str,
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
        econia_addr: str
            Econia account address, without leading hex specifier
        module : str
            An Econia module per :data:`~defs.econia_modules`
        member : str
            An Econia module member per :data:`~defs.econia_modules`

        Returns
        -------
        dict from str to Any or None
            APT resource data
        dict from str to Any or None
            USD resource data
        """
        [APT_tt, USD_tt] = coin_typed_trios(econia_addr, module, member)
        result  = {APT: None, USD: None}
        return \
            self.get_trio_data(APT_tt, addr), self.get_trio_data(USD_tt, addr)

    def publish_econia_balances(
        self,
        signer: Account,
        econia_addr: str
    ) -> str:
        """Publish empty APT and USD balance resources to an account

        Parameters
        ----------
        signer : econia.account.Account
            Signing account to publish under
        econia_addr: str
            Econia account address, without leading hex specifier

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [econia_addr, ems.Coin.name, ems.Coin.members.publish_balances]
        )

    def account_econia_coin_balances(
        self,
        addr: str,
        econia_addr: str
    ) -> Dict[str, Any]:
        """Return APT and USD coin holdings at given address

        Parameters
        ----------
        addr : str
            Address to check balances of
        econia_addr: str
            Econia account address, without leading hex specifier

        Returns
        -------
        dict from str to Any
            Holdings, in base units, for each coin, if a balance has
            been initialized for the account
        """
        result = {APT: None, USD: None}
        APT_d, USD_d = self.get_typed_resource_data(
            addr,
            econia_addr,
            ems.Coin.name,
            ems.Coin.members.Balance
        )
        coin = ems.Coin.fields.coin
        subunits = ems.Coin.fields.subunits
        for key, data in [(APT, APT_d), (USD, USD_d)]:
            if data is not None:
                result[key] = units(data[coin][subunits], key)
        return result

    def airdrop_econia_coins(
        self,
        econia_signer: Account,
        addr: str,
        apt: Union[str, int],
        usd: Union[str, int]
    ) -> str:
        """Airdrop APT and USD coins to given address

        Parameters
        ----------
        econia_signer : econia.account.Account
            Airdrop authority, which should be Econia account
        addr : str
            Address to mint to
        apt : str or int
            Amount of APT to mint, in base units
        usd : str or int
            Amount of USD to mint, in base units

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            econia_signer,
            [econia_signer.address(), ems.Coin.name, ems.Coin.members.airdrop],
            [addr, str(subs(apt, APT)), str(subs(usd, USD))]
        )

    def transfer_econia_coins(
        self,
        sender: Account,
        recipient: str,
        econia_addr: str,
        apt: Union[str, int] = 0,
        usd: Union[str, int] = 0,
    ) -> str :
        """Transfer APT and USD

        Parameters
        ----------
        sender : econia.account.Account
            Account sending coins
        recipient : str
            Address to send to
        econia_addr: str
            Econia account address, without leading hex specifier
        apt : str or int
            Base units of APT to transfer
        usd : int, optional
            Base units of USD to transfer

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            sender,
            [econia_addr, ems.Coin.name, ems.Coin.members.transfer_both_coins],
            [recipient, str(subs(apt, APT)), str(subs(usd, USD))]
        )

    def init_account(
        self,
        signer: Account,
        econia_addr: str,
    ) -> str:
        """Initialize user account

        Parameters
        ----------
        signer: econia.account.Account
            Account initializing an Econia-specific Econia::User::Account
        econia_addr: str
            Econia account address, without leading hex specifier

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [econia_addr, ems.User.name, ems.User.members.init_account],
        )

    def deposit_coins(
        self,
        signer: Account,
        econia_addr: str,
        apt: Union[str, int],
        usd: Union[str, int],
    ) -> str:
        """Deposit coins from `Econia::Coin::Balance` into collateral

        Parameters
        ----------
        signer: econia.account.Account
            Account initializing an Econia-specific
            Econia::User::Account
        econia_addr: str
            Econia account address, without leading hex specifier
        apt : str or int
            Amount of APT to deposit, in base units
        usd : str or int
            Amount of USD to deposit, in base units

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [econia_addr, ems.User.name, ems.User.members.deposit_coins],
            [str(subs(apt, APT)), str(subs(usd, USD))]
        )

    def withdraw_coins(
        self,
        signer: Account,
        econia_addr: str,
        apt: Union[str, int],
        usd: Union[str, int],
    ) -> str:
        """Withdraw coins from collateral into `Econia::Coin::Balance`

        Parameters
        ----------
        signer: econia.account.Account
            Account initializing an Econia-specific Econia::User::Account
        econia_addr: str
            Econia account address, without leading hex specifier
        apt : str or int
            Amount of APT to withdraw, in base units
        usd : str or int
            Amount of USD to withdraw, in base units

        Returns
        -------
        str
            Transaction hash
        """
        return self.run_script(
            signer,
            [econia_addr, ems.User.name, ems.User.members.withdraw_coins],
            [str(subs(apt, APT)), str(subs(usd, USD))]
        )

    def collateral_balances(
        self,
        addr: str,
        econia_addr: str
    ) -> Dict[str, Any]:
        """Return APT and USD collateral balances

        Parameters
        ----------
        addr : str
            Address to check balances of, without leading hex specifier
        econia_addr: str
            Econia account address, without leading hex specifier

        Returns
        -------
        dict from str to Any
            Holdings and available amount, in base units, for each coin,
            if a collateral resource has been initialized for the
            account
        """
        result = {APT: None, USD: None}
        APT_d, USD_d = self.get_typed_resource_data(
            addr,
            econia_addr,
            ems.User.name,
            ems.User.members.Collateral
        )
        available = ems.User.fields.available
        holdings = ems.User.fields.holdings
        subunits = ems.Coin.fields.subunits
        for key, data in [(APT, APT_d), (USD, USD_d)]:
            if data is not None:
                result[key] = {
                    holdings: units(data[holdings][subunits], key),
                    available: units(data[available], key)
                }
        return result

    def record_mock_order(
        self,
        econia: Account,
        addr: str,
        id: int,
        side: str,
        price: Union[str, int],
        unfilled: Union[str, int],
    ) -> str:
        """Record a mock order to a user's order history

        Parameters
        ----------
        econia : econia.account.Account
            The Econia account
        addr : str
            Address to record order at
        id : int
            Order id number
        side : str
            `Buy` if buying APT, `Sell` if selling APT
        price : str or int
            In base USD units per base unit of APT
        unfilled : str or int
            Amount remaining to match, in base APT units

        Returns
        -------
        str
            Transaction hash
        """
        record_mock_order = ems.User.members.record_mock_order
        side_bool = get_side_bool(side)
        price = str(subunit_price(price))
        unfilled = str(subs(unfilled, APT))
        return self.run_script(
            econia,
            [econia.address(), ems.User.name, record_mock_order],
            [addr, str(int(id)), side_bool, price, unfilled]
        )

    def open_orders(
        self,
        addr: str,
        econia_addr: str
    ) -> pd.DataFrame:
        """Get open orders for an address

        Parameters
        ----------
        addr : str
            Address to check, without leading hex specifier

        Returns
        -------
        pandas.DataFrame
            A cleaned ledger showing open orders in readable format
        """
        # Get data, store in pandas.DataFrame
        User = ems.User.name
        Orders = ems.User.members.Orders
        open = ems.User.fields.open
        data = self.get_resource_data(addr, econia_addr, User, Orders)[open]
        if len(data) == 0: return None
        df = pd.DataFrame.from_dict(data)

        # Sort columns to match original data structure
        id = ems.User.fields.id
        price = ems.User.fields.price
        side = ems.User.fields.side
        unfilled = ems.User.fields.unfilled
        df = df[[id, side, price, unfilled]]
        df.set_index(id, inplace=True)

        # Map side boolean values onto readable string
        df[side] = df[side].map(ebms.side)

        # Convert string representation of ints to floats, then scale
        df = df.astype({price: float, unfilled: float})
        df[price] = df[price] * (10 ** scale_map[APT]) / (10 ** scale_map[USD])
        df[unfilled] = df[unfilled] / (10 ** scale_map[APT])

        return df

    def trigger_match_order(
        self,
        econia: Account,
        addr: str,
        id: int,
        apt: Union[str, int],
        usd: Union[str, int]
    ) -> str:
        """Trigger a user-side order match

        Parameters
        ----------
        econia : econia.account.Account
            The Econia account
        addr : str
            Address to match at
        id : int
            Order id number
        apt : str or int
            In base APT units
        usd : str or int
            In base USD units

        Returns
        -------
        str
            Transaction hash
        """
        trigger = ems.User.members.trigger_match_order
        apt = str(subs(apt, APT))
        usd = str(subs(usd, USD))
        return self.run_script(
            econia,
            [econia.address(), ems.User.name, trigger],
            [addr, str(id), apt, usd]
        )