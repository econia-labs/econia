// @generated automatically by Diesel CLI.

diesel::table! {
    balance_updates_by_handle (txn_version, handle, market_id, custodian_id) {
        txn_version -> Numeric,
        #[max_length = 70]
        handle -> Varchar,
        market_id -> Numeric,
        custodian_id -> Numeric,
        time -> Timestamptz,
        base_total -> Numeric,
        base_available -> Numeric,
        base_ceiling -> Numeric,
        quote_total -> Numeric,
        quote_available -> Numeric,
        quote_ceiling -> Numeric,
    }
}

diesel::table! {
    cancel_order_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
        time -> Timestamptz,
        market_id -> Numeric,
        #[max_length = 70]
        user -> Varchar,
        custodian_id -> Numeric,
        order_id -> Numeric,
        reason -> Int2,
    }
}

diesel::table! {
    change_order_size_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
        market_id -> Numeric,
        time -> Timestamptz,
        order_id -> Numeric,
        #[max_length = 70]
        user -> Varchar,
        custodian_id -> Numeric,
        side -> Bool,
        new_size -> Numeric,
    }
}

diesel::table! {
    fill_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
        #[max_length = 70]
        emit_address -> Varchar,
        time -> Timestamptz,
        #[max_length = 70]
        maker_address -> Varchar,
        maker_custodian_id -> Numeric,
        maker_order_id -> Numeric,
        maker_side -> Bool,
        market_id -> Numeric,
        price -> Numeric,
        sequence_number_for_trade -> Numeric,
        size -> Numeric,
        #[max_length = 70]
        taker_address -> Varchar,
        taker_custodian_id -> Numeric,
        taker_order_id -> Numeric,
        taker_quote_fees_paid -> Numeric,
    }
}

diesel::table! {
    grafana_annotations (title, tag) {
        time -> Timestamptz,
        timeEnd -> Nullable<Timestamptz>,
        title -> Text,
        text -> Nullable<Text>,
        tag -> Text,
    }
}

diesel::table! {
    ledger_infos (chain_id) {
        chain_id -> Int8,
    }
}

diesel::table! {
    market_account_handles (user) {
        #[max_length = 70]
        user -> Varchar,
        #[max_length = 70]
        handle -> Varchar,
        creation_time -> Timestamptz,
    }
}

diesel::table! {
    market_registration_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
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
    place_limit_order_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
        time -> Timestamptz,
        market_id -> Numeric,
        #[max_length = 70]
        user -> Varchar,
        custodian_id -> Numeric,
        order_id -> Numeric,
        side -> Bool,
        #[max_length = 70]
        integrator -> Varchar,
        initial_size -> Numeric,
        price -> Numeric,
        restriction -> Int2,
        self_match_behavior -> Int2,
        size -> Numeric,
    }
}

diesel::table! {
    place_market_order_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
        market_id -> Numeric,
        time -> Timestamptz,
        order_id -> Numeric,
        #[max_length = 70]
        user -> Varchar,
        custodian_id -> Numeric,
        #[max_length = 70]
        integrator -> Varchar,
        direction -> Bool,
        size -> Numeric,
        self_match_behavior -> Int2,
    }
}

diesel::table! {
    place_swap_order_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
        market_id -> Numeric,
        time -> Timestamptz,
        order_id -> Numeric,
        #[max_length = 70]
        signing_account -> Varchar,
        #[max_length = 70]
        integrator -> Varchar,
        direction -> Bool,
        min_base -> Numeric,
        max_base -> Numeric,
        min_quote -> Numeric,
        max_quote -> Numeric,
        limit_price -> Numeric,
    }
}

diesel::table! {
    processor_status (processor) {
        #[max_length = 50]
        processor -> Varchar,
        last_success_version -> Int8,
        last_updated -> Timestamp,
    }
}

diesel::table! {
    recognized_market_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
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
        market_id -> Nullable<Numeric>,
        lot_size -> Nullable<Numeric>,
        tick_size -> Nullable<Numeric>,
        min_size -> Nullable<Numeric>,
        underwriter_id -> Nullable<Numeric>,
    }
}

diesel::allow_tables_to_appear_in_same_query!(
    balance_updates_by_handle,
    cancel_order_events,
    change_order_size_events,
    fill_events,
    grafana_annotations,
    ledger_infos,
    market_account_handles,
    market_registration_events,
    place_limit_order_events,
    place_market_order_events,
    place_swap_order_events,
    processor_status,
    recognized_market_events,
);
