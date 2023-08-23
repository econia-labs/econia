import math
from decimal import Decimal
from typing import Tuple


def _verify_decimal_input(decimal_input: str):
    if type(decimal_input) is not str:
        raise ValueError("Decimal input should be a string")


def _verify_integer_input(integer_input: int):
    if type(integer_input) is not int:
        raise ValueError("Integer input should be an integer")


def get_lot_size_integer(smallest_base_unit: str, base_decimals: int) -> int:
    """
    Given a decimal representation of the smallest possible unit and the
    whole unit's decimals (e.g. ETH has 18 decimals), return the lot size.

    Parameters:
    * `smallest_decimal_unit`: Decimal (e.g. "0.001" for one thousandth) of
      the smallest possible unit relative to a whole unit.
    * `coin_decimals`: The number of decimals one whole unit of the coin
      has (e.g. USDC has 6 decimals, ETH has 18).
    """
    _verify_decimal_input(smallest_base_unit)
    _verify_integer_input(base_decimals)
    smallest_decimal = Decimal(smallest_base_unit)
    smallest_subunits = 10 ** (base_decimals + math.log10(smallest_decimal))
    if smallest_subunits < 1:
        raise ValueError("Decimal unit too small to represent with 1 subunit")
    return math.ceil(smallest_subunits)


def get_tick_size_integer(smallest_quote_unit: str, quote_decimals: int) -> int:
    """
    Given a decimal representation of the smallest possible unit and the
    whole unit's decimals (e.g. ETH has 18 decimals), return the tick size.

    Parameters:
    * `smallest_decimal_unit`: Decimal (e.g. "0.001" for one thousandth) of
      the smallest possible unit relative to a whole unit.
    * `coin_decimals`: The number of decimals one whole unit of the coin
      has (e.g. USDC has 6 decimals, ETH has 18).
    """
    return get_lot_size_integer(smallest_quote_unit, quote_decimals)


def get_tick_size_integer_for_price_granularity(
    size_precision_nominal: str,
    price_precision_nominal: str,
    quote_decimals: int,
) -> int:
    """
    Returns the tick size integer to achieve a price precision given a size
    granularity, both in nominal terms.

    Parameters:
    * `size_precision_nominal`: Decimal (e.g. "0.001" for one thousandth) of
      the smallest possible size (of base) relative to a whole unit.
    * `price_precision_nominal`: The ratio of quote per base by which price
      is incremented and/or decremented (e.g. "0.01" USD/BTC expresses a
      price granularity of one penny).
    * `base decimals`: The number of decimals in the base for conversion to
       integer subunit terms.
    """
    _verify_decimal_input(size_precision_nominal)
    _verify_decimal_input(price_precision_nominal)
    _verify_integer_input(quote_decimals)
    tick_size = Decimal(price_precision_nominal) \
      * Decimal(size_precision_nominal) \
      * (10 ** quote_decimals)
    if tick_size < 1:
        raise ValueError("The price is too granular")
    return math.ceil(tick_size)


def get_market_parameters_nominal(
    lot_size_integer: int,
    tick_size_integer: int,
    min_size_integer: int,
    base_decimals: int,
    quote_decimals: int,
) -> Tuple[float, float, float]:
    """
    Returns the tuple of market parameters in nominal terms, rather than integer
    terms, given the three parameters as integers plus base and quote decimals.

    Parameters:
    * `lot_size_integer`: The size granularity in terms of base subunits.
    * `tick_size_integer`: The tick granularity in terms of quote subunits.
    * `min_size_integer`: The minimum size in terms of lots of base.
    * `base_decimals`: The number of decimals in the nominal base unit.
    * `quote_decimals`: The number of decimals in the nominal quote unit.
    """
    _verify_integer_input(lot_size_integer)
    _verify_integer_input(tick_size_integer)
    _verify_integer_input(min_size_integer)
    _verify_integer_input(base_decimals)
    _verify_integer_input(quote_decimals)
    lot_size_nominal = lot_size_integer / (10 ** base_decimals)
    tick_size_nominal = tick_size_integer / (10 ** quote_decimals)
    min_size_nominal = (min_size_integer * lot_size_integer) / (10 ** base_decimals)
    return (lot_size_nominal, tick_size_nominal, min_size_nominal)


def get_price_integer(
    nominal_price: str,
    lot_size: int,
    tick_size: int,
    base_decimals: int,
    quote_decimals: int,
  ) -> int:
    """
    Returns the "ticks per lot" price given a nominal price and other configuration variables.

    Parameters:
    * `nominal_price`: The price of one nominal unit of base in terms of nominal quote units.
    * `lot_size`: The subunits of base that make up one lot.
    * `tick_size`: The subunits of quote that make up one tick.
    * `base_decimals`: The number of decimals in one nominal unit of base.
    * `quote_decimals`: The number of decimals in one nominal unit of quote.
    """
    _verify_decimal_input(nominal_price)
    _verify_integer_input(lot_size)
    _verify_integer_input(tick_size)
    _verify_integer_input(base_decimals)
    _verify_integer_input(quote_decimals)
    result = Decimal(nominal_price) * Decimal((10 ** quote_decimals) / (10 ** base_decimals))
    result = result * Decimal((1 / tick_size) / (1 / lot_size))
    result_floor = math.floor(result)
    result_ceil = math.ceil(result)
    if (result_floor != result_ceil):
        raise ValueError("The price is not expressible as an integer with the parameters")
    return result_ceil

def get_price_nominal(integer_price: int, lot_size: int, tick_size: int) -> float:
    """
    Returns the "quote per base" price given an integer price and other configuration variables.

    Parameters:
    * `integer_price`: The number of ticks of quote per lot representing the price.
    * `lot_size`: The subunits of base that make up one lot.
    * `tick_size`: The subunits of quote that make up one tick.
    """
    _verify_integer_input(integer_price)
    _verify_integer_input(lot_size)
    _verify_integer_input(tick_size)
    return (integer_price * tick_size) / lot_size


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
