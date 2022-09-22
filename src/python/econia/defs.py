"""Value definitions

Define all numbers/strings, etc. here so code has no unnamed values
"""

from types import SimpleNamespace

build_command_fields = SimpleNamespace(
    docgen = 'docgen',
    generate = 'generate',
    print_keyfile_address = 'print-keyfile-address',
    rev = 'rev',
    substitute = 'substitute'
)
"""Command line fields for automated building process"""

Econia = 'Econia'
"""Project name"""

econia_paths = SimpleNamespace(
    # Relative to Econia repository root directory
    move_package_root = 'src/move/econia',
    # Relative to Move package root
    ss_path = 'ss',
    # Relative to Move package root
    toml_path = 'Move',
)
"""Econia Move code paths"""

e_msgs = SimpleNamespace(
    path_val_collision = 'Different value already exists at provided path'
)
"""Error messages"""

file_extensions = SimpleNamespace(
    key = 'key',
    mv = 'mv',
    sh = 'sh',
    toml = 'toml'
)
"""Extensions for common filetypes"""

named_addrs = SimpleNamespace(
    econia = SimpleNamespace(
        docgen = 'c0deb00c',
        address_name = 'econia',
    )
)
"""Named addresses"""

regex_trio_group_ids = SimpleNamespace(
    start = 1,
    middle = 2,
    end = 3
)
"""For RegEx search yielding 3 group matches"""

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

toml_section_names = SimpleNamespace(
    addresses = 'addresses'
)
"""Section names in Move.toml file"""

util_paths = SimpleNamespace(
    # Relative to Econia repository root
    secrets_dir = '.secrets',
    # Relative to secrets directory
    old_keys = 'old',
    # Econia repository root relative to `src/jupyter`
    econia_root_rel_jupyter = '../..'
)
"""Paths to developer utility resources"""