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

module_bytecode_dir = 'src/move/ultima/build/ultima/bytecode_modules'
"""Module bytecode directory, relative to ultima repository root"""

e_msgs = SimpleNamespace(
    path_val_collision = 'Different value already exists at provided path',
    tx_timeout = 'Transaction timeout'
)
"""Error messages"""

member_names = SimpleNamespace(
    Balance = 'Balance',
    publish_ultima_holdings = 'publish_ultima_holdings',
    transfer = 'transfer'
)
"""Move module member names"""

module_names = SimpleNamespace(
    Coins = 'Coins',
    TestCoin = 'TestCoin',
)
"""Move module names"""

msg_sig_start_byte = 2
"""
Byte within message from transaction request post response, after which
data should be signed. Per official Aptos transaction tutorial
"""

named_addrs = SimpleNamespace(
    Std = '1'
)
"""Named addresses (without leading hex specifier)"""

networks = SimpleNamespace(
    devnet = 'devnet'
)
"""Aptos cluster networks"""

payload_fields = SimpleNamespace(
    arguments = 'arguments',
    bytecode = 'bytecode',
    function = 'function',
    module_bundle_payload = 'module_bundle_payload',
    modules = 'modules',
    script_function_payload = 'script_function_payload',
    type = 'type',
    type_arguments = 'type_arguments'
)
"""Transaction payload fields"""

resource_fields = SimpleNamespace(
    coin = 'coin',
    data = 'data',
    type = 'type',
    value = 'value'
)
"""Move resource fields"""

rest_codes = SimpleNamespace(
    not_found = 404,
    processing = 202,
    success = 200
)
"""REST response codes"""

rest_path_elems = SimpleNamespace(
    accounts = 'accounts',
    mint = 'mint',
    resources = 'resources',
    signing_message = 'signing_message',
    transactions = 'transactions'
)
"""Rest API path elements"""

rest_post_headers = SimpleNamespace(
    content_type = 'Content-Type',
    application_json = 'application/json'
)
"""Rest post headers"""

rest_query_fields = SimpleNamespace(
    amount = 'amount',
    auth_key = 'auth_key'
)
"""Rest API URL query string fields"""

rest_response_fields = SimpleNamespace(
    hash = 'hash',
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

tx_sig_fields = SimpleNamespace(
    type = 'type',
    public_key = 'public_key',
    signature = 'signature',
    ed25519_signature = 'ed25519_signature',
)
"""Transaction signature fields"""

tx_timeout_granularity = 0.1
"""How long to wait between querying REST API for transaction status"""
