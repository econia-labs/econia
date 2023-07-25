from typing import Any, List, Optional

from aptos_sdk.account import Account
from aptos_sdk.account_address import AccountAddress
from aptos_sdk.client import RestClient
from aptos_sdk.transactions import EntryFunction, TransactionPayload


class EconiaClient:
    econia_address: AccountAddress
    aptos_client: RestClient
    user_account: Account

    def __init__(self, node_url: str, econia: AccountAddress, account: Account):
        self.econia_address = econia
        self.aptos_client = RestClient(node_url)
        self.user_account = account

    def submit_tx(self, entry: EntryFunction) -> str:
        payload = TransactionPayload(entry)
        signed_tx = self.aptos_client.create_bcs_signed_transaction(
            self.user_account, payload
        )
        return self.aptos_client.submit_bcs_transaction(signed_tx)

    def submit_tx_wait(self, entry: EntryFunction) -> str:
        txn_hash = self.submit_tx(entry)
        self.aptos_client.wait_for_transaction(txn_hash)
        return txn_hash


class EconiaViewer:
    econia_address: AccountAddress
    aptos_client: RestClient

    def __init__(self, node_url: str, econia: AccountAddress):
        self.econia_address = econia
        self.aptos_client = RestClient(node_url)

    def get_returns(
        self,
        module: str,
        function: str,
        type_arguments: List[str] = [],
        arguments: List = [],  # string encoded args i.e "12345" or "0xabcdef" or "abracadabra"
        ledger_version: int = -1,
    ) -> List:
        if ledger_version < 0:
            request = f"{self.aptos_client.base_url}/view"
        else:
            request = f"{self.aptos_client.base_url}/view?ledger_version={ledger_version}"

        response = self.aptos_client.client.post(
            request,
            json={
                "function": f"{self.econia_address}::{module}::{function}",
                "type_arguments": type_arguments,
                "arguments": arguments,
            },
        )

        if response.status_code >= 400:
            raise Exception(response.text, response.status_code)
        return response.json()

    def get_events_by_handle(
        self,
        struct_type: str,  # i.e 0x1::account::Account
        field_name: str,
        limit: Optional[int] = None,
    ) -> Any:
        request = f"{self.aptos_client.base_url}/accounts/{self.econia_address.hex()}/events/{struct_type}/{field_name}"
        if limit is not None:
            request = f"{request}?limit={limit}"

        response = self.aptos_client.client.get(request)
        if response.status_code >= 400:
            raise Exception(response.text, response.status_code)
        return response.json()

    def get_events_by_creation_number(
        self,
        emission_address: AccountAddress,
        creation_number: int,
        limit: Optional[int] = None,
        start: Optional[int] = None,  # sequence number to start from
    ) -> Any:
        request = f"{self.aptos_client.base_url}/accounts/{emission_address.hex()}/events/{creation_number}"
        if limit is not None and start is not None:
            request = f"{request}?limit={limit}&start={start}"
        elif limit is not None:
            request = f"{request}?limit={limit}"
        elif start is not None:
            request = f"{request}?start={start}"

        response = self.aptos_client.client.get(request)
        if response.status_code >= 400:
            raise Exception(response.text, response.status_code)
        return response.json()
