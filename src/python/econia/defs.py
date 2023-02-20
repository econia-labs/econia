"""Value definitions

Define all numbers/strings, etc. here so code has no unnamed values
"""

from decimal import Decimal as dec
from types import SimpleNamespace

build_command_fields = SimpleNamespace(
    docgen="docgen",
    generate="generate",
    genesis="genesis",
    print_keyfile_address="print-keyfile-address",
    rev="rev",
    substitute="substitute",
)
"""Command line fields for automated building process"""

incentive_parameters = SimpleNamespace(
    market_registration_fee=SimpleNamespace(
        constant_name="MARKET_REGISTRATION_FEE", amount=dec("25")
    ),
    underwriter_registration_fee=SimpleNamespace(
        constant_name="UNDERWRITER_REGISTRATION_FEE", amount=dec("0.01")
    ),
    custodian_registration_fee=SimpleNamespace(
        constant_name="CUSTODIAN_REGISTRATION_FEE", amount=dec("0.01")
    ),
    taker_fee_percentage=SimpleNamespace(
        constant_name="TAKER_FEE_DIVISOR", amount=dec("0.05")
    ),
    tiers=SimpleNamespace(
        fields=SimpleNamespace(
            fee_share_percentage=SimpleNamespace(
                constant_name_base="FEE_SHARE_DIVISOR", field_index=0
            ),
            tier_activation_fee=SimpleNamespace(
                constant_name_base="TIER_ACTIVATION_FEE", field_index=1
            ),
            withdrawal_fee=SimpleNamespace(
                constant_name_base="WITHDRAWAL_FEE", field_index=2
            ),
        ),
        amounts=[
            [dec("0.01"), dec("0.00"), dec("0.20")],
            [dec("0.012"), dec("0.20"), dec("0.19")],
            [dec("0.013"), dec("3"), dec("0.18")],
            [dec("0.014"), dec("40"), dec("0.17")],
            [dec("0.015"), dec("500"), dec("0.16")],
            [dec("0.016"), dec("6_000"), dec("0.15")],
            [dec("0.017"), dec("70_000"), dec("0.14")],
        ],
    ),
    doc_comment="    /// Genesis parameter.\n",
    indent="    ",
    constant_token="const",
    constant_type="u64",
    percent_base=100,
)
"""Incentive parameters, values in USD"""

Econia = "Econia"
"""Project name"""

econia_paths = SimpleNamespace(
    # Relative to Econia repository root directory
    move_package_root="src/move/econia",
    # Relative to Move package root
    ss_path="ss",
    # Relative to Move package root
    toml_path="Move",
    # Relative to Move package root
    incentives_path="sources/incentives",
)
"""Econia Move code paths"""

e_msgs = SimpleNamespace(
    path_val_collision="Different value already exists at provided path"
)
"""Error messages"""

file_extensions = SimpleNamespace(key="key", move="move", sh="sh", toml="toml")
"""Extensions for common filetypes"""

named_addrs = SimpleNamespace(
    econia=SimpleNamespace(
        docgen="c0deb00c",
        address_name="econia",
    )
)
"""Named addresses"""

regex_trio_group_ids = SimpleNamespace(start=1, middle=2, end=3)
"""For RegEx search yielding 3 group matches"""

seps = SimpleNamespace(
    amp="&",
    cln=":",
    cma=",",
    dot=".",
    eq="=",
    gt=">",
    hex="0x",
    lsb="[",
    lt="<",
    lp="(",
    nl="\n",
    pnd="#",
    qm="?",
    rp=")",
    rsb="]",
    sc=";",
    sq="'",
    sls="/",
    sp=" ",
    us="_",
)
"""Separators"""

single_sig_id = b"\x00"
"""1-byte signature scheme identifier, indicating single signature"""

toml_section_names = SimpleNamespace(addresses="addresses")
"""Section names in Move.toml file"""

util_paths = SimpleNamespace(
    # Relative to Econia repository root
    secrets_dir=".secrets",
    # Relative to secrets directory
    old_keys="old",
    # Econia repository root relative to `src/jupyter`
    econia_root_rel_jupyter="../..",
)
"""Paths to developer utility resources"""
