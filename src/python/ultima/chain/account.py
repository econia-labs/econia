"""Account management"""

import hashlib

from nacl.signing import SigningKey

class Account:
    """Representation of account and keypair

    Parameters
    ----------
    seed : bytes
        32-byte random seed value
    filename : str
        Filename of binary-encoded 32-byte random seed value

    Attributes
    ----------
    signing_key : nacl.signing.SigningKey
        Account signing key

    Example
    -------
    >>> import random
    >>> from ultima.chain.account import Account
    >>> random.seed('Ultima')
    >>> art = Account(random.randbytes(32))
    >>> art.address()
    '8831fe5427536eca8341a3ce0258b2a1de5a31ee54e6db638a8e1ccf5aaeba86'
    >>> art.save_seed_to_disk('art')
    >>> bud = Account(filename='art')
    >>> art.address() == bud.address()
    True

    .. testcode ::
      :HIDE:

      import os
      os.remove('art')
    """

    def __init__(
        self,
        seed: bytes = None,
        filename: str = None
    ) -> None:
        if seed is None:
            if filename is None:
                self.signing_key = SigningKey.generate()
            else:
                with open(filename, 'br') as f: # Binary read-only mode
                    self.signing_key = SigningKey(f.read())
        else:
            self.signing_key = SigningKey(seed)

    def auth_key(self) -> str:
        """Return account authentication key"""
        hasher = hashlib.sha3_256()
        hasher.update(self.signing_key.verify_key.encode() + b'\x00')
        return hasher.hexdigest()

    def address(self) -> str:
        """Return account address"""
        return self.auth_key()

    def pub_key(self) -> str:
        """Return account public key"""
        return self.signing_key.verify_key.encode().hex()

    def save_seed_to_disk(self, filename: str):
        """Save binary account seed to disk

        Parameters
        ----------
        filename : str
            filename to save seed at
        """
        with open(filename, 'bx') as f: # Binary exclusive creation mode
            f.write(self.signing_key._seed)
