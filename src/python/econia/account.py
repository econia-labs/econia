"""Account management"""

import hashlib
import os

from pathlib import Path
from nacl.signing import SigningKey
from econia.defs import (
    e_msgs,
    file_extensions as exts,
    single_sig_id,
    seps,
    util_paths
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
    dev_nb : bool, optional
        If True, initialize using key generated per
        :func:`build.gen_new_econia_dev_account`, assuming there is only
        one such key in the provided directory

    Attributes
    ----------
    signing_key : nacl.signing.SigningKey
        Account signing key

    Example
    -------
    >>> import random
    >>> import shutil
    >>> from pathlib import Path
    >>> from econia.account import Account
    >>> random.seed('Econia')
    >>> art = Account(random.randbytes(32))
    >>> art.address()
    '9f06af40c6bf3d33946488dd3e7c2ae2a516693317307134ac52cbfc930cc9f0'
    >>> hex_seed = art.signing_key._seed.hex()
    >>> hex_seed
    '512bb4996ea58e29f71bb07cd2353b3ce0d9556023859f1fd440770553e28a21'
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
        path: str = None,
        dev_nb: bool = False,
    ) -> None:
        if seed is None:
            if dev_nb:
                # Assume only one keyfile in `econia/.secrets`
                rrj = util_paths.econia_root_rel_jupyter
                secrets = util_paths.secrets_dir
                s_dir = os.path.join(os.path.abspath(rrj), secrets)
                keyfile_name = \
                    [p for p in os.listdir(s_dir) if p.endswith(exts.key)][0]
                abs_path = Path(s_dir) / keyfile_name
            elif path is None:
                self.signing_key = SigningKey.generate()
                return
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
            Account address, which may include leading 0
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
        >>> from econia.account import Account
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
    >>> from econia.account import hex_leader
    >>> hex_leader('f00cafe')
    '0xf00cafe'
    """
    return seps.hex + f'{addr}'