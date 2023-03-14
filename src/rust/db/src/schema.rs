// @generated automatically by Diesel CLI.

pub mod sql_types {
    #[derive(diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "market_event_type"))]
    pub struct MarketEventType;
}

diesel::table! {
    coins (id) {
        id -> Int4,
        account_address -> Varchar,
        module_name -> Text,
        struct_name -> Text,
        symbol -> Nullable<Varchar>,
        name -> Nullable<Text>,
        decimals -> Nullable<Int2>,
    }
}

diesel::table! {
    market_registration_events (market_id) {
        market_id -> Numeric,
        time -> Timestamp,
        base_id -> Int4,
        base_name_generic -> Nullable<Text>,
        quote_id -> Int4,
        lot_size -> Numeric,
        tick_size -> Numeric,
        min_size -> Numeric,
    }
}

diesel::table! {
    markets (market_id) {
        market_id -> Numeric,
        base_id -> Int4,
        base_name_generic -> Nullable<Text>,
        quote_id -> Int4,
        lot_size -> Numeric,
        tick_size -> Numeric,
        min_size -> Numeric,
        underwriter_id -> Numeric,
        created_at -> Timestamp,
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

diesel::joinable!(recognized_markets -> markets (market_id));

diesel::allow_tables_to_appear_in_same_query!(
    coins,
    market_registration_events,
    markets,
    recognized_market_events,
    recognized_markets,
);
