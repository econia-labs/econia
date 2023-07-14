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

# mainnet: 0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c
# testnet: 0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135
# devnet: 0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74
ECONIA_ADDR = AccountAddress.from_hex("0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74")
FAUCET_ADDR = AccountAddress.from_hex("0x260d1327643a17897a8f28ac7279f93b49bef390fb70007b6a7d4456a6a32f29")
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

    market_id = setup_market(faucet_client, viewer)
    print(f"Market ID: {market_id}")

    account_A = setup_new_account(faucet_client, market_id)
    print(f"Account A was set-up: {account_A.account_address}")
    # Bid to purchase 1 whole ETH at a price of 1 whole USDC per lot!
    # = $1000/ETH since there are 1000 lots in a whole ETH & 1 tick = 0.001 USDC
    buy_base_lots = 1 * (10**3)
    buy_ticks_per_lot = 1 * (10**3)
    place_limit_order(Side.BID, account_A, market_id, buy_base_lots, buy_ticks_per_lot)
    # Ask to sell 1 whole ETH at a price of 2 whole USDC per lot!
    # = $2000/ETH since there are 1000 lots in a whole ETH & 1 tick = 0.001 USDC
    sell_base_lots = 1 * (10**3)
    sell_ticks_per_lot = 2 * (10**3)
    place_limit_order(Side.ASK, account_A, market_id, sell_base_lots, sell_ticks_per_lot)
    print(f"Account A has finished making!")
    report_best_price_levels(viewer, market_id)

    account_B = setup_new_account(faucet_client, market_id)
    print(f"Account B was set-up: {account_B.account_address}")
    place_market_order(Side.BID, account_B, market_id, 500) # Buy 0.5 ETH
    place_market_order(Side.ASK, account_B, market_id, 500) # Sell 0.5 ETH
    print(f"Account B has finished taking!")

    report_best_price_levels(viewer, market_id)

def place_market_order(
    direction: Side,
    account: Account,
    market_id: int,
    size_lots_of_base: int,
):
    calldata = place_market_order_user_entry(
        ECONIA_ADDR,
        TypeTag(StructTag.from_str(COIN_TYPE_ETH)),
        TypeTag(StructTag.from_str(COIN_TYPE_USDC)),
        market_id,
        AccountAddress.from_hex("0x0"),
        direction,
        size_lots_of_base,
        SelfMatchBehavior.CancelMaker
    )
    EconiaClient(NODE_URL, ECONIA_ADDR, account).submit_tx_wait(calldata)

def place_limit_order(
    direction: Side,
    account: Account,
    market_id: int,
    size_lots_of_base: int,
    price_ticks_per_lot: int
):
    calldata = place_limit_order_user_entry(
        ECONIA_ADDR,
        TypeTag(StructTag.from_str(COIN_TYPE_ETH)),
        TypeTag(StructTag.from_str(COIN_TYPE_USDC)),
        market_id,
        AccountAddress.from_hex("0x0"),
        direction,
        size_lots_of_base,
        price_ticks_per_lot,
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

def setup_market(faucet_client: FaucetClient, viewer: EconiaViewer) -> int:
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
        account_XCH = Account.generate()
        faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
        faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
        faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
        faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
        faucet_client.fund_account(account_XCH.address(), 1 * (10**8))
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
    return market_id

def report_best_price_levels(viewer: EconiaViewer, market_id: int):
    price_levels = get_price_levels(viewer, market_id)

    best_bid_level = price_levels["bids"][0]
    best_bid_level_price = best_bid_level["price"] # in ticks
    best_bid_level_volume = best_bid_level["size"] # in lots
    print(f"There are {best_bid_level_volume} lots (of ETH) being BOUGHT for a price of {best_bid_level_price} ticks (of USDC) per lot")

    best_ask_level = price_levels["asks"][0]
    best_ask_level_price = best_ask_level["price"] # in ticks
    best_ask_level_volume = best_ask_level["size"] # in lots
    print(f"There are {best_ask_level_volume} lots (of ETH) being SOLD for a price of {best_ask_level_price} ticks (of USDC) per lot")
    
