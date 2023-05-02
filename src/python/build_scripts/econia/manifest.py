"""Move package manifest functionality."""
import argparse
import re
from pathlib import Path

DEFAULT_NAMED_ADDRESS = "econia"
"""Default named address to update."""

# Parser >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

parser = argparse.ArgumentParser(
    description="Assorted Move package manifest operations.",
)
subparsers = parser.add_subparsers(required=True)


def update_address(args):
    """Update named address in indicated Move package manifest."""
    lines = args.path.read_text().splitlines()  # Get file lines.
    found_block = False  # Flag that scan is not yet in address block.
    for i, line in enumerate(lines):  # Scan over lines in file:
        if not found_block:  # If not found block yet:
            # If found addresses header:
            if line.find("[addresses]") == 0:
                found_block = True  # Mark block found.
        else:  # If addresses block found:
            # If found line to update (if starts with name):
            if line.find(args.name) == 0:
                # Substitute provided named address.
                lines[i] = re.sub(r'"(.+)"', f'"{args.address}"', line)
                args.path.write_text("\n".join(lines))  # Write file.
                return
            # If line empty or if at new header:
            if line == "" or line[0] == "[":
                break  # Break out of loop.
    assert False, "Address not found."  # Raise error if no match.


# Address subcommand parser.
parser_address = subparsers.add_parser(
    name="address",
    aliases=["a"],
    description="Update named address in Move file.",
    help="Update named address.",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
)
parser_address.set_defaults(func=update_address)
parser_address.add_argument(
    "path",
    type=Path,
    help="Relative path to manifest file to update.",
)
parser_address.add_argument(
    "address",
    type=str,
    help="New address.",
)
parser_address.add_argument(
    "-n",
    "--name",
    type=str,
    default="econia",
    help="Named address to update.",
)

# Parser <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if __name__ == "__main__":
    parsed_args = parser.parse_args()  # Parse command line arguments.
    parsed_args.func(parsed_args)  # Call parsed args callback function.
