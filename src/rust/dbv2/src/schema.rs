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
