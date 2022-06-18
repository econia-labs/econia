"""Move package building functionality

Relies on a ``.secrets`` folder inside Econia project root directory,
which contains a directory ``old``, hence ``econia/.secrets/old``

Some functionality abstracted to be run from the command line:

.. code-block:: zsh
    :caption: Generate new account, set Econia = "_" in ``Move.toml``

    # From Econia repository root directory
    % python src/python/econia/build.py gen
    New account: 1b41ccde69f967baf13f18005cba2172cc5555b163c9a4e4bda93ab9a4c38f53
    % < src/move/econia/Move.toml
    [package]
    name = 'Econia'
    ...
    Econia = '_'
    ...

.. code-block:: zsh
    :caption: Publish all module bytecode, replace Econia address

    # From Econia repository root directory
    % python src/python/econia/build.py publish .secrets/1b41ccde69f967baf13f18005cba2172cc5555b163c9a4e4bda93ab9a4c38f53.key . serial
    BST: success (https://aptos-explorer.netlify.app/txn/1291521)
    CritBit: success (https://aptos-explorer.netlify.app/txn/1291525)
    % < src/move/econia/Move.toml
    [package]
    name = 'Econia'
    ...
    Econia = '0x1234'
    ...
"""

import os
import re
import shutil
import sys

from pathlib import Path
from typing import Union
from econia.account import Account, hex_leader
from econia.defs import (
    build_command_fields,
    build_print_outputs,
    e_msgs,
    econia_module_publish_order as e_m_p_o,
    econia_paths as ps,
    Econia,
    file_extensions,
    max_address_length,
    named_addrs,
    networks,
    regex_trio_group_ids as r_i,
    seps,
    toml_section_names,
    tx_defaults,
    tx_fields,
    util_paths
)
from econia.rest import Client

def get_move_util_path(
    filename: str,
    file_extension: str,
    econia_root: str = seps.dot,
) -> str:
    """Return absolute path of file in Move package directory

    Parameters
    ----------
    filename : str
        The file name, without extension
    file_extension : str
        File extension
    econia_root : str, optional
        Relative path to Econia repository root directory

    Returns
    -------
    str
        Absolute path to given file
    """
    abs_path = os.path.join(
        os.path.abspath(econia_root),
        ps.move_package_root,
        filename + seps.dot + file_extension
    )
    assert os.path.isfile(abs_path), abs_path
    return abs_path

def get_toml_path(
    econia_root: str = seps.dot
) -> str:
    """Return absolute path of Move.toml file

    Parameters
    ----------
    econia_root : str, optional
        Relative path to Econia repository root directory

    Returns
    -------
    str
        Absolute path to Move.toml file
    """
    return get_move_util_path(ps.toml_path, file_extensions.toml, econia_root)

def get_sh_path(
    econia_root: str = seps.dot
) -> str:
    """Return absolute path of Move package .sh file

    Parameters
    ----------
    econia_root : str, optional
        Relative path to Econia repository root directory

    Returns
    -------
    str
        Absolute path to ss.sh file
    """
    return get_move_util_path(ps.ss_path, file_extensions.sh, econia_root)

def get_toml_lines(
    abs_path: str
) -> list[str]:
    """Return all lines from Move.toml file

    Parameters
    ----------
    abs_path : str
        Absolute path to Move.toml file

    Returns
    -------
    list of str
        All lines in file
    """
    return Path(abs_path).read_text().splitlines()

def is_address_line(
    line: str
) -> bool:
    """Return True if line has [addresses] section flag

    Parameters
    ----------
    line : str
        A line from a .toml file

    Returns
    -------
    bool
        True if is [addresses]
    """
    return line == seps.lsb + toml_section_names.addresses + seps.rsb

def get_addr_elems(
    line: str
) -> list[str]:
    """Split address line into name, address, comment tokens

    Parameters
    ----------
    line : str
        Address line

    Returns
    -------
    str
        The name of the address
    str
        The address, without a leading '0x'
    str or None
        The comment

    Example
    -------
    >>> from econia.build import get_addr_elems
    >>> get_addr_elems("Foo = '0x123abc' # 123abc")
    ('Foo', '123abc', '123abc')
    >>> get_addr_elems("Bar = '0x987cbd'")
    ('Bar', '987cbd', None)
    """
    comment = None
    match = re.search(r'(?<=' + seps.pnd + r'\s)\w+' , line)
    if match:
        comment = match.group(0)
    return (
        re.search(r'^\w+', line).group(0),
        re.search(r'(?<=' + seps.hex + r')\w+', line).group(0),
        comment
    )

def get_addr_bytes(
    hex: str
) -> bytes:
    """Return hexstring pre-padded with zeros as necessary

    Parameters
    ----------
    hex : str
        Hexstring of address with or without leading zeroes

    Returns
    -------
    byte
        Address bytes

    Example
    -------
    >>> from econia.build import get_addr_bytes
    >>> get_addr_bytes('1')
    b'\\x01'
    >>> get_addr_bytes('01')
    b'\\x01'
    """
    if len(hex) % 2 != 0: # If not even number of characters
        hex = '0' + hex
    return bytes.fromhex(hex)

def normalized_hex(
    addr_bytes: bytes
) -> str:
    """Output address bytes as hex string without leading zeroes

    Parameters
    ----------
    addr_bytes: bytes
        The address bytes

    Returns
    -------
    str
        Normalized hex string

    Example
    -------
    >>> from econia.build import normalized_hex
    >>> normalized_hex(b'\\x00\\x01')
    '1'
    """
    return addr_bytes.hex().lstrip('0')

def format_addr(
    name: str,
    addr: str,
    comment: object,
    long: bool
) -> str:
    """Format address in long or short form, returning full line

    Parameters
    ----------
    name : str
        The name of the address
    addr : str
        Hexstring address without leading hex identifier
    comment : str or None
        Optional comment field specifying address ending
    long: bool
        If True, format as Aptos address, otherwise Move CLI address

    Returns
    -------
    str
        A new address line with a full Aptos-compatible address

    Example
    -------
    >>> from econia.build import format_addr
    >>> format_addr('A', '1234567890abcdef' * 3, None, True)
    "A = '0x1234567890abcdef1234567890abcdef1234567890abcdef'"
    >>> format_addr('B', '4321abcd' * 4, '7890' , True)
    "B = '0x4321abcd4321abcd4321abcd4321abcd7890'"
    >>> format_addr('C', '1234abcd' * 5, None, False)
    "C = '0x1234abcd1234abcd1234abcd1234abcd' # 1234abcd"
    >>> format_addr('D', '87654321' * 4, 'abcd' , False)
    "D = '0x87654321876543218765432187654321' # abcd"
    >>> # Preserves leading zeroes in comment but not at start
    >>> format_addr('E', '00123456' * 4, '00123456' , True)
    "E = '0x12345600123456001234560012345600123456'"
    """
    addr = get_addr_bytes(addr)
    if comment is not None:
        comment = get_addr_bytes(comment)
    if long:
        if comment is not None: # Merge comment into address
            addr = addr + comment
            comment = None
        assert len(addr) <= max_address_length.aptos
    else:
        if comment is None: # Split up
            if len(addr) > max_address_length.move_cli:
                comment = addr[max_address_length.move_cli:]
                addr = addr[0:max_address_length.move_cli]
        assert len(addr) <= max_address_length.move_cli
    line = f'{name}' +  seps.sp + seps.eq + seps.sp + seps.sq + \
        hex_leader(normalized_hex(addr)) + seps.sq
    if comment is not None:
        line = line + seps.sp + seps.pnd + seps.sp + comment.hex()
    return line

def format_addrs(
    lines: list[str],
    long: bool
) -> None:
    """Format addresses in the lines of a Toml file

    Parameters
    ----------
    lines : list of str
        Per :func:`~build.get_toml_lines`
    long : bool
        True if addresses should be formatted in long version
    """
    in_addrs = False
    for i, line in enumerate(lines):
        if in_addrs:
            if not line: # Blank line
                break
            lines[i] = format_addr(*get_addr_elems(line), long)
        if is_address_line(line):
            in_addrs = True

def prep_toml(
    econia_root: str = seps.dot,
    long: bool = True,
) -> None:
    """Prepare Move.toml file with either long/short address variants

    The Move CLI only accepts shorter addresses, while Aptos addresses
    are longer. Hence, when building, it may be necessary to transition
    between both forms for local testing and blockchain deployment

    Parameters
    ----------
    econia_root : str, optional
        Relative path to Econia repository root directory
    long: bool, optional
        If True, format as Aptos addresses, otherwise Move CLI addresses
    """
    toml_path = get_toml_path(econia_root)
    lines = get_toml_lines(toml_path)
    format_addrs(lines, long)
    Path(toml_path).write_text(seps.nl.join(lines))

def get_bytecode_files(
    econia_root: str = seps.dot
) -> dict[str, str]:
    """Return dict from module name to module bytecode string

    Parameters
    ----------
    econia_root : str, optional
        Relative path to econia repository root directory

    Returns
    -------
    dict from str to str
        Map from module name to bytecode hexstring
    """
    abs_path = os.path.join(
        os.path.abspath(econia_root),
        ps.move_package_root,
        ps.bytecode_dir
    ) # Get bytecode directory path
    bcs = {} # Init dict of bytecode files
    for path in Path(abs_path).iterdir(): # Loop over sub-paths
        if path.is_file(): # If sub-path is a file
            bcs[path.stem] = path.read_bytes().hex() # Add to dict
    return bcs

def print_bc_diagnostics(
    client: Client,
    signer: Account,
    leader: str,
    bc: Union[list[str], str],
    serialized: bool
) -> None:
    """Print bytecode publication diagnostic message

    Parameters
    ----------
    client : econia.rest.Client
        An instantiated REST client
    signer : econia.account.Account
        Signing account
    leader : str
        First token to print
    bc : list of str or str
        List of bytecode modules to publish, or a single bytecode module
    serialized : bool
        If True, publish all modules in serial
    """
    tx_hash = None
    if serialized:
        try:
            tx_hash = client.publish_module(signer, bc) # bc is str
        except AssertionError as e:
            print(e_msgs.tx_submission + seps.cln, e)
    else:
        try:
            tx_hash = client.publish_modules(signer, bc) # bc is list of str
        except AssertionError as e:
            print(e_msgs.tx_submission + seps.cln, e)
    if tx_hash is not None: # If tx actually published
        status = tx_fields.success
        if not client.tx_successful(tx_hash):
            status = e_msgs.failed
        print(
            leader + seps.cln,
            status,
            seps.lp + client.tx_vn_url(tx_hash) + seps.rp
        )

def publish_bytecode(
    s: Account,
    econia_root: str = seps.dot,
    serialized: bool = False
) -> str:
    """Publish bytecode modules with diagnostic printouts

    Assumes devnet

    Parameters
    ----------
    s : econia.account.Account
        Signing account
    econia_root : str, optional
        Relative path to econia repository root directory
    serialized : bool, optional
        If True, publish all modules in separate transactions. If False,
        batch as specified at :data:`~defs.econia_module_publish_order`

    Returns
    -------
    str
        Transaction hash of module upload transaction
    """
    c = Client(networks.devnet)
    bc_map = get_bytecode_files(econia_root)
    # Only load modules specified for publication
    loadable_modules = [module for batch in e_m_p_o for module in batch]
    if serialized: # Loop over modules
        to_load = {module: bc_map[module] for module in loadable_modules}
        for m in to_load.keys():
            print_bc_diagnostics(c, s, m, to_load[m], serialized=True)
    else: # Publish modules in batches
        for batch in e_m_p_o:
            first = True # First module in batch
            leader = '' # Initialize diagnostic printout message
            to_load = [] # List of bytecode hexstrings to load
            for module in batch:
                if first:
                    leader = leader + module
                    first = False
                else:
                    leader = leader + seps.cma + seps.sp + module
                to_load.append(bc_map[module])
            print_bc_diagnostics(c, s, leader, to_load, serialized=False)

def sub_middle_group_file(
    abs_path: str,
    pattern: str,
    sub: str
) -> str:
    """Loop over lines in a file and replace middle RegEx group at match

    Parameters
    ----------
    abs_path : str
        Absolute path of file
    pattern : str
        RegEx pattern
    sub : str
        Value to substitute for middle RegEx group

    Returns
    -------
    str
        The value that was replaced
    """
    lines = Path(abs_path).read_text().splitlines()
    for i, line in enumerate(lines):
        m = re.search(pattern, line)
        if m: # If RegEx matched, substitute middle value
            lines[i] = m.group(r_i.start) + sub + m.group(r_i.end)
            old = m.group(r_i.middle)
            break
    Path(abs_path).write_text(seps.nl.join(lines))
    return old

def get_secrets_dir(
    econia_root: str
) -> str:
    """Return absolute path of `econia/.secrets`

    Parameters
    ----------
    econia_root : str, optional
        Relative path to Econia repository root directory

    Returns
    -------
    str
        Absolute path of `econia/.secrets`
    """
    return os.path.join(os.path.abspath(econia_root), util_paths.secrets_dir)

def get_key_path(
    address = str,
    econia_root: str = seps.dot
) -> str:
    """Return absolute path keyfile at `econia/.secrets/<address>.key`

    Parameters
    ----------
    address : str
        Account address
    econia_root : str, optional
        Relative path to Econia repository root directory

    Returns
    -------
    str
        Absolute path of keyfile
    """
    return os.path.join(
        get_secrets_dir(econia_root),
        address + seps.dot + file_extensions.key
    )

def sub_address_in_build_files(
    address = str,
    econia_root: str = seps.dot
) -> str:
    """Substitute new address into relevant build files

    Parameters
    ----------
    address : str
        Account address without leading hex specifier
    econia_root : str, optional
        Relative path to econia repository root directory

    Returns
    -------
    str
        Previous build address
    """
    check = None
    for path, pattern in [
        (
            get_toml_path(econia_root),
            r'(' + Econia + r'.+' + seps.hex + r')(\w+)(' + seps.sq + r')',
        ),
        (
            get_sh_path(econia_root),
            r'(.+' + util_paths.secrets_dir + seps.sls + r')(\w+)(.+)'
        )
    ]:
        old_address = sub_middle_group_file(path, pattern, address)
        if check is None:
            check = old_address
        else:
            assert old_address == check
    return old_address

def archive_keyfile(
    abs_path: str
) -> None:
    """Move keyfile with given address into `.secrets/old`

    Parameters
    ----------
    abs_path : str
        Absolute path of keyfile to archive
    """
    try:
        Path(abs_path).replace(os.path.join(
            os.path.dirname(abs_path),
            util_paths.old_keys,
            os.path.basename(abs_path)
        ))
    except FileNotFoundError: # Keyfile likely already deleted manually
        pass

def archive_keyfiles(
    s_path: str
) -> None:
    """Archive all keyfiles from `.secrets` into `.secrets/old`

    Parameters
    ----------
    abs_path:
        Absolute path to `.secrets` directory
    """
    for i in os.listdir(s_path): # Loop over directory contents
        if os.path.isfile(Path(s_path) / i): # Move only if is file
            shutil.move(Path(s_path) / i, Path(s_path) / util_paths.old_keys)

def sub_named_toml_address(
    econia_root: str = seps.dot,
    generic: bool = True,
    named: str = hex_leader(named_addrs.Econia),
) -> str:
    """Substitute the named Econia address in Move.toml file

    Parameters
    ----------
    econia_root : str, optional
        Relative path to econia repository root directory
    generic : bool, optional
        If a generic named address should be substututed, e.g. '_'
    named : str, optional
        The named address string to substitute back inside single quotes

    Returns
    -------
    str
        Old value enclosed in single quotes
    """
    pattern = r'(' + Econia + r'.+' + seps.sq + r')(\w+)(' + seps.sq + r')$'
    if generic:
        to_sub = seps.us
    else:
        to_sub = named
    return sub_middle_group_file(get_toml_path(econia_root), pattern, to_sub)

def gen_new_econia_dev_account(
    econia_root: str = seps.dot
) -> None:
    """Generate new Econia account, fund from faucet, update build files

    Parameters
    ----------
    econia_root : str, optional
        Relative path to econia repository root directory
    """
    account = Account()
    address = account.address()
    mint_val = tx_defaults.faucet_mint_val
    try:
        Client(networks.devnet).mint_testcoin(address, mint_val)
    except Exception:
        print(e_msgs.faucet)
        return
    # Strip off potential leading 0 for recording on disk
    address = normalized_hex(get_addr_bytes(account.address()))
    print(build_print_outputs.account_msg, address)
    archive_keyfiles(get_secrets_dir(econia_root))
    account.save_seed_to_disk(get_key_path(address, econia_root))
    sub_named_toml_address(econia_root)

if __name__ == '__main__':
    """See module docstring for examples"""

    # Aliases
    publish = build_command_fields.publish
    serial = build_command_fields.serial
    action = sys.argv[1]

    if action == publish: # Publish compiled bytecode
        keyfile = sys.argv[2]
        econia_root = seps.dot
        serialized = False
        if len(sys.argv) >= 4:
            econia_root = sys.argv[3]
            serialized = ((len(sys.argv) == 5) and (sys.argv[4] == serial))
        account = Account(path=keyfile)
        publish_bytecode(account, econia_root, serialized)
        sub_named_toml_address(econia_root, generic=False)
    elif action == build_command_fields.gen: # Generate new dev account
        econia_root = seps.dot
        if len (sys.argv) == 3:
            econia_root = sys.argv[2]
        gen_new_econia_dev_account(econia_root)

    # (Deprecated)  Prepare Move.Toml file
    elif action == build_command_fields.prep:
        long = sys.argv[2] == build_command_fields.long
        econia_root = sys.argv[3]
        prep_toml(econia_root, long)