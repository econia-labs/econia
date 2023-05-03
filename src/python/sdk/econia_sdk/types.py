from enum import Enum


class Side(Enum):
    BID = 0
    ASK = 1


class AdvanceStyle(Enum):
    Ticks = 0
    Percent = 1


class SelfMatchBehavior(Enum):
    Abort = 0
    CancelBoth = 1
    CancelMaker = 2
    CancelTaker = 3


class Restriction(Enum):
    NoRestriction = 0
    FillOrAbort = 1
    ImmediateOrCancel = 2
