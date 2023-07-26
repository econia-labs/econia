from enum import IntEnum


class Side(IntEnum):
    BID = 0
    ASK = 1


class AdvanceStyle(IntEnum):
    Ticks = 0
    Percent = 1


class SelfMatchBehavior(IntEnum):
    Abort = 0
    CancelBoth = 1
    CancelMaker = 2
    CancelTaker = 3


class Restriction(IntEnum):
    NoRestriction = 0
    FillOrAbort = 1
    ImmediateOrCancel = 2
    PostOrAbort = 3


class CancelReason(IntEnum):
    Eviction = 1
    ImmediateOrCancel = 2
    ManualCancel = 3
    MaxQuoteTraded = 4
    NotEnoughLiquidity = 5
    SelfMatchMaker = 6
    SelfMatchTaker = 7
