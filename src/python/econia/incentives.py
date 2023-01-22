"""Incentive parameters functionality."""

from decimal import Decimal as dec
from econia.defs import incentive_parameters as params, seps

def format_constant_definition(
    name: str,
    amount: dec,
    first_in_block: bool = False
) -> str:
    """Format a constant definition for a block of constants.

    Parameters
    ----------
    name : str
        Constant name.
    amount : decimal.Decimal
        Constant amount.
    first_in_block : bool, optional
        If False, prepend a newline.

    Returns
    -------
    str
        Formatted constant definition.

    Example
    -------
    >>> from decimal import Decimal as dec
    >>> from econia.incentives import format_constant_definition
    >>> print(format_constant_definition('MY_PARAMETER', dec('5.02'), True))
        /// Genesis parameter.
        const MY_PARAMETER: u64 = 5;
    >>> print(format_constant_definition('MY_PARAMETER', dec('5.02'), False))
    <BLANKLINE>
        /// Genesis parameter.
        const MY_PARAMETER: u64 = 5;
    """
    if first_in_block:
        formatted = ''
    else:
        formatted = seps.nl
    return formatted + params.doc_comment + params.indent \
        + params.constant_token + seps.sp + name + seps.cln + seps.sp \
        + params.constant_type + seps.sp + seps.eq + seps.sp \
        + str(int(amount)) + seps.sc

def percent_to_divisor(
    percent: dec
) -> int:
    """Convert a percent to an integer divisor.

    Parameters
    ----------
    percent : str
        A percent.

    Returns
    -------
    int
        Corresponding divisor.

    Example
    -------
    >>> from decimal import Decimal as dec
    >>> from econia.incentives import percent_to_divisor
    >>> percent_to_divisor(dec('0.05'))
    2000
    >>> percent_to_divisor(dec('0.03'))
    3333
    >>> percent_to_divisor(dec('0.015'))
    6667
    """
    return int(round(1 / (percent / params.percent_base)))

def justify_constants(
    block: str
) -> str:
    """Right justify all of the constants in a definition block.

    Parameters
    ----------
    block : str
        A block of text with Move constant definitions.

    Returns
    -------
    str
        The same block, with all constants right-justified.

    Example
    -------
    >>> from econia.incentives import justify_constants
    >>> block = '''\\
    ...     /// Comment 1.
    ...     const CONSTANT_1: u64 = 1;
    ...     /// Comment 2.
    ...     const CONSTANT_2: u64 = 200;'''
    >>> print(justify_constants(block))
        /// Comment 1.
        const CONSTANT_1: u64 =   1;
        /// Comment 2.
        const CONSTANT_2: u64 = 200;
    """
    lines = block.splitlines() # Get all lines.
    max_length = 0 # Declare maximum line length.
    for line in lines: # Loop over all lines.
        if line[-1] is seps.sc: # If line ends in semicolon:
            # Update maximum line length as needed.
            if len(line) > max_length: max_length = len(line)
    new_block = '' # Initialize new block.
    for i, line in enumerate(lines): # Loop over all lines.
        if i != 0: # If not on first line:
            new_block = new_block + seps.nl # Append newline separator.
        if line[-1] is seps.sc: # If line ends in semicolon:
            indent = max_length - len(line) # Calculate indent required.
            if indent != 0: # If need to indent line:
                tokens = line.split() # Get tokens in line.
                line = params.indent # Start line with indent.
                while (len(tokens) > 1): # While multiple tokens left:
                    # Append the next token to the line.
                    line = line + tokens.pop(0) + seps.sp
                # Add indenting spaces as needed, final token.
                line = line + (indent) * seps.sp + tokens.pop()
        new_block = new_block + line # Append line to block.
    return new_block  # Return block.

def generate_constants_block(
    utility_coin_usd_value: dec,
    utility_coin_decimals: int
) -> str:
    """Generate a block of Move constant definitions.

    Parameters
    ----------
    utility_coin_usd_value : decimal.Decimal
        Value of utility coin in US dollars.
    utility_coin_decimals : int
        Number of decimals in utility coin.

    Returns
    -------
    str
        Formatted block of Move constant definitions.
    """
    # Get USD per subunit of utility coin.
    usd_per_subunit = utility_coin_usd_value \
        / dec(1).shift(utility_coin_decimals)
    block = '' # Initialize empty block.
    # Loop over registration fees:
    for i, registration_fee in enumerate([params.market_registration_fee,
                                          params.underwriter_registration_fee,
                                          params.custodian_registration_fee]):
        # Append constant definition.
        block = block + format_constant_definition(
            registration_fee.constant_name,
            registration_fee.amount / usd_per_subunit,
            i==0)
    # Append taker fee divisor definition.
    block = block + format_constant_definition(
        params.taker_fee_percentage.constant_name,
        percent_to_divisor(params.taker_fee_percentage.amount))
    # Loop over tier fields:
    for tier_field in [params.tiers.fields.fee_share_percentage,
                       params.tiers.fields.tier_activation_fee,
                       params.tiers.fields.withdrawal_fee]:
        # Get constant name base for given field.
        constant_name_base = tier_field.constant_name_base
        # If on fee share percentage field, flag to correct to divisor.
        correct_to_divisor = constant_name_base is \
                params.tiers.fields.fee_share_percentage.constant_name_base
        # Loop over tiers:
        for tier_number, tier_fields in enumerate(params.tiers.amounts):
            # Get amount for field at given tier.
            amount = tier_fields[tier_field.field_index]
            if correct_to_divisor: # Correct to divisor as needed:
                amount = percent_to_divisor(amount)
            else: # Otherwise correct to utility coin subunits:
                amount = amount / usd_per_subunit
            # Append to constants block the corresponding tier field.
            block = block + format_constant_definition(
                constant_name_base + seps.us + str(tier_number), amount)
    return justify_constants(block)

if __name__ == '__main__':
    print(generate_constants_block(dec('4.00'), 8))