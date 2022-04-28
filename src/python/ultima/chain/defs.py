"""Value definitions

Define all numbers/strings, etc. here so code has no unnamed values
"""

from types import SimpleNamespace

account_fields = SimpleNamespace(
    authentication_key = 'authentication_key',
    sequence_number = 'sequence_number'
)
"""Account fields"""

api_url_types = SimpleNamespace(
    fullnode = 'fullnode',
    faucet = 'faucet'
)
"""Types of REST API base urls"""

e_msgs = SimpleNamespace(
    path_val_collision = 'Different value already exists at provided path',
    tx_timeout = 'Transaction timeout'
)
"""Error messages"""

networks = SimpleNamespace(
    devnet = 'devnet'
)
"""Aptos cluster networks"""

rest_codes = SimpleNamespace(
    not_found = 404,
    processing = 202,
    success = 200
)
"""REST response codes"""

rest_path_elems = SimpleNamespace(
    accounts = 'accounts',
    resources = 'resources',
    signing_message = 'signing_message',
    transactions = 'transactions'
)
"""Rest API path elements"""

rest_post_headers = SimpleNamespace(
    content_type = 'Content-Type',
    application_json = 'application/json'
)

rest_response_fields = SimpleNamespace(
    message = 'message',
    pending_transaction = 'pending_transaction',
    type = 'type'
)
"""Rest response fields"""

rest_urls = {
    networks.devnet: {
        api_url_types.fullnode: 'https://fullnode.devnet.aptoslabs.com',
        api_url_types.faucet: 'https://faucet.devnet.aptoslabs.com',
    }
}
"""REST API urls"""

msg_sig_start_byte = 2
"""
Byte within message from transaction request post response, after which
data should be signed. Per official Aptos transaction tutorial
"""

seps = SimpleNamespace(
    amp = '&',
    colon = '-',
    equal = '=',
    hex = '0x',
    q_mark = '?',
    slash = '/'
)
"""Separators"""

single_sig_id = b'\x00'
"""1-byte signature scheme identifier, indicating single signature"""

tx_sig_fields = SimpleNamespace(
    type = 'type',
    public_key = 'public_key',
    signature = 'signature',
    ed25519_signature = 'ed25519_signature',
)
"""Transaction signature fields"""

tx_defaults = SimpleNamespace(
    gas_currency_code = 'XUS',
    gas_unit_price = 1,
    max_gas_amount = 2000,
    timeout_in_s = 600
)
"""Default transaction metadata values per Aptos tutorial"""

tx_fields = SimpleNamespace(
    expiration_timestamp_secs = 'expiration_timestamp_secs',
    gas_currency_code = 'gas_currency_code',
    gas_unit_price = 'gas_unit_price',
    max_gas_amount = 'max_gas_amount',
    payload = 'payload',
    sender = 'sender',
    sequence_number = 'sequence_number',
    signature = 'signature'
)
"""Transaction fields"""
