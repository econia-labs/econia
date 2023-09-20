// @generated automatically by Diesel CLI.

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
        trade_sequence_number -> Numeric,
        size -> Numeric,
        #[max_length = 70]
        taker_address -> Varchar,
        taker_custodian_id -> Numeric,
        taker_order_id -> Numeric,
        taker_quote_fees_paid -> Numeric,
    }
}

diesel::table! {
    place_limit_order_events (txn_version, event_idx) {
        txn_version -> Numeric,
        event_idx -> Numeric,
        time -> Timestamptz,
        market_id -> Numeric,
        #[max_length = 70]
        maker_address -> Varchar,
        maker_custodian_id -> Numeric,
        maker_order_id -> Numeric,
        maker_side -> Bool,
        integrator_address -> Varchar,
        initial_size -> Numeric,
        price -> Numeric,
        restriction -> Numeric,
        self_match_behavior -> Numeric,
        posted_size -> Numeric,
    }
}