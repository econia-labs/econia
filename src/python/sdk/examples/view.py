from aptos_sdk.account_address import AccountAddress
from aptos_sdk.account import Account
from aptos_sdk.client import RestClient, FaucetClient
from aptos_sdk.transactions import EntryFunction, ModuleId
from aptos_sdk.bcs import Serializer, encoder
from aptos_sdk.type_tag import TypeTag, StructTag

from econia_sdk.lib import EconiaViewer, EconiaClient;
from econia_sdk.types import *
from econia_sdk.entry.market import *
from econia_sdk.entry.user import *
from econia_sdk.view.incentives import *
from econia_sdk.view.market import *
from econia_sdk.view.registry import *
from econia_sdk.view.resource_account import *
from econia_sdk.view.user import *


class WTF:
    strval: str
    def __init__(self, s: str):
        self.strval = s
    
    def serialize(self, serializer: Serializer):
        return serializer.str(self.strval)

ECONIA_ADDR = AccountAddress.from_hex("0xfe5cf7b1ca8a2895705771fbb9933b2fe4d30e74ee402a4213b48083759f9eec")
FAUCET_ADDR = AccountAddress.from_hex("0x4334ed72a7037abfd05bb7b846fa4535cc3d2cb31b7565939817de15551a6c03")
COIN_TYPE_ETH = f"{FAUCET_ADDR}::test_eth::TestETH"
COIN_TYPE_USDC = f"{FAUCET_ADDR}::test_usdc::TestUSDC"
COIN_TYPE_APT = "0x1::aptos_coin::AptosCoin"
NODE_URL = "https://fullnode.devnet.aptoslabs.com/v1"
FAUCET_URL = "https://faucet.devnet.aptoslabs.com"

def start():
    rest_client = RestClient(NODE_URL)
    faucet_client = FaucetClient(FAUCET_URL, rest_client)  # <:!:section_1
    viewer = EconiaViewer(NODE_URL, ECONIA_ADDR)
    print(f"Econia address (from view function): {get_address(viewer)}")

    account_XCH = Account.generate()
    # faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
    # faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
    # faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
    # faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
    # faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
    print(f"Funded main account address: {account_XCH.address()}")

    lot_size = 10**(18-3) # tETH has 18 decimals, want 1/1000th granularity
    tick_size = 10**(6-3) # tUSDC has 6 decimals, want 1/1000th granularity
    min_size = 1
    market_id = get_market_id_base_coin(
        viewer,
        COIN_TYPE_ETH,
        COIN_TYPE_USDC,
        lot_size,
        tick_size,
        min_size
    )
    if market_id == None:
        print("Market does not exist yet, creating one...")
        calldata = register_market_base_coin_from_coinstore(
            ECONIA_ADDR,
            TypeTag(StructTag.from_str(COIN_TYPE_ETH)),
            TypeTag(StructTag.from_str(COIN_TYPE_USDC)),
            TypeTag(StructTag.from_str(COIN_TYPE_APT)),
            lot_size,
            tick_size,
            min_size
        )
        EconiaClient(
            NODE_URL,
            ECONIA_ADDR,
            account_XCH
        ).submit_tx_wait(calldata)
        market_id = get_market_id_base_coin(
          viewer,
          COIN_TYPE_ETH,
          COIN_TYPE_USDC,
          lot_size,
          tick_size,
          min_size
        )
    if market_id == None: exit()
    print(f"Market ID: {market_id}")

    account_A = setup_new_account(faucet_client, market_id)
    print(f"Account A was set-up: {account_A.account_address}")
    # Bid to purchase 1 whole ETH at a price of 1 whole USDC per lot!
    # = $1000/ETH since there are 1000 lots in a whole ETH & 1 tick = 0.001 USDC
    limit_order_BID(account_A, market_id, 1 * (10**3), 1 * (10**3))
    # Ask to sell 1 whole ETH at a price of 2 whole USDC per lot!
    # = $2000/ETH since there are 1000 lots in a whole ETH & 1 tick = 0.001 USDC
    limit_order_ASK(account_A, market_id, 1 * (10**3), 2 * (10**3))

    account_B = setup_new_account(faucet_client, market_id)
    print(f"Account B was set-up: {account_B.account_address}")


def limit_order_BID(
        account: Account,
        market_id: int,
        base_lots_to_buy: int,
        quote_ticks_per_lot: int
):
    calldata = place_limit_order_user_entry(
        ECONIA_ADDR,
        TypeTag(StructTag.from_str(COIN_TYPE_ETH)),
        TypeTag(StructTag.from_str(COIN_TYPE_USDC)),
        market_id,
        AccountAddress.from_hex("0x0"),
        Side.BID,
        base_lots_to_buy,
        quote_ticks_per_lot,
        Restriction.NoRestriction,
        SelfMatchBehavior.CancelMaker,
    )
    EconiaClient(NODE_URL, ECONIA_ADDR, account).submit_tx_wait(calldata)

def limit_order_ASK(
        account: Account,
        market_id: int,
        base_lots_to_sell: int,
        quote_ticks_per_lot: int
):
    calldata = place_limit_order_user_entry(
        ECONIA_ADDR,
        TypeTag(StructTag.from_str(COIN_TYPE_ETH)),
        TypeTag(StructTag.from_str(COIN_TYPE_USDC)),
        market_id,
        AccountAddress.from_hex("0x0"),
        Side.ASK,
        base_lots_to_sell,
        quote_ticks_per_lot,
        Restriction.NoRestriction,
        SelfMatchBehavior.CancelMaker,
    )
    EconiaClient(NODE_URL, ECONIA_ADDR, account).submit_tx_wait(calldata)
    

def setup_new_account(faucet: FaucetClient, market_id: int):
    account = Account.generate()
    client_A = EconiaClient(NODE_URL, ECONIA_ADDR, account)

    # Fund with APT, "ETH" and "USDC"
    faucet.fund_account(account.address(), 1 * (10**8))
    fund_ETH(account, 10)
    fund_USDC(account, 10_000)

    # Register market account
    calldata = register_market_account(
        ECONIA_ADDR,
        TypeTag(StructTag.from_str(COIN_TYPE_ETH)),
        TypeTag(StructTag.from_str(COIN_TYPE_USDC)),
        market_id,
        0
    )
    client_A.submit_tx_wait(calldata)

    # Deposit "ETH"
    calldata = deposit_from_coinstore(
        ECONIA_ADDR,
        TypeTag(StructTag.from_str(COIN_TYPE_ETH)),
        market_id,
        0,
        5 * (10**18)
    )
    client_A.submit_tx_wait(calldata)

    # Deposit "USDC"
    calldata = deposit_from_coinstore(
        ECONIA_ADDR,
        TypeTag(StructTag.from_str(COIN_TYPE_USDC)),
        market_id,
        0,
        5_000 * (10**6)
    )
    client_A.submit_tx_wait(calldata)

    return account

# NOTE: `wholes` must be 18 or under due to u64 sizing restrictions
def fund_ETH(account: Account, wholes: int):
    calldata = EntryFunction(
        ModuleId.from_str(f"{FAUCET_ADDR}::faucet"), # module
        "mint", # funcname
        [TypeTag(StructTag.from_str(COIN_TYPE_ETH))], # generics
        [encoder(wholes * (10**18), Serializer.u64)], # arguments
    )
    return EconiaClient(
        NODE_URL,
        ECONIA_ADDR,
        account
    ).submit_tx_wait(calldata)

def fund_USDC(account: Account, wholes: int):
    calldata = EntryFunction(
        ModuleId.from_str(f"{FAUCET_ADDR}::faucet"), # module
        "mint", # funcname
        [TypeTag(StructTag.from_str(COIN_TYPE_USDC))], # generics
        [encoder(wholes * (10**6), Serializer.u64)], # arguments
    )
    return EconiaClient(
        NODE_URL,
        ECONIA_ADDR,
        account
    ).submit_tx_wait(calldata)
    
