"""Incentive parameters functionality."""
import argparse
from decimal import Decimal
from pathlib import Path
from typing import List

# Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

UTILITY_COIN_DECIMALS = 8
"""Number of decimals in utility coin."""

MARKET_REGISTRATION_FEE = Decimal("25")
"""USD Cost to register a market."""

UNDERWRITER_REGISTRATION_FEE = Decimal("0.01")
"""USD cost to register as an underwriter."""

CUSTODIAN_REGISTRATION_FEE = Decimal("0.01")
"""USD cost to register as a custodian."""

TAKER_FEE_PERCENTAGE = Decimal("0.05")
"""Flat taker fee percentage."""

TIERS = [
    [Decimal("0.01"), Decimal("0.00"), Decimal("0.20")],
    [Decimal("0.012"), Decimal("0.20"), Decimal("0.19")],
    [Decimal("0.013"), Decimal("3"), Decimal("0.18")],
    [Decimal("0.014"), Decimal("40"), Decimal("0.17")],
    [Decimal("0.015"), Decimal("500"), Decimal("0.16")],
    [Decimal("0.016"), Decimal("6_000"), Decimal("0.15")],
    [Decimal("0.017"), Decimal("70_000"), Decimal("0.14")],
]
"""Integrator tier parameters."""

INDENT = "    "
"""4-space indent."""

DOC_COMMENT = f"{INDENT}/// Genesis parameter."
"""Doc comment used for DocGen in incentives module file."""

BLOCK_COMMENT = f"{INDENT}// Incentive parameters."
"""Constant block delimiter for Move script file."""

# Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Formatters >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


def format_constant_definition(
    name: str,
    amount: Decimal,
    is_genesis_parameter: bool = False,
) -> str:
    """Format a constant definition for a block of constants.

    Example
    -------
    >>> print(format_constant_definition("FOO", Decimal("1.02"), True))
        /// Genesis parameter.
        const FOO: u64 = 1;
    >>> print(format_constant_definition("BAR", Decimal("500")))
        const BAR: u64 = 500;
    """
    # Prepend genesis parameter doc comment if necessary.
    base = f"{DOC_COMMENT}\n" if is_genesis_parameter else ""
    # Return appended and formatted constant definition block.
    return f"{base}{INDENT}const {name}: u64 = {str(int(amount))};"


def generate_constants_block(
    utility_coin_usd_value: Decimal,
    utility_coin_decimals: int = UTILITY_COIN_DECIMALS,
    market_registration_fee: Decimal = MARKET_REGISTRATION_FEE,
    underwriter_registration_fee: Decimal = UNDERWRITER_REGISTRATION_FEE,
    custodian_registration_fee: Decimal = CUSTODIAN_REGISTRATION_FEE,
    taker_fee_percentage: Decimal = TAKER_FEE_PERCENTAGE,
    tiers: List[List[Decimal]] = TIERS,
    is_genesis_block: bool = False,
) -> str:
    """Return a block of Move incentive parameter constant definitions.

    Example
    -------
    >>> utility_coin_usd_value = Decimal("20")
    >>> utility_coin_decimals = 8
    >>> market_registration_fee = Decimal("25")
    >>> underwriter_registration_fee = Decimal("0.01")
    >>> custodian_registration_fee = Decimal("0.01")
    >>> taker_fee_percentage = Decimal("0.05")
    >>> tiers = [
    ...     [Decimal("0.01"), Decimal("0.00"), Decimal("0.20")],
    ...     [Decimal("0.012"), Decimal("0.20"), Decimal("0.19")],
    ... ]
    >>> print(generate_constants_block(
    ...     utility_coin_usd_value,
    ...     utility_coin_decimals,
    ...     market_registration_fee,
    ...     underwriter_registration_fee,
    ...     custodian_registration_fee,
    ...     taker_fee_percentage,
    ...     tiers))
        // Incentive parameters.
        const MARKET_REGISTRATION_FEE: u64 =  125000000;
        const UNDERWRITER_REGISTRATION_FEE: u64 = 50000;
        const CUSTODIAN_REGISTRATION_FEE: u64 =   50000;
        const TAKER_FEE_DIVISOR: u64 =             2000;
        const FEE_SHARE_DIVISOR_0: u64 =          10000;
        const FEE_SHARE_DIVISOR_1: u64 =           8333;
        const TIER_ACTIVATION_FEE_0: u64 =            0;
        const TIER_ACTIVATION_FEE_1: u64 =      1000000;
        const WITHDRAWAL_FEE_0: u64 =           1000000;
        const WITHDRAWAL_FEE_1: u64 =            950000;
    >>> print(generate_constants_block(
    ...     utility_coin_usd_value,
    ...     utility_coin_decimals,
    ...     market_registration_fee,
    ...     underwriter_registration_fee,
    ...     custodian_registration_fee,
    ...     taker_fee_percentage,
    ...     tiers,
    ...     is_genesis_block=True))
        /// Genesis parameter.
        const MARKET_REGISTRATION_FEE: u64 =  125000000;
        /// Genesis parameter.
        const UNDERWRITER_REGISTRATION_FEE: u64 = 50000;
        /// Genesis parameter.
        const CUSTODIAN_REGISTRATION_FEE: u64 =   50000;
        /// Genesis parameter.
        const TAKER_FEE_DIVISOR: u64 =             2000;
        /// Genesis parameter.
        const FEE_SHARE_DIVISOR_0: u64 =          10000;
        /// Genesis parameter.
        const FEE_SHARE_DIVISOR_1: u64 =           8333;
        /// Genesis parameter.
        const TIER_ACTIVATION_FEE_0: u64 =            0;
        /// Genesis parameter.
        const TIER_ACTIVATION_FEE_1: u64 =      1000000;
        /// Genesis parameter.
        const WITHDRAWAL_FEE_0: u64 =           1000000;
        /// Genesis parameter.
        const WITHDRAWAL_FEE_1: u64 =            950000;
    """
    # Get USD per subunit of utility coin.
    usd_per_subunit = utility_coin_usd_value / Decimal(1).shift(
        utility_coin_decimals
    )
    # Index tier parameters.
    divisors, activation_fees, withdrawal_fees = (
        [percent_to_divisor(tier[0]) for tier in tiers],
        [tier[1] for tier in tiers],
        [tier[2] for tier in tiers],
    )
    # Get block comment header if not a genesis parameter block.
    header = "" if is_genesis_block else f"{BLOCK_COMMENT}\n"
    # Return justified constants block.
    return header + justify_constants(
        "\n".join(
            [
                format_constant_definition(
                    "MARKET_REGISTRATION_FEE",
                    market_registration_fee / usd_per_subunit,
                    is_genesis_block,
                ),
                format_constant_definition(
                    "UNDERWRITER_REGISTRATION_FEE",
                    underwriter_registration_fee / usd_per_subunit,
                    is_genesis_block,
                ),
                format_constant_definition(
                    "CUSTODIAN_REGISTRATION_FEE",
                    custodian_registration_fee / usd_per_subunit,
                    is_genesis_block,
                ),
                format_constant_definition(
                    "TAKER_FEE_DIVISOR",
                    percent_to_divisor(taker_fee_percentage),
                    is_genesis_block,
                ),
                "\n".join(
                    [
                        format_constant_definition(
                            f"FEE_SHARE_DIVISOR_{i}",
                            divisor,
                            is_genesis_block,
                        )
                        for i, divisor in enumerate(divisors)
                    ],
                ),
                "\n".join(
                    [
                        format_constant_definition(
                            f"TIER_ACTIVATION_FEE_{i}",
                            activation_fee / usd_per_subunit,
                            is_genesis_block,
                        )
                        for i, activation_fee in enumerate(activation_fees)
                    ],
                ),
                "\n".join(
                    [
                        format_constant_definition(
                            f"WITHDRAWAL_FEE_{i}",
                            withdrawal_fee / usd_per_subunit,
                            is_genesis_block,
                        )
                        for i, withdrawal_fee in enumerate(withdrawal_fees)
                    ],
                ),
            ]
        )
    )


def justify_constants(block: str) -> str:
    """Right justify all of the constants in a definition block.

    Example
    -------
    >>> block = '''\\
    ...     /// Short comment.
    ...     const CONSTANT_1: u64 = 1;
    ...     /// Long comment that is longer than longest line of code.
    ...     const CONSTANT_2: u64 = 200;'''
    >>> print(justify_constants(block))
        /// Short comment.
        const CONSTANT_1: u64 =   1;
        /// Long comment that is longer than longest line of code.
        const CONSTANT_2: u64 = 200;
    """
    lines = block.splitlines()  # Get all lines.
    # Get maximum line length for lines of code (ending in semicolon).
    max_length = max([len(line) for line in lines if line[-1] == ";"])
    for i, line in enumerate(lines):  # Loop over all lines.
        if line[-1] == ";":  # If line ends in semicolon (is code):
            pad = (max_length - len(line)) * " "  # Get pad required.
            if pad != "":  # If need to pad line:
                tokens = line.split()  # Get tokens in line.
                # Update line with padded integer value.
                lines[i] = f"{INDENT}{' '.join(tokens[:-1])} {pad}{tokens[-1]}"
    return "\n".join(lines)  # Return formatted block of new lines.


def percent_to_divisor(percent: Decimal) -> int:
    """Convert a percent to an integer divisor.

    Example
    -------
    >>> percent_to_divisor(Decimal('0.05'))
    2000
    >>> percent_to_divisor(Decimal('0.03'))
    3333
    >>> percent_to_divisor(Decimal('0.015'))
    6667
    """
    return int(round(1 / (percent / 100)))


# Formatters <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Parser >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

parser = argparse.ArgumentParser(
    description="Assorted incentive parameter operations.",
)
subparsers = parser.add_subparsers(required=True)


def update_incentive_parameters(args):
    """Update incentive parameters in indicated Move file."""
    lines = args.path.read_text().splitlines()  # Get file lines.
    found_block = False  # Flag that scan is not yet in block.
    # Get constants block delimiter.
    delimiter = DOC_COMMENT if args.genesis_parameters else BLOCK_COMMENT
    for i, line in enumerate(lines):  # Scan over lines in file:
        # If found first line of block:
        if line == delimiter and not found_block:
            found_block = True  # Mark block found.
            block_start_line = i  # Mark block start line.
        # If out of block:
        if found_block and line == "":
            line_after_block = i  # Mark line after block.
            break  # Stop scan.
    # Substitute in generated constants block.
    lines[block_start_line:line_after_block] = generate_constants_block(
        utility_coin_usd_value=args.utility_coin_usd_value,
        utility_coin_decimals=args.utility_coin_decimals,
        is_genesis_block=args.genesis_parameters,
    ).splitlines()
    args.path.write_text("\n".join(lines))  # Write file.


# Update subcommand parser.
parser_update = subparsers.add_parser(
    name="update",
    aliases=["u"],
    description="Update update incentive parameters in Move file.",
    help="Update incentive parameters.",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
)
parser_update.set_defaults(func=update_incentive_parameters)
parser_update.add_argument(
    "path",
    type=Path,
    help="Relative path to Move file to update.",
)
parser_update.add_argument(
    "utility_coin_usd_value",
    metavar="utility-coin-usd-value",
    type=Decimal,
    help="Utility coin value in USD.",
)
parser_update.add_argument(
    "-g",
    "--genesis-parameters",
    action="store_true",
    help="True if updating genesis parameters in incentives module.",
)
parser_update.add_argument(
    "-d",
    "--utility-coin-decimals",
    type=int,
    default=UTILITY_COIN_DECIMALS,
    help="Utility coin decimals.",
)

# Parser <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if __name__ == "__main__":
    parsed_args = parser.parse_args()  # Parse command line arguments.
    parsed_args.func(parsed_args)  # Call parsed args callback function.
