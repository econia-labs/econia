"""Aptos network connection functionality"""

from types import SimpleNamespace

connect_url = SimpleNamespace(
    devnet = 'https://fullnode.devnet.aptoslabs.com',
    devnet_faucet = 'https://faucet.devnet.aptoslabs.com'
)
"""URLs for connecting to various Aptos network elements"""