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
    all_modules = 'All modules'
)

build_command_fields = SimpleNamespace(
    gen = 'gen',
    long = 'long',
    prep = 'prep',
    publish = 'publish',
    batch = 'batch'
)
"""Command line fields for automated building process"""

coin_scales = SimpleNamespace(
    APT = 6,
    USD = 12,
)
"""Decimal scalars for each coin"""

e_msgs = SimpleNamespace(
    path_val_collision = 'Different value already exists at provided path',
    tx_timeout = 'Transaction timeout',
    failed = 'failed',
    decimal = "Decimal values must be reported as str ('123.45') or int (123)",
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
    sp = ' '
)
"""Separators"""

single_sig_id = b'\x00'
"""1-byte signature scheme identifier, indicating single signature"""

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

Ultima = 'Ultima'
"""Project name"""

ultima_bool_maps = SimpleNamespace(
    side  = {True: 'Buy', False: 'Sell'},
)
"""Mapping from boolean values onto corresponding string"""

ultima_modules = SimpleNamespace(
    Book = SimpleNamespace(
        name = 'Book',
    ),
    Coin = SimpleNamespace(
        name = 'Coin',
        members = SimpleNamespace(
            airdrop = 'airdrop',
            APT = 'APT',
            Balance = 'Balance',
            publish_balances = 'publish_balances',
            transfer_both_coins = 'transfer_both_coins',
            USD = 'USD'
        ),
        fields = SimpleNamespace(
            coin = 'coin',
            subunits = 'subunits'
        )
    ),
    User = SimpleNamespace(
        name = 'User',
        members = SimpleNamespace(
            Collateral = 'Collateral',
            deposit_coins = 'deposit_coins',
            init_account = 'init_account',
            Orders = 'Orders',
            record_mock_order = 'record_mock_order',
            trigger_match_order = 'trigger_match_order',
            withdraw_coins = 'withdraw_coins',
        ),
        fields = SimpleNamespace(
            available = 'available',
            holdings = 'holdings',
            id = 'id',
            open = 'open',
            price = 'price',
            side = 'side',
            unfilled = 'unfilled'
        )
    )
)
"""Ultima Move modules with nested member specifiers"""

ultima_module_publish_order = [
    ultima_modules.Coin.name,
    ultima_modules.User.name,
    ultima_modules.Book.name,
]
"""Order to publish Move modules bytecode in"""

ultima_paths = SimpleNamespace(
    # Relative to Move package root directory
    bytecode_dir = 'build/ultima/bytecode_modules',
    # Relative to Ultima repository root directory
    move_package_root = 'src/move/ultima',
    # Relative to Move package root
    ss_path = 'ss',
    # Relative to Move package root
    toml_path = 'Move',
)
"""Ultima Move code paths"""

util_paths = SimpleNamespace(
    # Relative to Ultima repository root
    secrets_dir = '.secrets',
    # Relative to secrets directory
    old_keys = 'old',
    # Ultima repository root relative to `src/jupyter`
    ultima_root_rel_jupyter = '../..'
)
"""Paths to developer utility resources"""