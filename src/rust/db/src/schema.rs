// @generated automatically by Diesel CLI.

pub mod sql_types {
    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "cancel_reason"))]
    pub struct CancelReason;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "market_event_type"))]
    pub struct MarketEventType;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "order_state"))]
    pub struct OrderState;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "restriction"))]
    pub struct Restriction;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "self_match_behavior"))]
    pub struct SelfMatchBehavior;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
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
    use diesel::sql_types::*;
    use super::sql_types::CancelReason;

    cancel_order_events (market_id, order_id) {
        market_id -> Numeric,
        order_id -> Numeric,
        #[max_length = 70]
        user_address -> Varchar,
        custodian_id -> Nullable<Numeric>,
        reason -> CancelReason,
        time -> Timestamptz,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;

    change_order_size_events (market_id, order_id) {
        market_id -> Numeric,
        order_id -> Numeric,
        #[max_length = 70]
        user_address -> Varchar,
        custodian_id -> Nullable<Numeric>,
        side -> Side,
        new_size -> Numeric,
        time -> Timestamptz,
    }
}

diesel::table! {
    coins (account_address, module_name, struct_name) {
        #[max_length = 70]
        account_address -> Varchar,
        module_name -> Text,
        struct_name -> Text,
        #[max_length = 10]
        symbol -> Varchar,
        name -> Text,
        decimals -> Int2,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;

    fill_events (market_id, maker_order_id, taker_order_id) {
        market_id -> Numeric,
        size -> Numeric,
        price -> Numeric,
        maker_side -> Side,
        #[max_length = 70]
        maker -> Varchar,
        maker_custodian_id -> Nullable<Numeric>,
        maker_order_id -> Numeric,
        #[max_length = 70]
        taker -> Varchar,
        taker_custodian_id -> Nullable<Numeric>,
        taker_order_id -> Numeric,
        taker_quote_fees_paid -> Numeric,
        sequence_number_for_trade -> Numeric,
        time -> Timestamptz,
    }
}

diesel::table! {
    market_registration_events (market_id) {
        market_id -> Numeric,
        time -> Timestamptz,
        #[max_length = 70]
        base_account_address -> Nullable<Varchar>,
        base_module_name -> Nullable<Text>,
        base_struct_name -> Nullable<Text>,
        base_name_generic -> Nullable<Text>,
        #[max_length = 70]
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
        #[max_length = 70]
        base_account_address -> Nullable<Varchar>,
        base_module_name -> Nullable<Text>,
        base_struct_name -> Nullable<Text>,
        base_name_generic -> Nullable<Text>,
        #[max_length = 70]
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

    orders (order_id, market_id) {
        order_id -> Numeric,
        market_id -> Numeric,
        side -> Side,
        size -> Numeric,
        remaining_size -> Numeric,
        price -> Numeric,
        #[max_length = 70]
        user_address -> Varchar,
        custodian_id -> Nullable<Numeric>,
        order_state -> OrderState,
        created_at -> Timestamptz,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;
    use super::sql_types::Restriction;
    use super::sql_types::SelfMatchBehavior;

    place_limit_order_events (market_id, order_id) {
        market_id -> Numeric,
        #[max_length = 70]
        user_address -> Varchar,
        custodian_id -> Nullable<Numeric>,
        #[max_length = 70]
        integrator -> Nullable<Varchar>,
        side -> Side,
        size -> Numeric,
        price -> Numeric,
        restriction -> Restriction,
        self_match_behavior -> SelfMatchBehavior,
        remaining_size -> Numeric,
        order_id -> Numeric,
        time -> Timestamptz,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;
    use super::sql_types::SelfMatchBehavior;

    place_market_order_events (market_id, order_id) {
        market_id -> Numeric,
        #[max_length = 70]
        user_address -> Varchar,
        custodian_id -> Nullable<Numeric>,
        #[max_length = 70]
        integrator -> Nullable<Varchar>,
        direction -> Side,
        size -> Numeric,
        self_match_behavior -> SelfMatchBehavior,
        order_id -> Numeric,
        time -> Timestamptz,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Side;

    place_swap_order_events (market_id, order_id) {
        market_id -> Numeric,
        #[max_length = 70]
        signing_account -> Varchar,
        #[max_length = 70]
        integrator -> Nullable<Varchar>,
        direction -> Side,
        min_base -> Numeric,
        max_base -> Numeric,
        min_quote -> Numeric,
        max_quote -> Numeric,
        limit_price -> Numeric,
        order_id -> Numeric,
        time -> Timestamptz,
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

diesel::joinable!(bars_15m -> markets (market_id));
diesel::joinable!(bars_1h -> markets (market_id));
diesel::joinable!(bars_1m -> markets (market_id));
diesel::joinable!(bars_30m -> markets (market_id));
diesel::joinable!(bars_5m -> markets (market_id));
diesel::joinable!(cancel_order_events -> markets (market_id));
diesel::joinable!(change_order_size_events -> markets (market_id));
diesel::joinable!(fill_events -> markets (market_id));
diesel::joinable!(market_registration_events -> markets (market_id));
diesel::joinable!(orders -> markets (market_id));
diesel::joinable!(place_limit_order_events -> markets (market_id));
diesel::joinable!(place_market_order_events -> markets (market_id));
diesel::joinable!(place_swap_order_events -> markets (market_id));
diesel::joinable!(recognized_markets -> markets (market_id));

diesel::allow_tables_to_appear_in_same_query!(
    bars_15m,
    bars_1h,
    bars_1m,
    bars_30m,
    bars_5m,
    cancel_order_events,
    change_order_size_events,
    coins,
    fill_events,
    market_registration_events,
    markets,
    orders,
    place_limit_order_events,
    place_market_order_events,
    place_swap_order_events,
    recognized_market_events,
    recognized_markets,
);
