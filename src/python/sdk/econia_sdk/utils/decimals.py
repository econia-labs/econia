import math

def get_lot_size(smallest_decimal_unit: float, coin_decimals: int) -> int:
    """
    Given a decimal representation of the smallest possible unit and the
    whole unit's decimals (e.g. ETH has 18 decimals), return the lot size.

    Parameters:
    * `smallest_decimal_unit`: Decimal (e.g. 0.001 for one thousandth) of
      the smallest possible unit relative to a whole unit.
    * `coin_decimals`: The number of decimals one whole unit of the coin
      has (e.g. USDC has 6 decimals, ETH has 18).
    """
    return math.ceil(10**(coin_decimals+math.log10(smallest_decimal_unit)))

def get_tick_size(smallest_decimal_unit: float, coin_decimals: int) -> int:
    """
    Given a decimal representation of the smallest possible unit and the
    whole unit's decimals (e.g. ETH has 18 decimals), return the tick size.

    Parameters:
    * `smallest_decimal_unit`: Decimal (e.g. 0.001 for one thousandth) of
      the smallest possible unit relative to a whole unit.
    * `coin_decimals`: The number of decimals one whole unit of the coin
      has (e.g. USDC has 6 decimals, ETH has 18).
    """
    return get_lot_size(smallest_decimal_unit, coin_decimals)

def get_min_size(
    smallest_decimal_size: float,
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
    smallest_subunits = smallest_decimal_size * (10 ** base_coin_decimals)
    return math.ceil(smallest_subunits / lot_size)


def get_min_quote_per_base(
    smallest_decimal_size_base: float,
    smallest_decimal_size_quote: float,
) -> float:
    """
    """
    return (1/smallest_decimal_size_base) * smallest_decimal_size_quote