"""Account interface functionality"""

from nacl.signing import SigningKey
from ultima.chain.connect import connect_url

class Account:
    """Represents account and keypair on Aptos blockchain"""

    def __init__(self, seed: bytes = None) -> None:
        if seed is None:
            self.signing_key = SigningKey.generate()
        else:
            self.signing_key = SigningKey(seed)