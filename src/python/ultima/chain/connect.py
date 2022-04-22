"""Aptos network connection functionality

Per https://aptos.dev/tutorials/your-first-transaction
"""

import time
import requests

from types import SimpleNamespace
from typing import Any, Dict, Optional
from ultima.chain.account import Account

network_urls = SimpleNamespace(
    devnet = 'https://fullnode.devnet.aptoslabs.com',
    devnet_faucet = 'https://faucet.devnet.aptoslabs.com'
)
"""URLs for connecting to various Aptos network elements"""

default_max_gas_amount = 2000
"""Per Aptos official transaction tutorial"""

default_gas_unit_price = 1
"""Per Aptos official transaction tutorial"""

default_timeout_in_s = 600
"""Per Aptos official transaction tutorial"""

fields = SimpleNamespace(
    accounts = 'accounts',
    arguments = 'arguments',
    amount = 'amount',
    application_json = 'application/json',
    auth_key = 'auth_key',
    bytecode = 'bytecode',
    coin = 'coin',
    Content_Type = 'Content-Type',
    data = 'data',
    ed25519_signature = 'ed25519_signature',
    expiration_timestamp_secs = 'expiration_timestamp_secs',
    function = 'function',
    gas_currency_code = 'gas_currency_code',
    gas_unit_price = 'gas_unit_price',
    hash = 'hash',
    max_gas_amount = 'max_gas_amount',
    message = 'message',
    mint = 'mint',
    module_bundle_payload = 'module_bundle_payload',
    modules = 'modules',
    payload = 'payload',
    pending_transaction = 'pending transaction',
    public_key = 'public_key',
    resources = 'resources',
    script_function_payload = 'script_function_payload',
    sender = 'sender',
    sequence_number = 'sequence_number',
    signature = 'signature',
    signing_message = 'signing_message',
    testcoin_balance = '0x1::TestCoin::Balance',
    testcoin_transfer = '0x1::TestCoin::transfer',
    message_messageholder = 'Message::MessageHolder',
    message_set_message = 'Message::set_message',
    timeout = 'timeout',
    transaction = 'transaction',
    transactions = 'transactions',
    type = 'type',
    type_arguments = 'type_arguments',
    utf_8 = 'utf-8',
    value = 'value',
    XUS = 'XUS'
)
"""
Common field names, specified via callable attributes (to reduce typos)
"""

codes = SimpleNamespace(
    not_found = 404,
    processing = 202,
    success = 200
)
"""REST response codes"""

class RestClient:
    """Wrapper for Aptos-core REST API

    Attributes
    ----------
    url : str
        REST API url per :data:`~chain.connect.network_urls`
    """

    def __init__(self, url: str) -> None:
        self.url = url

    def account(self, account_address: str) -> Dict[str, str]:
        """Returns account sequence number and authentication key"""
        response = requests.get(
            f'{self.url}/{fields.accounts}/{account_address}'
        )
        assert response.status_code == codes.success, \
            f'{response.text} - {account_address}'
        return response.json()

    def account_resources(self, account_address: str) -> Dict[str, Any]:
        """Return all account resources"""
        response = requests.get(
            f'{self.url}/{fields.accounts}/{account_address}/'
            f'{fields.resources}'
        )
        assert response.status_code == codes.success, response.text
        return response.json()

    def generate_tx(
        self,
        sender: str,
        payload: Dict[str, Any],
        max_gas_amount: int = default_max_gas_amount,
        gas_unit_price: int = default_gas_unit_price,
        gas_currency_code: str = fields.XUS,
        timeout_in_s: int = default_timeout_in_s,
    ) -> Dict[str, Any]:
        """Generates request for a raw transaction

        Transaction request can be submitted to produce raw transaction,
        which can be signed and then submitted to the blockchain
        """
        account_data = self.account(sender)
        seq_num = int(account_data[fields.sequence_number])
        tx_request = {
            fields.sender: f'0x{sender}',
            fields.sequence_number: str(seq_num),
            fields.max_gas_amount: str(max_gas_amount),
            fields.gas_unit_price: str(gas_unit_price),
            fields.gas_currency_code: gas_currency_code,
            fields.expiration_timestamp_secs:
                str(int(time.time()) + timeout_in_s),
            fields.payload: payload
        }
        return tx_request

    def sign_tx(self, account_from: Account, tx_request: Dict[str, Any]) \
        -> Dict[str, Any]:
        """Sign transaction request in preparation for submission

        Transaction request should be generated per
        :meth:`~chain.connect.RestClient.generate_tx`
        """
        response = requests.post(
            f'{self.url}/{fields.transactions}/{fields.signing_message}',
            json=tx_request
        )
        assert response.status_code == codes.success, response.text
        to_sign = bytes.fromhex(response.json()[fields.message][2:])
        signature = account_from.signing_key.sign(to_sign).signature
        tx_request[fields.signature] = {
            fields.type: fields.ed25519_signature,
            fields.public_key: f'0x{account_from.pub_key()}',
            fields.signature: f'0x{signature.hex()}'
        }
        return tx_request

    def submit_tx(self, tx: Dict[str, Any]) ->Dict[str, Any]:
        """Submits signed transaction to blockchain"""
        headers = {fields.Content_Type: fields.application_json}
        response = requests.post(
            f'{self.url}/{fields.transactions}',
            headers=headers,
            json=tx
        )
        assert response.status_code == codes.processing, \
            f'{response.text} - {tx}'
        return response.json()

    def tx_pending(self, tx_hash: str) -> bool:
        """Returns True if tx not found or if pending"""
        response = requests.get(f'{self.url}/{fields.transactions}/{tx_hash}')
        if response.status_code == codes.not_found:
            return True
        assert response.status_code == codes.success, \
            f'{response.text} - {tx_hash}'
        return response.json()[fields.type] == fields.pending_transaction

    def wait_for_tx(self, tx_hash: str, time_in_s: int) -> None:
        """Wait for specified amount of time for transaction to clear"""
        count = 0
        while self.tx_pending(tx_hash):
            assert count < time_in_s, \
                f'{fields.transaction} {tx_hash} {fields.timeout}'
            time.sleep(1)
            count += 1

    def testcoin_balance(self, account_address: str) ->Optional[int]:
        """Return TestCoin balance associated with account"""
        resources = self.account_resources(account_address)
        for resource in resources:
            if resource[fields.type] == fields.testcoin_balance:
                return int(resource[fields.data][fields.coin][fields.value])
        return None

    def transfer_testcoin(
        self, account_from: Account, recipient: str, amount: int,
        max_gas_amount: int, gas_unit_price: int, gas_currency_code: str,
        timeout_in_s: int
    ) -> str:
        """Transfer specified TestCoin amount between accounts

        Returns
        -------
        str
            Sequence number of transaction
        """
        payload = {
            fields.type: fields.script_function_payload,
            fields.function: fields.testcoin_transfer,
            fields.type_arguments: [],
            fields.arguments: [
                f'0x{recipient}',
                str(amount)
            ]
        }
        tx_request = self.generate_tx(
            account_from.address(),
            payload,
            max_gas_amount=max_gas_amount,
            gas_unit_price=gas_unit_price,
            gas_currency_code=gas_currency_code,
            timeout_in_s=timeout_in_s)
        signed_tx = self.sign_tx(account_from, tx_request)
        result = self.submit_tx(signed_tx)
        return str(result[fields.hash])

class FaucetClient:
    """Wrapper for faucet

    Attributes
    ----------
    url : str
        Faucet REST API url per :data:`~chain.connect.network_urls`
    rest_client : RestClient
        An :class:`RestClient` instance
    """

    def __init__(self, url: str, rest_client: RestClient) -> None:
        self.url = url

    def fund_account(self, auth_key: str, amount: int) -> None:
        """Creates account if necessary, funds with specified amount"""
        txs  = requests.post(
            f'{self.url}/{fields.mint}?{fields.amount}={amount}&'
            f'{fields.auth_key}={auth_key}'
        )
        assert txs.status_code == codes.success, txs.text

class HelloBlockchainClient(RestClient):
    """Client for interacting with Hello Blockchain program

    Per Aptos official tutorial "Your first Move module"
    """
    def publish_module(self, account_from: Account, module_hex:str) -> str:
        """Publish new module to blockchain within specified account"""

        payload = {
            fields.type: fields.module_bundle_payload,
            fields.modules: [
                {fields.bytecode: f'0x{module_hex}'},
            ]
        }
        tx_request = self.generate_tx(account_from.address(), payload)
        signed_tx = self.sign_tx(account_from, tx_request)
        result = self.submit_tx(signed_tx)
        return str(result[fields.hash])

    def get_message(self, contract_address: str, account_address:str) -> \
        Optional[str]:
        """Retrieve resource `Message::MessageHolder::message`"""
        resources = self.account_resources(account_address)
        for resource in resources:
            if resource[fields.type] == \
                f'0x{contract_address}::{fields.message_messageholder}':
                return resource[fields.data][fields.message]
        return None

    def set_message(
        self, contract_address: str, account_from: Account, message:str
    ) -> str:
        """
        Optionally initialize, and set resource
        `Message::MessageHolder::message`

        Returns
        -------
        str
            Transaction hash
        """
        payload = {
            fields.type: fields.script_function_payload,
            fields.function:
                f'0x{contract_address}::{fields.message_set_message}',
            fields.type_arguments: [],
            fields.arguments: [
                message.encode(fields.utf_8).hex(),
            ]
        }
        tx_request = self.generate_tx(account_from.address(), payload=payload)
        signed_tx = self.sign_tx(account_from, tx_request)
        result = self.submit_tx(signed_tx)
        return str(result[fields.hash])