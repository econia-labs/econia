import math
from decimal import Decimal


def _verify_decimal_input(decimal_input: str):
    if type(decimal_input) is not str:
        raise ValueError("Decimal input should be a string")


def _verify_integer_input(integer_input: int):
    if type(integer_input) is not int:
        raise ValueError("Integer input should be an integer")


def get_lot_size_integer(smallest_decimal_unit: str, coin_decimals: int) -> int:
    """
    Given a decimal representation of the smallest possible unit and the
    whole unit's decimals (e.g. ETH has 18 decimals), return the lot size.

    Parameters:
    * `smallest_decimal_unit`: Decimal (e.g. "0.001" for one thousandth) of
      the smallest possible unit relative to a whole unit.
    * `coin_decimals`: The number of decimals one whole unit of the coin
      has (e.g. USDC has 6 decimals, ETH has 18).
    """
    _verify_decimal_input(smallest_decimal_unit)
    _verify_integer_input(coin_decimals)
    smallest_decimal = Decimal(smallest_decimal_unit)
    smallest_subunits = 10 ** (coin_decimals + math.log10(smallest_decimal))
    if smallest_subunits < 1:
        raise ValueError("Decimal unit too small to represent with 1 subunit")
    return math.ceil(smallest_subunits)


def get_tick_size_integer(smallest_decimal_unit: str, coin_decimals: int) -> int:
    """
    Given a decimal representation of the smallest possible unit and the
    whole unit's decimals (e.g. ETH has 18 decimals), return the tick size.

    Parameters:
    * `smallest_decimal_unit`: Decimal (e.g. "0.001" for one thousandth) of
      the smallest possible unit relative to a whole unit.
    * `coin_decimals`: The number of decimals one whole unit of the coin
      has (e.g. USDC has 6 decimals, ETH has 18).
    """
    return get_lot_size_integer(smallest_decimal_unit, coin_decimals)


def get_min_size_integer(
    smallest_decimal_size: str, base_coin_decimals: int, lot_size: int
) -> int:
    """
    Returns the minimum size, in number of lots, to represent the smallest
    decimal size according to the base coin's decimals and lot size.

    Parameters:
    * `smallest_decimal_size`: Decimal (e.g. "0.001" for one thousandth) of
      the smallest possible size relative to a whole unit. Note that this
      maybe different (larger) than the smallest possible unit (lot size).
      This should be of the base coin, not the quote coin!
    * `base_coin_decimals`: The number of decimals one whole unit of the
      base has (e.g. USDC has 6 decimals, ETH has 18).
    * `lot_size`: The size in subunits of one lot of base coin.
    """
    _verify_decimal_input(smallest_decimal_size)
    _verify_integer_input(base_coin_decimals)
    _verify_integer_input(lot_size)
    smallest_decimal = Decimal(smallest_decimal_size)
    smallest_subunits = (smallest_decimal * (10**base_coin_decimals)) / lot_size
    if smallest_subunits < 0:
        raise ValueError("Decimal size too small to represent with 1 lot")
    return math.ceil(smallest_subunits)


def get_min_quote_per_base_nominal(
    smallest_decimal_size_base: str,
    smallest_decimal_size_quote: str,
) -> float:
    """
    Returns the minimum units of quote that one can obtain for a unit of
    base, given the granularity of base and granularity of quote. This
    can be thought of as price granularity--how much the price must move
    by in order to move at all. If the price granularity is 10 USDC for
    example, then only prices divisible by 10 are expressible: $10/unit,
    $20/unit, $30/unit, any so on.

    Parameters:
    * `smallest_decimal_size_base`: The decimal size of one lot of base,
      as a string i.e "0.001" for one-thousandth.
    * `smallest_decimal_size_quote`: The decimal size of one tick of quote,
      as a string i.e "0.001" for one-thousandth.
    """
    _verify_decimal_input(smallest_decimal_size_base)
    _verify_decimal_input(smallest_decimal_size_quote)
    return float(
        (1 / Decimal(smallest_decimal_size_base)) * Decimal(smallest_decimal_size_quote)
    )


def get_max_quote_per_base_nominal(
    smallest_decimal_size_base: str,
    smallest_decimal_size_quote: str,
) -> float:
    """
    Returns the maximum units of quote that once can obtain for a unit of
    base, given the granularity of base and granularity of quote. This
    can be thought of as maximum price.

    Parameters:
    * `smallest_decimal_size_base`: The decimal size of one lot of base,
      as a string i.e "0.001" for one-thousandth.
    * `smallest_decimal_size_quote`: The decimal size of one tick of quote,
      as a string i.e "0.001" for one-thousandth.
    """
    _verify_decimal_input(smallest_decimal_size_base)
    _verify_decimal_input(smallest_decimal_size_quote)
    lots_per_base_unit = 1 / Decimal(smallest_decimal_size_base)
    max_ticks_per_lot = (2**32) - 1
    max_quote_per_lot = Decimal(smallest_decimal_size_quote) * max_ticks_per_lot
    return float(max_quote_per_lot * lots_per_base_unit)
