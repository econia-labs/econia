// @generated automatically by Diesel CLI.

diesel::table! {
    coins (symbol) {
        symbol -> Varchar,
        name -> Text,
        decimals -> Int2,
        address -> Text,
    }
}

diesel::table! {
    orderbooks (id) {
        id -> Int4,
        base -> Varchar,
        quote -> Varchar,
        lot_size -> Int4,
        tick_size -> Int4,
        min_size -> Int4,
        underwriter_id -> Int4,
    }
}

diesel::allow_tables_to_appear_in_same_query!(
    coins,
    orderbooks,
);
