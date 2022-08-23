/// User-side book keeping and, optionally, collateral management.
///
/// For a given market, a user can register multiple `MarketAccount`s,
/// with each such market account having a different delegated custodian
/// ID and therefore a unique `MarketAccountInfo`: hence, each market
/// account has a particular "user-specific" custodian ID. For a given
/// `MarketAccount`, a user has entries in a `Collateral` map for each
/// asset that is a coin type.
///
/// For assets that are not a coin type, the "market-wide generic asset
/// transfer" custodian (`registry::TradingPairInfo`) is required to
/// verify deposits and withdrawals. Hence a user-specific general
/// custodian overrides a market-wide generic asset transfer
/// custodian when placing or cancelling trades on an asset-agnostic
/// market, whereas the market-wide generic asset transfer custodian
/// overrides the user-specific general custodian ID when depositing or
/// withdrawing a non-coin asset.
module econia::user {

    // Dependency planning stubs
    public(friend) fun return_0(): u8 {0}

    // Friends >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    friend econia::market;

    // Friends <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}