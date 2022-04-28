"""Move package building functionality"""

import os
import re

from pathlib import Path
from ultima.account import hex_leader
from ultima.defs import (
    file_extensions,
    max_address_length,
    seps,
    toml_section_names,
    ultima_paths as ps
)

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
    abs_path = os.path.join(
        os.path.abspath(ultima_root),
        ps.move_package_root,
        ps.toml_path + seps.dot + file_extensions.toml
    )
    assert os.path.isfile(abs_path), abs_path
    return abs_path

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
    match = re.search(r'(?<=#\s)\w+', line)
    if match:
        comment = match.group(0)
    return (
        re.search(r'^\w+', line).group(0),
        re.search(r'(?<=0x)\w+', line).group(0),
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
    line = f'{name}' +  seps.sp + seps.equal + seps.sp + seps.s_q + \
        hex_leader(normalized_hex(addr)) + seps.s_q
    if comment is not None:
        line = line + seps.sp + seps.pound + seps.sp + normalized_hex(comment)
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
    long: bool
        If True, format as Aptos addresses, otherwise Move CLI addresses
    """
    toml_path = get_toml_path(ultima_root)
    lines = get_toml_lines(toml_path)
    format_addrs(lines, long)
    Path(toml_path).write_text(seps.nl.join(lines))

