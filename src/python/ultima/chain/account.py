"""Account management"""

import hashlib
import os

from pathlib import Path
from nacl.signing import SigningKey
from ultima.chain.defs import (
    e_msgs,
    single_sig_id,
    seps
)

class Account:
    """Representation of account and keypair

    Parameters
    ----------
    seed : bytes, optional
        32-byte random seed value
    path : str, optional
        Relative path to file containing 32-byte random seed value,
        stored as human readable hex string

    Attributes
    ----------
    signing_key : nacl.signing.SigningKey
        Account signing key

    Example
    -------
    >>> import random
    >>> import shutil
    >>> from pathlib import Path
    >>> from ultima.chain.account import Account
    >>> random.seed('Ultima')
    >>> art = Account(random.randbytes(32))
    >>> art.address()
    '8831fe5427536eca8341a3ce0258b2a1de5a31ee54e6db638a8e1ccf5aaeba86'
    >>> hex_seed = art.signing_key._seed.hex()
    >>> hex_seed
    '65fc056e6134c06208d819822eba58fa3dd56493f628ca5e7e0f671d0d1aa234'
    >>> path = 'tmp/.secrets/art.key'
    >>> art.save_seed_to_disk(path)
    >>> Path(path).read_text() == hex_seed
    True
    >>> Account(path=path).address() == art.address()
    True
    >>> shutil.rmtree(Path(path).parts[0]) # Clean up tmp dir
    """

    def __init__(
        self,
        seed: bytes = None,
        path: str = None
    ) -> None:
        if seed is None:
            if path is None:
                self.signing_key = SigningKey.generate()
            else:
                abs_path = os.path.abspath(Path(os.getcwd()) / path)
                self.signing_key = \
                    SigningKey(bytes.fromhex(Path(abs_path).read_text()))
        else:
            self.signing_key = SigningKey(seed)

    def auth_key(self) -> str:
        """Return account authentication key

        Returns
        -------
        str
            Account authentication key
        """
        hasher = hashlib.sha3_256()
        hasher.update(
            self.signing_key.verify_key.encode() + single_sig_id
        )
        return hasher.hexdigest()

    def address(self) -> str:
        """Return account address

        Returns
        -------
        str
            Account address
        """
        return self.auth_key()

    def pub_key(self) -> str:
        """Return account public key

        Returns
        -------
        str
            Account public key
        """
        return self.signing_key.verify_key.encode().hex()

    def save_seed_to_disk(self, path: str):
        """Save account seed to given path, as human readable hex string

        Do nothing if seed already saved at provided path

        Parameters
        ----------
        path : str
            Relative path to save seed at

        Raises
        ------
        ValueError
            If a different seed exists at the provided path

        Example
        -------
        >>> import shutil
        >>> from ultima.chain.account import Account
        >>> path = 'tmp/.secrets/acct.key'
        >>> # Account generation makes new random seed each time
        >>> Account().save_seed_to_disk(path)
        >>> try:
        ...     Account().save_seed_to_disk(path)
        ... except ValueError as e:
        ...     print(e)
        Different value already exists at provided path
        >>> shutil.rmtree(Path(path).parts[0]) # Clean up tmp dir
        """
        abs_path = os.path.abspath(Path(os.getcwd()) / path)
        hex_seed = self.signing_key._seed.hex()
        if os.path.exists(abs_path):
            if Path(abs_path).read_text() != hex_seed:
                raise ValueError(e_msgs.path_val_collision)
            return # Seed already exists at path
        # If path does not already exist, create directories as needed
        dirname = os.path.dirname(abs_path) # Cointaining directory
        if not os.path.exists(dirname):
            Path(dirname).mkdir(parents=True)
        Path(abs_path).write_text(hex_seed)

def hex_leader(
    addr: str
) -> str:
    """Return address with '0x' appended

    Parameters
    ----------
    addr : str
        Hex address without leading '0x'

    Returns
    -------
    str
        Address with leading '0x'

    Example
    -------
    >>> from ultima.chain.account import hex_leader
    >>> hex_leader('f00cafe')
    '0xf00cafe'
    """
    return seps.hex + f'{addr}'