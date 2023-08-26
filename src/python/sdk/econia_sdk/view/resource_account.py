from aptos_sdk.account_address import AccountAddress

from econia_sdk.lib import EconiaViewer


def get_address(view: EconiaViewer) -> AccountAddress:
    """
    Return resource account address.
    """
    returns = view.get_returns("resource_account", "get_address")
    return AccountAddress.from_hex(returns[0])
