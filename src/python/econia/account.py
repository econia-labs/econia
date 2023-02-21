"""Account file management."""

import argparse
import os
import shutil
from pathlib import Path

from aptos_sdk.account import Account

# Parser >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

parser = argparse.ArgumentParser(
    description="Assorted Aptos account operations.",
)
subparsers = parser.add_subparsers(required=True)


def print_auth_key(args):
    """Print authentication key for sole secret file in directory."""
    dir = args.parent_dir  # Get parent dir path.
    assert (  # Assert directory exists and has only one file.
        dir.exists() and len(os.listdir(dir)) == 1
    ), "Parent directory may not have more than one file."
    secret_file = next(dir.iterdir())  # Get secrets file.
    # Get account from secrets file.
    account = Account.load_key(secret_file.read_text())
    # Get authentication key without hex prefix.
    auth_key = account.account_address.address.hex()
    # Print notice of secret file path.
    print(f"Secret file:\n {os.path.abspath(secret_file)}")
    # Print notice of authentication key.
    print(f"Authentication key:\n {auth_key}")


# Authentication key subcommand parser.
parser_auth_key = subparsers.add_parser(
    name="authentication-key",
    aliases=["a"],
    description="Print authentication key from secret file in directory.",
    help="Print authentication key.",
)
parser_auth_key.set_defaults(func=print_auth_key)
parser_auth_key.add_argument(
    "parent_dir",
    metavar="parent-dir",
    type=Path,
    help="Relative path to directory containing a single keyfile.",
)


def generate_secret_file(args):
    """Generate new account and store secret on disk."""
    # Get parent directory to store secret file in.
    dir = args.secrets_path / Path(args.type)
    if dir.exists():  # Parent directory to store in exists:
        if len(os.listdir(dir)) > 0:  # If it is not empty:
            # Get directory to store old secret files in.
            old_dir = args.secrets_path / Path("old")
            if not old_dir.exists():  # If old directory doesn't exist:
                os.makedirs(old_dir)  # Create it.
            # Iterate over files in target directory:
            for file in dir.iterdir():
                shutil.move(file, old_dir)  # Move file to old dir.
    else:  # If parent directory to store in does not exist:
        os.makedirs(dir)  # Create it.
    account = Account.generate()  # Generate new account.
    # Get authentication key without hex prefix.
    auth_key = account.account_address.address.hex()
    # Get file path from authentication key.
    file_path = dir / Path(f"{auth_key}.secret")
    # Write private key hex to file.
    file_path.write_text(account.private_key.key.encode().hex())
    # Print notice.
    print(f"New account secret file:\n {os.path.abspath(file_path)}")


# Generate subcommand parser.
parser_generate = subparsers.add_parser(
    name="generate",
    aliases=["g"],
    description="Generate a new Aptos account secret file.",
    help="Generate secret file.",
)
parser_generate.set_defaults(func=generate_secret_file)
parser_generate.add_argument(
    "secrets_path",
    metavar="secrets-path",
    type=Path,
    help="Relative path to secrets directory.",
)
parser_generate.add_argument(
    "-t",
    "--type",
    choices=["persistent", "temporary"],
    type=str,
    help="Type of account secret file to generate.",
)


# Parser <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if __name__ == "__main__":
    parsed_args = parser.parse_args()  # Parse command line arguments.
    parsed_args.func(parsed_args)  # Call parsed args callback function.
