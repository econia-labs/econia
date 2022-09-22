"""Move package building functionality

Relies on a ``.secrets`` folder inside Econia project root directory,
where temporary keyfiles are stored. Old temporary keyfiles are moved to
``econia/.secrets/old``. The "official" devnet keyfile is the one stored
in ``econia/.secrets/devnet``

Some functionality abstracted to be run from the command line:

.. code-block:: zsh
    :caption: Mark ``Move.toml`` to have generic Econia address
    :emphasize-lines: 5, 13

    # From inside Econia repository root directory
    # Navigate to Move package
    % cd src/move/econia
    # Run substitute command for generic address marker
    % python ../../../src/python/econia/build.py substitute _ ../../../
    # Output Move.toml contents
    % < Move.toml
    [package]
    name = 'Econia'
    ...

    [addresses]
    econia = '_'
    ...

.. code-block:: zsh
    :caption: Generate temporary new account, printing address
    :emphasize-lines: 3

    # Still inside Move package directory
    # Run generate command, printing new address
    % python ../../python/econia/build.py generate ../../../
    db5d4dfd8d4f0f801697f5124ab61ad486d13fc140778117d76641904d728ba6
    # Output corresponding keyfile contents
    % < ../../../.secrets/db5d4dfd8d4f0f801697f5124ab61ad486d13fc140778117d76641904d728ba6.key
    (hex seed)
    ...

.. code-block:: zsh
    :caption: Compile package using new named address

    # Still inside Move package directory
    # Compile address with temporary address
    % aptos move compile --named-addresses "econia=0xdb5d4dfd8d4f0f801697f5124ab61ad486d13fc140778117d76641904d728ba6"
    {
      "Result": [
        "DB5D4DFD8D4F0F801697F5124AB61AD486D13FC140778117D76641904D728BA6::capability",
        ...
        "DB5D4DFD8D4F0F801697F5124AB61AD486D13FC140778117D76641904D728BA6::user"
      ]
    }

.. code-block:: zsh
    :caption: Publish bytecode using temporary address, with optional serial flag
    :emphasize-lines: 3

    # Still inside Move package directory
    # Publish using the temporary keyfile
    % python ../../python/econia/build.py publish ../../../.secrets/db5d4dfd8d4f0f801697f5124ab61ad486d13fc140778117d76641904d728ba6.key ../../../ serial
    capability: success (https://aptos-explorer.netlify.app/txn/6788537)
    ...
    init: success (https://aptos-explorer.netlify.app/txn/6788747)
    0xEconia::init::init_econia: success (https://aptos-explorer.netlify.app/txn/6788771)

.. code-block:: zsh
    :caption: Substitute docgen address into ``Move.toml``
    :emphasize-lines: 3, 10

    # Still inside Move package directory
    # Substitute docgen address into Move.toml
    % python ../../../src/python/econia/build.py substitute docgen ../../../
    # Output Move.toml contents
    % < Move.toml
    [package]
    name = 'Econia'
    ...
    [addresses]
    econia = '0xc0deb00c'
    ...

.. code-block:: zsh
    :caption: Print full address generated from official devnet keyfile
    :emphasize-lines: 2

    # Still inside Move package directory
    # Print keyfile address from relative file path
    % python ../../../src/python/econia/build.py print-keyfile-address ../../../.secrets/devnet/c0deb00c.key
    c0deb00c9154b6b64db01eeb77d08255300315e1fa35b687d384a703f6034fbd

.. code-block:: zsh
    :caption: Substitute the address into ``Move.toml``
    :emphasize-lines: 3, 10

    # Still inside Move package directory
    # Substitute the official devnet address into Move.toml
    % python ../../../src/python/econia/build.py substitute c0deb00c9154b6b64db01eeb77d08255300315e1fa35b687d384a703f6034fbd ../../../
    # Output Move.toml contents
    % < Move.toml
    [package]
    name = 'Econia'
    ...
    [addresses]
    econia = '0xc0deb00c9154b6b64db01eeb77d08255300315e1fa35b687d384a703f6034fbd'
    ...

.. code-block:: zsh
    :caption: Substitute new ``rev`` hash in ``Move.toml``
    :emphasize-lines: 3, 11, 13, 21

    # Still inside Move package directory
    # Substitute a new revision hash into Move.toml
    % python ../../../src/python/econia/build.py rev abcdef ../../../
    # Output Move.toml contents
    % < Move.toml
    [package]
    name = 'Econia'
    ...
    [dependencies.AptosFramework]
    ...
    rev = 'abcdef'
    # Switch to a different mock hash
    % python ../../../src/python/econia/build.py rev 123456 ../../../
    # Output Move.toml contents
    % < Move.toml
    [package]
    name = 'Econia'
    ...
    [dependencies.AptosFramework]
    ...
    rev = '123456'
"""

import os
import re
import shutil
import sys

from pathlib import Path
from econia.account import Account, hex_leader
from econia.defs import (
    build_command_fields,
    econia_paths as ps,
    Econia,
    file_extensions,
    named_addrs,
    regex_trio_group_ids as r_i,
    seps,
    util_paths
)

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
    named: str = hex_leader(named_addrs.econia.docgen),
) -> str:
    """Substitute the named Econia address in Move.toml file

    Parameters
    ----------
    econia_root : str, optional
        Relative path to econia repository root directory
    generic : bool, optional
        If a generic named address should be substituted, e.g. '_'
    named : str, optional
        The named address string to substitute back inside single quotes

    Returns
    -------
    str
        Old value enclosed in single quotes
    """
    pattern = r'(' + named_addrs.econia.address_name + r'.+' + seps.sq + \
        r')(\w+)(' + seps.sq + r')$'
    if generic:
        to_sub = seps.us
    else:
        to_sub = named
    return sub_middle_group_file(get_toml_path(econia_root), pattern, to_sub)

def gen_new_econia_dev_account(
    econia_root: str = seps.dot
) -> None:
    """Generate new Econia account, save keyfile to secrets directory

    Parameters
    ----------
    econia_root : str, optional
        Relative path to econia repository root directory
    """
    account = Account() # Generate new account
    # Archive old temp keyfiles in secrets directory
    archive_keyfiles(get_secrets_dir(econia_root))
    # Strip off potential leading 0 from filename for keyfile
    address = normalized_hex(get_addr_bytes(account.address()))
    print(address) # Print address
    # Save keyfile to disk
    account.save_seed_to_disk(get_key_path(address, econia_root))

def sub_rev_hash(
    new_hash = str,
    econia_root: str = seps.dot
):
    """Substitute new hash into sole dependency rev field for Move.toml

    Parameters
    ----------
    new_hash : str
        New commit hash to use
    econia_root : str, optional
        Relative path to econia repository root directory
    """
    # Define RegEx pattern for substituting new hash to middle group
    pattern = r'(' + build_command_fields.rev + r'.+' + seps.sq + \
        r')(\w+)(' + seps.sq + r')' # (rev.+')(\w+)(')
    # Substitute new hash into middle group from RegEx search match
    sub_middle_group_file(get_toml_path(econia_root), pattern, new_hash)

if __name__ == '__main__':
    """See module docstring for examples"""

    # Aliases
    docgen = build_command_fields.docgen
    generate = build_command_fields.generate
    print_keyfile_address = build_command_fields.print_keyfile_address
    rev = build_command_fields.rev
    substitute = build_command_fields.substitute
    action = sys.argv[1]

    if action == generate: # Generate new dev account
        econia_root = seps.dot # Assume in Econia root
        if len (sys.argv) == 3: # If argument passed after action
            # Save it as relative path to Econia project root directory
            econia_root = sys.argv[2]
        gen_new_econia_dev_account(econia_root)
    elif action == print_keyfile_address: # If want keyfile address
        # Print address derived from hex seed in keyfile at relative
        # path
        print(Account(path=sys.argv[2]).address())
    elif action == rev: # Substitute given hash into Move.toml rev
        econia_root = seps.dot # Assume in Econia repo root
        # First argument after build command is new hash
        new_hash = sys.argv[2]
        if len(sys.argv) == 4: # If given one optional argument
            # It is relative path to Econia project root directory
            econia_root = sys.argv[3]
        # Substitute the given hash into Move.toml
        sub_rev_hash(new_hash, econia_root)
    elif action == substitute: # Substitute Move.toml named address
        econia_root = seps.dot # Assume in Econia repo root
        if len(sys.argv) >= 3: # If given one optional argument
            address = sys.argv[2] # It is the address to substitute
            if len(sys.argv) == 4: # If given second optional argument
                # It is relative path to Econia project root directory
                econia_root = sys.argv[3]
            if address == seps.us: # If flagged for generic address
                sub_named_toml_address(econia_root) # Substitute it
            elif address == docgen: # If flagged for docgen address
                # Sub docgen address
                sub_named_toml_address(econia_root, generic=False)
            else: # If actually given an address
                # Substitute it into Move.toml
                sub_named_toml_address(econia_root, generic=False,
                    named=hex_leader(normalized_hex(get_addr_bytes(address))))