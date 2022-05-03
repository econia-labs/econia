"""Move package building functionality

Relies on a ``.secrets`` folder inside Ultima project root directory,
which contains a directory ``old``, hence ``ultima/.secrets/old``

Some functionality abstracted to be run from the command line:

.. code-block:: zsh
    :caption: Prepping Move.toml file

    # From within Ultima repository root
    % python src/python/ultima/build.py prep long
    % python src/python/ultima/build.py prep short
    # From elsewhere
    % cd src
    python ../src/python/ultima/build.py prep long '../'

.. code-block:: zsh
    :caption: Publishing all module bytecode

    # From Ultima repository root directory
    % python src/python/ultima/build.py publish .secrets/ultima.key
    Success, tx hash: 0x9322adcaacbcd499b35d16b5d24c4521f65f30da27b1efd127319d24c916820e

.. code-block:: zsh
    :caption: Generating a new dev account (when bytecode loader gets stuck)

    # From Ultima repository root directory
    % python src/python/ultima/build.py gen
    New account: 767f55126ad35ac6acaa130a2a18ba38d721fd42e5fa4bfe10885216ee307706
"""

import os
import re
import sys
import time

from pathlib import Path
from ultima.account import Account, hex_leader
from ultima.defs import (
    build_command_fields,
    e_msgs,
    file_extensions,
    max_address_length,
    networks,
    regex_trio_group_ids as r_i,
    seps,
    toml_section_names,
    tx_defaults,
    tx_fields,
    tx_timeout_granularity,
    Ultima,
    ultima_paths as ps,
    util_paths
)
from ultima.rest import Client

def get_move_util_path(
    filename: str,
    file_extension: str,
    ultima_root: str = seps.dot,
) -> str:
    """Return absolute path of file in Move package directory

    Parameters
    ----------
    filename : str
        The file name, without extension
    file_extension : str
        File extension
    ultima_root : str, optional
        Relative path to Ultima repository root directory

    Returns
    -------
    str
        Absolute path to given file
    """
    abs_path = os.path.join(
        os.path.abspath(ultima_root),
        ps.move_package_root,
        filename + seps.dot + file_extension
    )
    assert os.path.isfile(abs_path), abs_path
    return abs_path

def get_toml_path(
    ultima_root: str = seps.dot
) -> str:
    """Return absolute path of Move.toml file

    Parameters
    ----------
    ultima_root : str, optional
        Relative path to Ultima repository root directory

    Returns
    -------
    str
        Absolute path to Move.toml file
    """
    return get_move_util_path(ps.toml_path, file_extensions.toml, ultima_root)

def get_sh_path(
    ultima_root: str = seps.dot
) -> str:
    """Return absolute path of Move package .sh file

    Parameters
    ----------
    ultima_root : str, optional
        Relative path to Ultima repository root directory

    Returns
    -------
    str
        Absolute path to ss.sh file
    """
    return get_move_util_path(ps.ss_path, file_extensions.sh, ultima_root)

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
    >>> from ultima.build import get_addr_elems
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
    >>> from ultima.build import get_addr_bytes
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
    >>> from ultima.build import normalized_hex
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
    >>> from ultima.build import format_addr
    >>> format_addr('A', '1234567890abcdef' * 3, None, True)
    "A = '0x1234567890abcdef1234567890abcdef1234567890abcdef'"
    >>> format_addr('B', '4321abcd' * 4, '7890' , True)
    "B = '0x4321abcd4321abcd4321abcd4321abcd7890'"
    >>> format_addr('C', '1234abcd' * 5, None, False)
    "C = '0x1234abcd1234abcd1234abcd1234abcd' # 1234abcd"
    >>> format_addr('D', '87654321' * 4, 'abcd' , False)
    "D = '0x87654321876543218765432187654321' # abcd"
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
        line = line + seps.sp + seps.pnd + seps.sp + normalized_hex(comment)
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
    ultima_root: str = seps.dot,
    long: bool = True,
) -> None:
    """Prepare Move.toml file with either long/short address variants

    The Move CLI only accepts shorter addresses, while Aptos addresses
    are longer. Hence, when building, it may be necessary to transition
    between both forms for local testing and blockchain deployment

    Parameters
    ----------
    ultima_root : str, optional
        Relative path to Ultima repository root directory
    long: bool, optional
        If True, format as Aptos addresses, otherwise Move CLI addresses
    """
    toml_path = get_toml_path(ultima_root)
    lines = get_toml_lines(toml_path)
    format_addrs(lines, long)
    Path(toml_path).write_text(seps.nl.join(lines))

def get_bytecode_files(
    ultima_root: str = seps.dot
) -> dict[str: str]:
    """Return list of module bytecode strings

    Parameters
    ----------
    ultima_root : str, optional
        relative path to ultima repository root directory

    Returns
    -------
    dict from str to str
        Map from module name to bytecode hexstring
    """
    abs_path = os.path.join(
        os.path.abspath(ultima_root),
        ps.move_package_root,
        ps.bytecode_dir
    )
    bcs = {}
    for path in Path(abs_path).iterdir():
        bcs[path.stem] = path.read_bytes().hex()
    return bcs

def publish_bytecode(
    signer: Account,
    ultima_root: str = seps.dot
) -> str:
    """Publish bytecode modules with diagnostic printouts

    Assumes devnet

    Parameters
    ----------
    signer : ultima.account.Account
        Signing account
    ultima_root : str, optional
        relative path to ultima repository root directory

    Returns
    -------
    str
        Transaction hash of module upload transaction
    """
    client = Client(networks.devnet)
    bcs = get_bytecode_files(ultima_root)
    modules = bcs.keys()
    for module in modules:
        tx_hash = client.publish_module(signer, bcs[module])
        time.sleep(tx_timeout_granularity)
        status = tx_fields.success
        if not client.tx_successful(tx_hash):
            status = e_msgs.failed
        print(f'{module}: {status} ({client.tx_vn_url(tx_hash)})')

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
    ultima_root: str
) -> str:
    """Return absolute path of `ultima/.secrets`

    Parameters
    ----------
    ultima_root : str, optional
        relative path to Ultima repository root directory

    Returns
    -------
    str
        Absolute path of `ultima/.secrets`
    """
    return os.path.join(os.path.abspath(ultima_root), util_paths.secrets_dir)

def get_key_path(
    address = str,
    ultima_root: str = seps.dot
) -> str:
    """Return absolute path keyfile at `ultima/.secrets/<address>.key`

    Parameters
    ----------
    address : str
        Account address
    ultima_root : str, optional
        relative path to Ultima repository root directory

    Returns
    -------
    str
        Absolute path of keyfile
    """
    return os.path.join(
        get_secrets_dir(ultima_root),
        address + seps.dot + file_extensions.key
    )

def sub_address_in_build_files(
    address = str,
    ultima_root: str = seps.dot
) -> str:
    """Substitute new address into relevant build files

    Parameters
    ----------
    address : str
        Account address
    ultima_root : str, optional
        relative path to ultima repository root directory

    Returns
    -------
    str
        Previous build address
    """
    check = None
    for path, pattern in [
        (
            get_toml_path(ultima_root),
            r'(' + Ultima + r'.+' + seps.hex + r')(\w+)(' + seps.sq + r')',
        ),
        (
            get_sh_path(ultima_root),
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
    Path(abs_path).replace(os.path.join(
        os.path.dirname(abs_path),
        util_paths.old_keys,
        os.path.basename(abs_path)
    ))

def gen_new_ultima_dev_account(
    ultima_root: str = seps.dot
) -> str:
    """Generate new Ultima account, fund from faucet, update build files

    For when bytecode loader gets stuck and will not upload valid code
    without changing the Move module or Ultima named address account

    Parameters
    ----------
    ultima_root : str, optional
        relative path to ultima repository root directory

    Returns
    -------
    str
        The address of the new account
    """
    account = Account()
    address = account.address()
    account.save_seed_to_disk(get_key_path(address, ultima_root))
    Client(networks.devnet).mint_testcoin(address, tx_defaults.faucet_mint_val)
    prep_toml(ultima_root, long=True)
    old_address = sub_address_in_build_files(address, ultima_root)
    archive_keyfile(get_key_path(old_address, ultima_root))
    return(address)

if __name__ == '__main__':
    """See module docstring for examples"""
    ultima_root = seps.dot # Assume running from within Ultima root dir
    if len(sys.argv) == 4:
        ultima_root = sys.argv[3]
    action = sys.argv[1]
    if action == build_command_fields.prep: # Prepare Move.Toml file
        long = sys.argv[2] == build_command_fields.long
        prep_toml(ultima_root, long)
    if action == build_command_fields.publish: # Cargo build and publish
        keyfile = sys.argv[2]
        account = Account(path=keyfile)
        publish_bytecode(account, ultima_root)
    if action == build_command_fields.gen: # Generate new dev account
        if len (sys.argv) == 3:
            ultima_root = sys.argv[2]
        new_address = gen_new_ultima_dev_account(ultima_root)
        print(build_command_fields.account_msg, new_address)