import asyncio
from os import environ
from aptos_sdk.account import Account
from aptos_sdk.account_address import AccountAddress
from aptos_sdk.async_client import FaucetClient, RestClient
from econia_sdk.lib import EconiaClient, EconiaViewer
import sys
from os import environ
from typing import Optional, Tuple
import random

from aptos_sdk.bcs import Serializer, encoder
from aptos_sdk.transactions import EntryFunction, ModuleId
from aptos_sdk.type_tag import StructTag, TypeTag

from econia_sdk.entry.market import (
    cancel_all_orders_user,
    change_order_size_user,
    place_limit_order_user_entry,
    place_market_order_user_entry,
    register_market_base_coin_from_coinstore,
    swap_between_coinstores_entry,
)
from econia_sdk.entry.registry import set_recognized_market
from econia_sdk.entry.user import deposit_from_coinstore, register_market_account
from econia_sdk.types import Restriction, SelfMatchBehavior, Side
from econia_sdk.view.market import get_open_orders_all, get_price_levels
from econia_sdk.view.registry import (
    get_market_id_base_coin,
    get_market_registration_events,
)
from econia_sdk.view.user import (
    get_cancel_order_events,
    get_fill_events,
    get_market_account,
    get_place_limit_order_events,
)

U64_MAX = (2**64) - 1
NODE_URL_LOCAL = "http://0.0.0.0:8080/v1"
FAUCET_URL_LOCAL = "http://0.0.0.0:8081"
ECONIA_ADDR_LOCAL = "0xeeee0dd966cd4fc739f76006591239b32527edbb7c303c431f8c691bda150b40"
ECONIA_KEY_LOCAL = "0x8eeb9bd1808d99ef54758060f5067b5707be379058cfd83cd983fe7e47063a09"
FAUCET_ADDR_LOCAL = "0xffff094ef8ccfa9137adcb13a2fae2587e83c348b32c63f811cc19fcc9fc5878"
COIN_TYPE_APT = "0x1::aptos_coin::AptosCoin"


def get_econia_address() -> AccountAddress:
    addr = environ.get("ECONIA_ADDR")
    if addr == None:
        addr_in = input(
            "Enter the 0x-prefixed address of an Econia deployment (enter nothing to default to local OR re-run with ECONIA_ADDR environment variable)\n"
        ).strip()
        if addr_in == "":
            return AccountAddress.from_hex(ECONIA_ADDR_LOCAL)
        else:
            return AccountAddress.from_hex(addr_in)
    else:
        return AccountAddress.from_hex(addr)

def get_faucet_address() -> AccountAddress:
    addr = environ.get("FAUCET_ADDR")
    if addr == None:
        addr_in = input(
            "Enter the 0x-prefixed address of an Econia faucet deployment (enter nothing to default to local OR re-run with FAUCET_ADDR environment variable)\n"
        ).strip()
        if addr_in == "":
            return AccountAddress.from_hex(FAUCET_ADDR_LOCAL)
        else:
            return AccountAddress.from_hex(addr_in)
    else:
        return AccountAddress.from_hex(addr)


def get_aptos_node_url() -> str:
    url = environ.get("APTOS_NODE_URL")
    if url == None:
        url_in = input(
            "Enter the URL of an Aptos node (enter nothing to default to local OR re-run with APTOS_NODE_URL environment variable)\n"
        ).strip()
        if url_in == "":
            return NODE_URL_LOCAL
        else:
            return url_in
    else:
        return url


def get_aptos_faucet_url() -> str:
    url = environ.get("APTOS_FAUCET_URL")
    if url == None:
        url_in = input(
            "Please enter the URL of an Aptos faucet (enter nothing to default to local OR re-run with APTOS_FAUCET_URL environment variable)\n"
        ).strip()
        if url_in == "":
            return FAUCET_URL_LOCAL
        else:
            return url_in
    else:
        return url
    
NODE_URL = get_aptos_node_url()
FAUCET_URL = get_aptos_faucet_url()
ECONIA_ADDR = get_econia_address()
FAUCET_ADDR = get_faucet_address()
COIN_TYPE_EAPT = TypeTag(StructTag.from_str(f"{FAUCET_ADDR}::example_apt::ExampleAPT"))
COIN_TYPE_EUSDC = TypeTag(StructTag.from_str(f"{FAUCET_ADDR}::example_usdc::ExampleUSDC"))

LOT_SIZE = 100000 if int(sys.argv[1]) == 0 else int(sys.argv[1])  # type: ignore
TICK_SIZE = 1 if int(sys.argv[2]) == 0 else int(sys.argv[2])  # type: ignore
MIN_SIZE = 500 if int(sys.argv[3]) == 0 else int(sys.argv[3])  # type: ignore

MAKER_APT_PER_ROUND = 100

def start():
    asyncio.run(gen_start())

async def gen_start():
    rest_client = RestClient(NODE_URL)
    faucet_client = FaucetClient(FAUCET_URL, rest_client)
    viewer = EconiaViewer(NODE_URL, ECONIA_ADDR)
    econia_client = await setup_client(faucet_client, rest_client)
    market_id = get_market_id_base_coin(
        viewer,
        str(COIN_TYPE_EAPT),
        str(COIN_TYPE_EUSDC),
        LOT_SIZE,
        TICK_SIZE,
        MIN_SIZE,
    )
    if market_id is None:
        calldata = register_market_base_coin_from_coinstore(
            ECONIA_ADDR,
            COIN_TYPE_EAPT,
            COIN_TYPE_EUSDC,
            TypeTag(StructTag.from_str(COIN_TYPE_APT)),
            LOT_SIZE,
            TICK_SIZE,
            MIN_SIZE,
        )
        await econia_client.gen_submit_tx_wait(calldata)
        market_id = get_market_id_base_coin(
            viewer,
            str(COIN_TYPE_EAPT),
            str(COIN_TYPE_EUSDC),
            LOT_SIZE,
            TICK_SIZE,
            MIN_SIZE
        )
        print("Created market {}", market_id)
    else:
        print("Market existed: {}", market_id)

    if market_id is None:
        print("Failed to discover or create market")
        exit()
    n = 50
    tasks = [setup_client(faucet_client, rest_client) for _ in range(n)] # type: ignore
    clients = await asyncio.gather(*tasks)
    clients_pairs = zip(clients[:n//2], clients[n//2:])
    tasks = []
    for (a, b) in clients_pairs:
        tasks.append(setup_pair(a, b, market_id, (100 * 10**8) // LOT_SIZE, 11))
    await asyncio.gather(*tasks)
    print("THE END!")

def coin_flip():
    return random.choice([True, False]) # type: ignore

async def setup_pair(
    client_a: EconiaClient,
    client_b: EconiaClient,
    market_id: int,
    base_lots: int,
    interval: int
):
    print("Initializing pair...")
    await client_a.gen_submit_tx_wait(register_market_account(
        ECONIA_ADDR,
        COIN_TYPE_EAPT,
        COIN_TYPE_EUSDC,
        market_id,
        0,
    ))
    await client_b.gen_submit_tx_wait(register_market_account(
        ECONIA_ADDR,
        COIN_TYPE_EAPT,
        COIN_TYPE_EUSDC,
        market_id,
        0,  
    ))
    print("Registered accounts...")
    async def looper():
        while True:
            flip = coin_flip()
            client_maker = client_a if flip else client_b
            client_taker = client_b if flip else client_a
            flip = coin_flip()
            from_type = COIN_TYPE_EAPT if flip else COIN_TYPE_EUSDC
            to_type = COIN_TYPE_EUSDC if flip else COIN_TYPE_EAPT
            base_lots_remaining = base_lots
            await client_a.gen_submit_tx_wait(deposit_from_coinstore(
                ECONIA_ADDR,
                COIN_TYPE_EAPT,
                market_id,
                0,
                100 * 10**8
            ))
            await client_a.gen_submit_tx_wait(deposit_from_coinstore(
                ECONIA_ADDR,
                COIN_TYPE_EUSDC,
                market_id,
                0,
                600 * 10**6
            ))
            await client_b.gen_submit_tx_wait(deposit_from_coinstore(
                ECONIA_ADDR,
                COIN_TYPE_EAPT,
                market_id,
                0,
                100 * 10**8
            ))
            await client_b.gen_submit_tx_wait(deposit_from_coinstore(
                ECONIA_ADDR,
                COIN_TYPE_EUSDC,
                market_id,
                0,
                600 * 10**6
            ))
            print("Funded the accounts...")
            orders = 0
            base_lots_made = 0
            while base_lots_remaining > MIN_SIZE:
                base_lots_size = random.randint(MIN_SIZE, base_lots_remaining)
                ticks_per_lot = (
                    random.randint(1 * 10**3, (6 * 10**3) // 2)
                    if from_type == COIN_TYPE_EUSDC
                    else random.randint(((6 * 10**3) // 2) + 1, 6 * 10**3)
                )
                await execute_limit_order(client_maker, market_id, from_type, base_lots_size, ticks_per_lot)
                await execute_market_order(client_taker, market_id, to_type, base_lots_size)
                orders += 1
                base_lots_made += base_lots_size
                base_lots_remaining -= base_lots_size
            print(f"Created the paired orders: {orders}")
            await asyncio.sleep(interval)

    await looper()

async def setup_client(faucet: FaucetClient, rest: RestClient) -> EconiaClient:
    account = Account.generate()
    client = EconiaClient(NODE_URL, ECONIA_ADDR, account, None, rest)
    await faucet.fund_account(account.address().hex(), 10 * (10**8))
    await fund(client, client.user_account, U64_MAX, COIN_TYPE_EAPT)
    await fund(client, client.user_account, U64_MAX, COIN_TYPE_EUSDC)
    return client

async def setup_taker(client: EconiaClient, market_id: int, from_type: TypeTag, subunits: int, interval: int):
    pass

async def fund(client: EconiaClient, account: Account, subunits: int, type: TypeTag):
    await client.gen_submit_tx_wait(
        EntryFunction(
            ModuleId.from_str(f"{FAUCET_ADDR}::faucet"),  # module
            "mint",  # funcname
            [type],  # generics
            [encoder(subunits, Serializer.u64)],  # arguments
        )
    )

async def execute_market_order(client: EconiaClient, market_id: int, from_type: TypeTag, base_lots: int):
    direction = Side.BID if from_type == COIN_TYPE_EUSDC else Side.ASK
    calldata = place_market_order_user_entry(
        ECONIA_ADDR,
        COIN_TYPE_EAPT,
        COIN_TYPE_EUSDC,
        market_id,
        ECONIA_ADDR,
        direction,
        base_lots,
        SelfMatchBehavior.CancelMaker,
    )
    await client.gen_submit_tx_wait(calldata)

async def execute_limit_order(client: EconiaClient, market_id: int, from_type: TypeTag, base_lots: int, ticks_per_lot: int):
    direction = Side.BID if from_type == COIN_TYPE_EUSDC else Side.ASK
    calldata = place_limit_order_user_entry(
        ECONIA_ADDR,
        COIN_TYPE_EAPT,
        COIN_TYPE_EUSDC,
        market_id,
        ECONIA_ADDR,
        direction,
        base_lots,
        ticks_per_lot,
        Restriction.NoRestriction,
        SelfMatchBehavior.CancelMaker,
    )
    await client.gen_submit_tx_wait(calldata)