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
    explorer = 'explorer',
    fullnode = 'fullnode',
    faucet = 'faucet'
)
"""Types of REST API base urls"""

build_print_outputs = SimpleNamespace(
    account_msg = 'New account:',
)

build_command_fields = SimpleNamespace(
    gen = 'gen',
    long = 'long',
    prep = 'prep',
    publish = 'publish',
    serial = 'serial'
)
"""Command line fields for automated building process"""

coin_scales = SimpleNamespace(
    APT = 6,
    USD = 12,
)
"""Decimal scalars for each coin"""

Econia = 'Econia'
"""Project name"""

econia_bool_maps = SimpleNamespace(
    side  = {True: 'Buy', False: 'Sell'},
)
"""Mapping from boolean values onto corresponding string"""

econia_modules = SimpleNamespace(
    Book = SimpleNamespace(
        name = 'Book'
    ),
    Caps = SimpleNamespace(
        name = 'Caps'
    ),
    CritBit = SimpleNamespace(
        name = 'CritBit'
    ),
    ID = SimpleNamespace(
        name = 'ID'
    ),
    Orders = SimpleNamespace(
        name = 'Orders'
    ),
    Registry = SimpleNamespace(
        name = 'Registry'
    ),
    User = SimpleNamespace(
        name = 'User'
    ),
    Version = SimpleNamespace(
        name = 'Version'
    )
)
"""Econia Move modules with nested member specifiers"""

econia_module_publish_order = [
    [
        econia_modules.CritBit.name,
    ],
    [
        econia_modules.ID.name,
    ],
    [
        econia_modules.Book.name,
    ],
    [
        econia_modules.Orders.name,
    ],
    [
        econia_modules.Version.name,
        econia_modules.Caps.name,
        econia_modules.Registry.name,
        econia_modules.User.name,
    ],
]
"""
Order to publish Move modules bytecode in, with sublists indicating
batched modules that should be loaded together. Individual modules
should be defined as the sole element in a list if they are to be loaded
alone. If order within sub-batches is changed loading may break, for
instance among friends, where the module declaring a friend should be
listed before the declared friend.
"""

econia_paths = SimpleNamespace(
    # Relative to Move package root directory
    bytecode_dir = 'build/econia/bytecode_modules',
    # Relative to Econia repository root directory
    move_package_root = 'src/move/econia',
    # Relative to Move package root
    ss_path = 'ss',
    # Relative to Move package root
    toml_path = 'Move',
)
"""Econia Move code paths"""

e_msgs = SimpleNamespace(
    decimal = "Decimal values must be reported as str ('123.45') or int (123)",
    failed = 'failed',
    faucet = 'Faucet funding failed',
    path_val_collision = 'Different value already exists at provided path',
    tx_timeout = 'Transaction timeout',
    tx_submission = 'Transaction submission failed'
)
"""Error messages"""

file_extensions = SimpleNamespace(
    key = 'key',
    mv = 'mv',
    sh = 'sh',
    toml = 'toml'
)
"""Extensions for common filetypes"""

max_address_length = SimpleNamespace(
    aptos = 32,
    move_cli = 16,
)
"""Max address length in bytes"""

member_names = SimpleNamespace(
    Balance = 'Balance',
    transfer = 'transfer'
)
"""Move module member names"""

module_names = SimpleNamespace(
    TestCoin = 'TestCoin',
)
"""Move module names"""

msg_sig_start_byte = 2
"""
Byte within message from transaction request post response, after which
data should be signed. Per official Aptos transaction tutorial
"""

named_addrs = SimpleNamespace(
    Std = '1',
    Econia = 'c0deb00c' # For command-line testing
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

regex_trio_group_ids = SimpleNamespace(
    start = 1,
    middle = 2,
    end = 3
)
"""For RegEx search yielding 3 group matches"""

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
    transactions = 'transactions',
    txn = 'txn'
)
"""Rest API path elements"""

rest_post_headers = SimpleNamespace(
    content_type = 'Content-Type',
    application_json = 'application/json'
)
"""Rest post headers"""

rest_query_fields = SimpleNamespace(
    amount = 'amount',
    auth_key = 'auth_key',
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
        api_url_types.explorer: 'https://aptos-explorer.netlify.app'
    }
}
"""REST API urls"""

seps = SimpleNamespace(
    amp = '&',
    cln = ':',
    cma = ',',
    dot = '.',
    eq = '=',
    gt = '>',
    hex = '0x',
    lsb = '[',
    lt = '<',
    lp = '(',
    nl = '\n',
    pnd = '#',
    qm = '?',
    rp = ')',
    rsb = ']',
    sq = "'",
    sls = '/',
    sp = ' ',
    us = '_'
)
"""Separators"""

single_sig_id = b'\x00'
"""1-byte signature scheme identifier, indicating single signature"""

test_coins = SimpleNamespace(
    APT = SimpleNamespace(
        name = 'APT'
    ),
    USD = SimpleNamespace(
        name = 'USD'
    ),
)
"""Test coins"""

toml_section_names = SimpleNamespace(
    addresses = 'addresses'
)
"""Section names in Move.toml file"""

tx_defaults = SimpleNamespace(
    faucet_mint_val = 1_000_000,
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
    signature = 'signature',
    success = 'success',
    version = 'version'
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

util_paths = SimpleNamespace(
    # Relative to Econia repository root
    secrets_dir = '.secrets',
    # Relative to secrets directory
    old_keys = 'old',
    # Econia repository root relative to `src/jupyter`
    econia_root_rel_jupyter = '../..'
)
"""Paths to developer utility resources"""