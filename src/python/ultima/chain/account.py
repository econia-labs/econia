"""Account interface functionality"""

import hashlib

from nacl.signing import SigningKey

class Account:
    """Represents account and keypair for Aptos blockchain

    Attributes
    ----------
    signing_key : nacl.signing.SigningKey
        Account signing key
    """

    def __init__(self, seed: bytes = None) -> None:
        if seed is None:
            self.signing_key = SigningKey.generate()
        else:
            self.signing_key = SigningKey(seed)

    def auth_key(self) -> str:
        """Returns account auth_key"""
        hasher = hashlib.sha3_256()
        hasher.update(self.signing_key.verify_key.encode() + b'\x00')
        return hasher.hexdigest()

    def address(self) -> str:
        """Returns account address"""
        return self.auth_key()

    def pub_key(self) -> str:
        """Returns account public key"""
        return self.signing_key.verify_key.encode().hex()