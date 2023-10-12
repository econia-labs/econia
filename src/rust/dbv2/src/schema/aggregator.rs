// @generated automatically by Diesel CLI.
pub mod sql_types {
    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "order_status"))]
    pub struct OrderStatus;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "order_type"))]
    pub struct OrderType;
}

diesel::table! {
    aggregator.aggregated_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
    }
}

diesel::table! {
    aggregator.competition_exclusion_metadata (user, competition_id) {
        user -> Text,
        reason -> Nullable<Text>,
        competition_id -> Int4,
    }
}

diesel::table! {
    aggregator.competition_indexed_events (txn_version, event_idx, competition_id) {
        txn_version -> Numeric,
        event_idx -> Numeric,
        competition_id -> Int4,
    }
}

diesel::table! {
    aggregator.competition_leaderboard_users (user, competition_id) {
        user -> Text,
        volume -> Numeric,
        integrators_used -> Array<Nullable<Text>>,
        n_trades -> Int4,
        points -> Nullable<Numeric>,
        competition_id -> Int4,
    }
}

diesel::table! {
    aggregator.competition_metadata (id) {
        id -> Int4,
        start -> Timestamptz,
        end -> Timestamptz,
        prize -> Int4,
        market_id -> Numeric,
        integrators_required -> Array<Nullable<Text>>,
    }
}

diesel::table! {
    aggregator.markets_registered_per_day (date) {
        date -> Date,
        markets -> Int8,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::OrderStatus;
    use super::sql_types::OrderType;

    aggregator.user_history (market_id, order_id) {
        market_id -> Numeric,
        order_id -> Numeric,
        created_at -> Timestamptz,
        last_updated_at -> Nullable<Timestamptz>,
        integrator -> Text,
        total_filled -> Numeric,
        remaining_size -> Numeric,
        order_status -> OrderStatus,
        order_type -> OrderType,
    }
}

diesel::table! {
    aggregator.user_history_limit (market_id, order_id) {
        market_id -> Numeric,
        order_id -> Numeric,
        user -> Text,
        custodian_id -> Numeric,
        side -> Bool,
        self_matching_behavior -> Int2,
        restriction -> Int2,
        price -> Numeric,
        last_increase_stamp -> Numeric,
    }
}

diesel::table! {
    aggregator.user_history_market (market_id, order_id) {
        market_id -> Numeric,
        order_id -> Numeric,
        user -> Text,
        custodian_id -> Numeric,
        direction -> Bool,
        self_matching_behavior -> Int2,
    }
}

diesel::table! {
    aggregator.user_history_swap (market_id, order_id) {
        market_id -> Numeric,
        order_id -> Numeric,
        direction -> Bool,
        limit_price -> Numeric,
        signing_account -> Text,
        min_base -> Numeric,
        max_base -> Numeric,
        min_quote -> Numeric,
        max_quote -> Numeric,
    }
}

diesel::joinable!(competition_exclusion_metadata -> competition_metadata (competition_id));
diesel::joinable!(competition_indexed_events -> competition_metadata (competition_id));
diesel::joinable!(competition_leaderboard_users -> competition_metadata (competition_id));

diesel::allow_tables_to_appear_in_same_query!(
    aggregated_events,
    competition_exclusion_metadata,
    competition_indexed_events,
    competition_leaderboard_users,
    competition_metadata,
    markets_registered_per_day,
    user_history,
    user_history_limit,
    user_history_market,
    user_history_swap,
);
