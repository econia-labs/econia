from aptos_sdk.account_address import AccountAddress
from econia_sdk.lib import EconiaViewer;

def start():
    viewer = EconiaViewer(
      "https://fullnode.devnet.aptoslabs.com/v1",
      AccountAddress.from_hex(
          "0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74"
      ),
    )
    print(viewer.view_fn("market", "get_ABORT")[0])