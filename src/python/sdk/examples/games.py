import asyncio
from os import environ
from aptos_sdk.account import Account
from aptos_sdk.account_address import AccountAddress
from aptos_sdk.async_client import FaucetClient, RestClient
from econia_sdk.lib import EconiaClient, EconiaViewer
import sys
from os import environ
from typing import Any, Optional, Tuple
import random
import json

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
import httpx

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
COIN_TYPE_EUSDC = TypeTag(
    StructTag.from_str(f"{FAUCET_ADDR}::example_usdc::ExampleUSDC")
)

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
            MIN_SIZE,
        )
        print(f"Created market {market_id}")
    else:
        print(f"Market existed: {market_id}")

    input(f"Press enter to start the competition on Market ID {market_id}")

    if market_id is None:
        print("Failed to discover or create market")
        exit()
    n = 50
    tasks = [setup_client(faucet_client, rest_client) for _ in range(n)]  # type: ignore
    clients = await asyncio.gather(*tasks)
    clients_pairs = list(zip(clients[: n // 2], clients[n // 2 :]))
    initialized = False

    for i in range(10): # type: ignore
        tasks = []
        ticks_per_lot = random.randint(1 * 10**3, (6 * 10**3) - 1)
        for (a, b) in clients_pairs:
            task = asyncio.create_task(
                setup_pair(
                    a,
                    b,
                    market_id,
                    (100 * 10**8) // LOT_SIZE,
                    ticks_per_lot,
                    initialized,
                )
            )
            tasks.append(task)
        res = await asyncio.gather(*tasks, return_exceptions=True)
        initialized = True
        for result in res:
            if isinstance(result, Exception):
                print(f"ERROR: {result}")
                exit()
        print(f"Finished round #{i}")

    write_dict_to_file(volume_buffer, "./output_expect.json")
    write_dict_to_file(get_fills(market_id), "./output_events.json")
    print("THE END!")


def coin_flip():
    return random.choice([True, False])  # type: ignore


async def setup_pair(
    client_a: EconiaClient,
    client_b: EconiaClient,
    market_id: int,
    base_lots: int,
    ticks_per_lot: int,
    initialized: bool,
):
    if not initialized:
        await client_a.gen_submit_tx_wait(
            register_market_account(
                ECONIA_ADDR,
                COIN_TYPE_EAPT,
                COIN_TYPE_EUSDC,
                market_id,
                0,
            )
        )
        await client_b.gen_submit_tx_wait(
            register_market_account(
                ECONIA_ADDR,
                COIN_TYPE_EAPT,
                COIN_TYPE_EUSDC,
                market_id,
                0,
            )
        )
        print("Initialized account pair...")

    async def run():
        flip = coin_flip()
        client_maker = client_a if flip else client_b
        client_taker = client_b if flip else client_a
        flip = coin_flip()
        from_type = COIN_TYPE_EAPT if flip else COIN_TYPE_EUSDC
        to_type = COIN_TYPE_EUSDC if flip else COIN_TYPE_EAPT
        base_lots_remaining = base_lots
        await client_a.gen_submit_tx_wait(
            deposit_from_coinstore(ECONIA_ADDR, COIN_TYPE_EAPT, market_id, 0, 100 * 10**8)
        )
        await client_a.gen_submit_tx_wait(
            deposit_from_coinstore(
                ECONIA_ADDR, COIN_TYPE_EUSDC, market_id, 0, 600 * 10**6
            )
        )
        await client_b.gen_submit_tx_wait(
            deposit_from_coinstore(ECONIA_ADDR, COIN_TYPE_EAPT, market_id, 0, 100 * 10**8)
        )
        await client_b.gen_submit_tx_wait(
            deposit_from_coinstore(
                ECONIA_ADDR, COIN_TYPE_EUSDC, market_id, 0, 600 * 10**6
            )
        )

        orders = 0
        while base_lots_remaining > MIN_SIZE:
            base_lots_size = random.randint(MIN_SIZE, base_lots_remaining)
            match_price = (
                ticks_per_lot if from_type == COIN_TYPE_EUSDC else ticks_per_lot + 1
            )
            volume = base_lots_size * match_price * TICK_SIZE
            fee = volume // 2000
            volume = volume - fee
            await execute_limit_order(
                client_maker, market_id, from_type, base_lots_size, match_price
            )
            add_volume(client_maker, volume)
            await execute_market_order(client_taker, market_id, to_type, base_lots_size)
            add_volume(client_taker, volume)
            orders += 1
            base_lots_remaining -= base_lots_size

        print(f"Created the paired orders: {orders}")

    await run()
    # await asyncio.sleep(interval)


async def setup_client(faucet: FaucetClient, rest: RestClient) -> EconiaClient:
    account = Account.generate()
    client = EconiaClient(NODE_URL, ECONIA_ADDR, account, None, rest)
    await faucet.fund_account(account.address().hex(), 10 * (10**8))
    await fund(client, client.user_account, U64_MAX, COIN_TYPE_EAPT)
    await fund(client, client.user_account, U64_MAX, COIN_TYPE_EUSDC)
    return client


async def setup_taker(
    client: EconiaClient,
    market_id: int,
    from_type: TypeTag,
    subunits: int,
    interval: int,
):
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


async def execute_market_order(
    client: EconiaClient, market_id: int, from_type: TypeTag, base_lots: int
):
    direction = Side.BID if from_type == COIN_TYPE_EUSDC else Side.ASK
    integrator = ECONIA_ADDR
    calldata = place_market_order_user_entry(
        ECONIA_ADDR,
        COIN_TYPE_EAPT,
        COIN_TYPE_EUSDC,
        market_id,
        integrator,
        direction,
        base_lots,
        SelfMatchBehavior.CancelMaker,
    )
    await client.gen_submit_tx_wait(calldata)


async def execute_limit_order(
    client: EconiaClient,
    market_id: int,
    from_type: TypeTag,
    base_lots: int,
    ticks_per_lot: int,
):
    direction = Side.BID if from_type == COIN_TYPE_EUSDC else Side.ASK
    integrator = ECONIA_ADDR
    calldata = place_limit_order_user_entry(
        ECONIA_ADDR,
        COIN_TYPE_EAPT,
        COIN_TYPE_EUSDC,
        market_id,
        integrator,
        direction,
        base_lots,
        ticks_per_lot,
        Restriction.NoRestriction,
        SelfMatchBehavior.CancelMaker,
    )
    await client.gen_submit_tx_wait(calldata)


volume_buffer_integ = dict()


def add_volume_with_integrator(
    econia_client: EconiaClient, integrator_address: AccountAddress, base_lots: int
):
    global volume_buffer
    user_address = econia_client.user_account.address().hex()
    integ_address = integrator_address.hex()
    if (
        user_address in volume_buffer_integ
        and integ_address in volume_buffer_integ[user_address]
    ):
        volume_buffer_integ[user_address][integ_address] += base_lots
    elif user_address in volume_buffer_integ and integ_address:
        volume_buffer_integ[user_address][integ_address] = base_lots
    else:
        volume_buffer_integ[user_address] = {integ_address: base_lots}


volume_buffer = dict()


def add_volume(econia_client: EconiaClient, volume: int):
    global volume_buffer
    user_address = econia_client.user_account.address().hex()
    if user_address in volume_buffer:
        volume_buffer[user_address] += volume
    else:
        volume_buffer[user_address] = volume


def write_dict_to_file(data_dict, filepath):
    try:
        with open(filepath, "w", encoding="utf-8") as file:
            json.dump(data_dict, file, ensure_ascii=False, indent=4)
        print(f"Data written to {filepath}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")


def get_fills(market_id: int) -> Any:
    fills = httpx.get(f"http://localhost:3000/fill_events?market_id=eq.{market_id}").json()
    volume = {}
    for fill in fills:
        address = fill["emit_address"]
        if address in volume:
            volume[address] += fill["size"] * fill["price"] * TICK_SIZE
        else:
            volume[address] = fill["size"] * fill["price"] * TICK_SIZE
    return volume

