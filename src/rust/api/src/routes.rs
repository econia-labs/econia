use axum::{extract::State, Json};
use sqlx::{Pool, Postgres};

pub async fn index() -> String {
    String::from("Econia backend API")
}

pub async fn markets(State(pool): State<Pool<Postgres>>) -> Json<Vec<types::Market>> {
    let query_markets = sqlx::query_as!(
        types::QueryMarket,
        r#"
        select 
            market_id,
            base_coins.symbol as base_symbol,
            base_coins.name as base_name,
            base_coins.decimals as base_decimals,
            base_coins.account_address as base_account_address,
            base_coins.module_name as base_module_name,
            base_coins.struct_name as base_struct_name,
            quote_coins.symbol as quote_symbol,
            quote_coins.name as quote_name,
            quote_coins.decimals as quote_decimals,
            quote_coins.account_address as quote_account_address,
            quote_coins.module_name as quote_module_name,
            quote_coins.struct_name as quote_struct_name,
            base_name_generic,
            lot_size,
            tick_size,
            min_size,
            underwriter_id,
            created_at
        from markets
            join coins base_coins on markets.base_id = base_coins.id
            join coins quote_coins on markets.quote_id = quote_coins.id
        "#
    )
    .fetch_all(&pool)
    .await
    .unwrap();

    let mut markets: Vec<types::Market> = vec![];
    let mut iter = query_markets.into_iter();

    while let Some(query_market) = iter.next() {
        let res: types::Market = query_market.try_into().unwrap();
        markets.push(res);
    }

    tracing::info!("{:?}", markets);

    Json(markets)
}
