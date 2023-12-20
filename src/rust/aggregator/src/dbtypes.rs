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

impl OrderDirection {
    pub fn from_bool_type(direction: bool, order_type: OrderType) -> Self {
        if direction {
            match order_type {
                OrderType::Limit => OrderDirection::Ask,
                OrderType::Market => OrderDirection::Sell,
                OrderType::Swap => OrderDirection::Sell,
            }
        } else {
            match order_type {
                OrderType::Limit => OrderDirection::Bid,
                OrderType::Market => OrderDirection::Buy,
                OrderType::Swap => OrderDirection::Buy,
            }
        }
    }
}
