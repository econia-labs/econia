import math
from decimal import Decimal
from typing import Tuple

MAX_TICKS_INTEGER = (2**32) - 1


def _verify_decimal_input(decimal_input: str):
    if type(decimal_input) is not str:
        raise ValueError("Decimal input should be a string")


def _verify_integer_input(integer_input: int):
    if type(integer_input) is not int:
        raise ValueError("Integer input should be an integer")


def _get_lot_size_integer(smallest_base_unit: str, base_decimals: int) -> int:
    _verify_decimal_input(smallest_base_unit)
    _verify_integer_input(base_decimals)
    smallest_decimal = Decimal(smallest_base_unit)
    smallest_subunits = 10 ** (base_decimals + math.log10(smallest_decimal))
    if smallest_subunits < 1:
        raise ValueError("Decimal unit too small to represent with 1 subunit")
    return math.ceil(smallest_subunits)


def _get_tick_size_integer(
    size_precision_nominal: str,
    price_precision_nominal: str,
    quote_decimals: int,
) -> int:
    _verify_decimal_input(size_precision_nominal)
    _verify_decimal_input(price_precision_nominal)
    _verify_integer_input(quote_decimals)
    tick_size = (
        Decimal(price_precision_nominal)
        * Decimal(size_precision_nominal)
        * (10**quote_decimals)
    )
    if tick_size < 1:
        raise ValueError("The price is too granular given the size granularity")
    return math.ceil(tick_size)


def get_market_parameters_integer(
    size_precision_nominal: str,
    price_precision_nominal: str,
    min_size_nominal: str,
    base_decimals: int,
    quote_decimals: int,
) -> Tuple[int, int, int]:
    """
    Returns the tuple of market parameters in integer terms, rather than nominal
    terms, given the three nominal parameters plus base and quote decimals. These
    can be directly used to register a market (along with the base/quote types).

    Parameters:
    * `size_precision_nominal`: The size precision in nominal base terms.
    * `price_precision_nominal`: The price precision in nominal quote/base terms.
    * `min_size_nominal`: The minimum size in nominal base terms.
    * `base_decimals`: The number of decimals in the nominal base unit.
    * `quote_decimals`: The number of decimals in the nominal quote unit.

    Returns: (lot_size_integer, tick_size_integer, min_size_integer)
    """
    lot_size = _get_lot_size_integer(size_precision_nominal, base_decimals)
    tick_size = _get_tick_size_integer(
        size_precision_nominal, price_precision_nominal, quote_decimals
    )
    min_size = _get_min_size_integer(min_size_nominal, base_decimals, lot_size)
    return (lot_size, tick_size, min_size)


def get_market_parameters_nominal(
    lot_size_integer: int,
    tick_size_integer: int,
    min_size_integer: int,
    base_decimals: int,
    quote_decimals: int,
) -> Tuple[Decimal, Decimal, Decimal]:
    """
    Returns the tuple of market parameters in nominal terms, rather than integer
    terms, given the three parameters as integers plus base and quote decimals.

    Parameters:
    * `lot_size_integer`: The size granularity in terms of base subunits.
    * `tick_size_integer`: The tick granularity in terms of quote subunits.
    * `min_size_integer`: The minimum size in terms of lots of base.
    * `base_decimals`: The number of decimals in the nominal base unit.
    * `quote_decimals`: The number of decimals in the nominal quote unit.

    Returns: (lot_size_nominal, tick_size_nominal, min_size_nominal)
    """
    _verify_integer_input(lot_size_integer)
    _verify_integer_input(tick_size_integer)
    _verify_integer_input(min_size_integer)
    _verify_integer_input(base_decimals)
    _verify_integer_input(quote_decimals)
    lot_size_nominal = Decimal(lot_size_integer) / (10**base_decimals)
    tick_size_nominal = Decimal(tick_size_integer) / (10**quote_decimals)
    min_size_nominal = Decimal(min_size_integer * lot_size_integer) / (
        10**base_decimals
    )
    return (lot_size_nominal, tick_size_nominal, min_size_nominal)


def get_price_integer(
    nominal_price: str,
    lot_size_integer: int,
    tick_size_integer: int,
    base_decimals: int,
    quote_decimals: int,
) -> int:
    """
    Returns the "ticks per lot" price given a nominal price and other configuration
    variables.

    Parameters:
    * `nominal_price`: The price of one nominal unit of base in terms of nominal quote
      units.
    * `lot_size_integer`: The subunits of base that make up one lot.
    * `tick_size_integer`: The subunits of quote that make up one tick.
    * `base_decimals`: The number of decimals in one nominal unit of base.
    * `quote_decimals`: The number of decimals in one nominal unit of quote.
    """
    _verify_decimal_input(nominal_price)
    _verify_integer_input(lot_size_integer)
    _verify_integer_input(tick_size_integer)
    _verify_integer_input(base_decimals)
    _verify_integer_input(quote_decimals)
    result = Decimal(nominal_price) * Decimal(
        (10**quote_decimals) / (10**base_decimals)
    )
    result = result * Decimal((1 / tick_size_integer) / (1 / lot_size_integer))
    result_floor = math.floor(result)
    result_ceil = math.ceil(result)
    if result_floor != result_ceil:
        raise ValueError(
            "The price is not expressible as an integer with the parameters"
        )
    return result_ceil


def get_price_nominal(
    integer_price: int,
    lot_size_integer: int,
    tick_size_integer: int,
    base_decimals: int,
    quote_decimals: int,
) -> Decimal:
    """
    Returns the "quote per base" price given an integer price and other configuration
    variables.

    Parameters:
    * `integer_price`: The number of ticks of quote per lot representing the price.
    * `lot_size_integer`: The subunits of base that make up one lot.
    * `tick_size_integer`: The subunits of quote that make up one tick.
    * `base_decimals`: The number of decimals in one nominal unit of base.
    * `quote_decimals`: The number of decimals in one nominal unit of quote.
    """
    _verify_integer_input(integer_price)
    _verify_integer_input(lot_size_integer)
    _verify_integer_input(tick_size_integer)
    _verify_integer_input(base_decimals)
    _verify_integer_input(quote_decimals)
    quote_units = Decimal(integer_price * tick_size_integer) / (10**quote_decimals)
    base_units = Decimal(lot_size_integer) / (10**base_decimals)
    return quote_units / base_units


def _get_min_size_integer(
    smallest_decimal_size: str, base_coin_decimals: int, lot_size: int
) -> int:
    _verify_decimal_input(smallest_decimal_size)
    _verify_integer_input(base_coin_decimals)
    _verify_integer_input(lot_size)
    smallest_decimal = Decimal(smallest_decimal_size)
    smallest_subunits = (smallest_decimal * (10**base_coin_decimals)) / lot_size
    if smallest_subunits < 0:
        raise ValueError("Decimal size too small to represent with 1 lot")
    return math.ceil(smallest_subunits)


def get_max_price_nominal(price_precision_nominal: str) -> Decimal:
    """
    Returns the maximum units of quote that once can obtain for a unit of
    base, given the granularity of base and granularity of quote. This
    can be thought of as maximum price.

    Parameters:
    * `price_precision_nominal`: The price precision in nominal quote/base terms.
    """
    _verify_decimal_input(price_precision_nominal)
    return Decimal(price_precision_nominal) * MAX_TICKS_INTEGER
