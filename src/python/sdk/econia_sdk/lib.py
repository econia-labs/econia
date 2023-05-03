from aptos_sdk.client import RestClient
from aptos_sdk.account_address import AccountAddress
from aptos_sdk.account import Account
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
