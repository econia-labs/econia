import math
from decimal import Decimal

def get_lot_size_integer(smallest_decimal_unit: str, coin_decimals: int) -> int:
    """
    Given a decimal representation of the smallest possible unit and the
    whole unit's decimals (e.g. ETH has 18 decimals), return the lot size.

    Parameters:
    * `smallest_decimal_unit`: Decimal (e.g. 0.001 for one thousandth) of
      the smallest possible unit relative to a whole unit.
    * `coin_decimals`: The number of decimals one whole unit of the coin
      has (e.g. USDC has 6 decimals, ETH has 18).
    """
    smallest_decimal = Decimal(smallest_decimal_unit)
    smallest_subunits = 10**(coin_decimals+math.log10(smallest_decimal))
    if smallest_subunits < 1:
        raise ValueError("Decimal unit too small to represent with 1 subunit")
    return math.ceil(smallest_subunits)

def get_tick_size_integer(smallest_decimal_unit: str, coin_decimals: int) -> int:
    """
    Given a decimal representation of the smallest possible unit and the
    whole unit's decimals (e.g. ETH has 18 decimals), return the tick size.

    Parameters:
    * `smallest_decimal_unit`: Decimal (e.g. 0.001 for one thousandth) of
      the smallest possible unit relative to a whole unit.
    * `coin_decimals`: The number of decimals one whole unit of the coin
      has (e.g. USDC has 6 decimals, ETH has 18).
    """
    return get_lot_size_integer(smallest_decimal_unit, coin_decimals)

def get_min_size_integer(
    smallest_decimal_size: str,
    base_coin_decimals: int,
    lot_size: int
) -> int:
    """
    Returns the minimum size, in number of lots, to represent the smallest
    decimal size according to the base coin's decimals and lot size.

    Parameters:
    * `smallest_decimal_size`: Decimal (e.g. 0.001 for one thousandth) of
      the smallest possible size relative to a whole unit. Note that this
      maybe different (larger) than the smallest possible unit (lot size).
      This should be of the base coin, not the quote coin!
    * `base_coin_decimals`: The number of decimals one whole unit of the
      base has (e.g. USDC has 6 decimals, ETH has 18).
    * `lot_size`: The size in subunits of one lot of base coin.
    """
    smallest_decimal = Decimal(smallest_decimal_size)
    smallest_subunits = (smallest_decimal * (10 ** base_coin_decimals)) / lot_size
    if smallest_subunits < 0:
        raise ValueError("Decimal size too small to represent with 1 lot")
    return math.ceil(smallest_subunits)


def get_min_quote_per_base_nominal(
    smallest_decimal_size_base: float,
    smallest_decimal_size_quote: float,
) -> float:
    """
    Returns the minimum units of quote that one can obtain for a unit of
    base, given the granularity of base and granularity of quote. This
    can be thought of as price granularity--how much the price must move
    by in order to move at all. If the price granularity is 10 USDC for
    example, then only prices divisible by 10 are expressible: $10/unit,
    $20/unit, $30/unit, any so on.

    Parameters:
    * `smallest_decimal_size_base`: The decimal size of one lot of base.
    * `smallest_decimal_size_quote`: The decimal size of one tick of quote.
    """
    return (1/smallest_decimal_size_base) * smallest_decimal_size_quote