// @generated automatically by Diesel CLI.

diesel::table! {
    coins (symbol) {
        symbol -> Varchar,
        name -> Text,
        decimals -> Int2,
        address -> Nullable<Text>,
    }
}

diesel::table! {
    orderbooks (id) {
        id -> Numeric,
        base -> Varchar,
        quote -> Varchar,
        lot_size -> Numeric,
        tick_size -> Numeric,
        min_size -> Numeric,
        underwriter_id -> Numeric,
    }
}

diesel::allow_tables_to_appear_in_same_query!(
    coins,
    orderbooks,
);
