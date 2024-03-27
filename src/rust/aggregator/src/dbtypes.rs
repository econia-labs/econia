#[derive(sqlx::Type, Debug)]
#[sqlx(type_name = "order_direction", rename_all = "lowercase")]
pub enum OrderDirection {
    Ask,
    Bid,
    Sell,
    Buy,
}

#[derive(sqlx::Type, Debug)]
#[sqlx(type_name = "order_status", rename_all = "lowercase")]
pub enum OrderStatus {
    Open,
    Closed,
    Cancelled,
}

#[derive(sqlx::Type, Debug)]
#[sqlx(type_name = "order_type", rename_all = "lowercase")]
pub enum OrderType {
    Limit,
    Market,
    Swap,
}
