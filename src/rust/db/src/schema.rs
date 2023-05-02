// @generated automatically by Diesel CLI.

pub mod sql_types {
    #[derive(diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "maker_event_type"))]
    pub struct MakerEventType;

    #[derive(diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "market_event_type"))]
    pub struct MarketEventType;

    #[derive(diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "order_state"))]
    pub struct OrderState;

    #[derive(diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "side"))]
    pub struct Side;
}

diesel::table! {
    bars_15m (market_id, start_time) {
        market_id -> Numeric,
        start_time -> Timestamptz,
        open -> Numeric,
        high -> Numeric,
        low -> Numeric,
        close -> Numeric,
        volume -> Numeric,
    }
}

diesel::table! {
    bars_1h (market_id, start_time) {
        market_id -> Numeric,
        start_time -> Timestamptz,
        open -> Numeric,
        high -> Numeric,
        low -> Numeric,
        close -> Numeric,
        volume -> Numeric,
    }
}

diesel::table! {
    bars_1m (market_id, start_time) {
        market_id -> Numeric,
        start_time -> Timestamptz,
        open -> Numeric,
        high -> Numeric,
        low -> Numeric,
        close -> Numeric,
        volume -> Numeric,
    }
}

diesel::table! {
    bars_30m (market_id, start_time) {
        market_id -> Numeric,
        start_time -> Timestamptz,
        open -> Numeric,
        high -> Numeric,
        low -> Numeric,
        close -> Numeric,
        volume -> Numeric,
    }
}

diesel::table! {
    bars_5m (market_id, start_time) {
        market_id -> Numeric,
        start_time -> Timestamptz,
        open -> Numeric,
        high -> Numeric,
        low -> Numeric,
        close -> Numeric,
        volume -> Numeric,
    }
}

diesel::table! {
    coins (account_address, module_name, struct_name) {
        account_address -> Varchar,
        module_name -> Text,
        struct_name -> Text,
        symbol -> Varchar,
        name -> Text,
        decimals -> Int2,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;

    fills (market_id, maker_order_id, time) {
        market_id -> Numeric,
        maker_order_id -> Numeric,
        maker -> Varchar,
        maker_side -> Side,
        custodian_id -> Nullable<Numeric>,
        size -> Numeric,
        price -> Numeric,
        time -> Timestamptz,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;
    use super::sql_types::MakerEventType;

    maker_events (market_order_id, time) {
        market_id -> Numeric,
        side -> Side,
        market_order_id -> Numeric,
        user_address -> Varchar,
        custodian_id -> Nullable<Numeric>,
        event_type -> MakerEventType,
        size -> Numeric,
        price -> Numeric,
        time -> Timestamptz,
    }
}

diesel::table! {
    market_registration_events (market_id) {
        market_id -> Numeric,
        time -> Timestamptz,
        base_account_address -> Nullable<Varchar>,
        base_module_name -> Nullable<Text>,
        base_struct_name -> Nullable<Text>,
        base_name_generic -> Nullable<Text>,
        quote_account_address -> Varchar,
        quote_module_name -> Text,
        quote_struct_name -> Text,
        lot_size -> Numeric,
        tick_size -> Numeric,
        min_size -> Numeric,
        underwriter_id -> Numeric,
    }
}

diesel::table! {
    markets (market_id) {
        market_id -> Numeric,
        name -> Text,
        base_account_address -> Nullable<Varchar>,
        base_module_name -> Nullable<Text>,
        base_struct_name -> Nullable<Text>,
        base_name_generic -> Nullable<Text>,
        quote_account_address -> Varchar,
        quote_module_name -> Text,
        quote_struct_name -> Text,
        lot_size -> Numeric,
        tick_size -> Numeric,
        min_size -> Numeric,
        underwriter_id -> Numeric,
        created_at -> Timestamptz,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;
    use super::sql_types::OrderState;

    orders (market_order_id, market_id) {
        market_order_id -> Numeric,
        market_id -> Numeric,
        side -> Side,
        size -> Numeric,
        price -> Numeric,
        user_address -> Varchar,
        custodian_id -> Nullable<Numeric>,
        order_state -> OrderState,
        created_at -> Timestamptz,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::MarketEventType;

    recognized_market_events (market_id) {
        market_id -> Numeric,
        time -> Timestamptz,
        event_type -> MarketEventType,
        lot_size -> Nullable<Numeric>,
        tick_size -> Nullable<Numeric>,
        min_size -> Nullable<Numeric>,
    }
}

diesel::table! {
    recognized_markets (id) {
        id -> Int4,
        market_id -> Numeric,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;

    taker_events (market_order_id, time) {
        market_id -> Numeric,
        side -> Side,
        market_order_id -> Numeric,
        maker -> Varchar,
        custodian_id -> Nullable<Numeric>,
        size -> Numeric,
        price -> Numeric,
        time -> Timestamptz,
    }
}

diesel::joinable!(bars_15m -> markets (market_id));
diesel::joinable!(bars_1h -> markets (market_id));
diesel::joinable!(bars_1m -> markets (market_id));
diesel::joinable!(bars_30m -> markets (market_id));
diesel::joinable!(bars_5m -> markets (market_id));
diesel::joinable!(fills -> markets (market_id));
diesel::joinable!(maker_events -> markets (market_id));
diesel::joinable!(market_registration_events -> markets (market_id));
diesel::joinable!(orders -> markets (market_id));
diesel::joinable!(recognized_markets -> markets (market_id));
diesel::joinable!(taker_events -> markets (market_id));

diesel::allow_tables_to_appear_in_same_query!(
    bars_15m,
    bars_1h,
    bars_1m,
    bars_30m,
    bars_5m,
    coins,
    fills,
    maker_events,
    market_registration_events,
    markets,
    orders,
    recognized_market_events,
    recognized_markets,
    taker_events,
);
