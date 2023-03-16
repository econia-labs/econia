// @generated automatically by Diesel CLI.

pub mod sql_types {
    #[derive(diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "maker_event_type"))]
    pub struct MakerEventType;

    #[derive(diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "market_event_type"))]
    pub struct MarketEventType;

    #[derive(diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "side"))]
    pub struct Side;
}

diesel::table! {
    assets (account_address, module_name, struct_name) {
        account_address -> Varchar,
        module_name -> Text,
        struct_name -> Text,
        symbol -> Nullable<Varchar>,
        name -> Nullable<Text>,
        decimals -> Nullable<Int2>,
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
        base_account_address -> Varchar,
        base_module_name -> Text,
        base_struct_name -> Text,
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
        base_account_address -> Varchar,
        base_module_name -> Text,
        base_struct_name -> Text,
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

    orders (market_order_id) {
        market_order_id -> Numeric,
        market_id -> Numeric,
        side -> Side,
        size -> Numeric,
        price -> Numeric,
        user_address -> Varchar,
        custodian_id -> Nullable<Numeric>,
        created_at -> Timestamptz,
        order_access_key -> Numeric,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::MarketEventType;

    recognized_market_events (market_id) {
        market_id -> Numeric,
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

diesel::joinable!(maker_events -> markets (market_id));
diesel::joinable!(maker_events -> orders (market_order_id));
diesel::joinable!(market_registration_events -> markets (market_id));
diesel::joinable!(orders -> markets (market_id));
diesel::joinable!(recognized_markets -> markets (market_id));
diesel::joinable!(taker_events -> markets (market_id));
diesel::joinable!(taker_events -> orders (market_order_id));

diesel::allow_tables_to_appear_in_same_query!(
    assets,
    maker_events,
    market_registration_events,
    markets,
    orders,
    recognized_market_events,
    recognized_markets,
    taker_events,
);
