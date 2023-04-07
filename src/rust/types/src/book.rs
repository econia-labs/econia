use std::collections::{BTreeMap, HashMap};

use crate::order::{Order, Side};

pub struct OrderBook {
    asks: BTreeMap<u64, Vec<Order>>,
    bids: BTreeMap<u64, Vec<Order>>,
    orders_to_price_level: HashMap<u64, (Side, u64)>,
}

impl OrderBook {
    pub fn new() -> Self {
        Self {
            asks: BTreeMap::new(),
            bids: BTreeMap::new(),
            orders_to_price_level: HashMap::new(),
        }
    }

    pub fn get_side(&self, side: Side) -> &BTreeMap<u64, Vec<Order>> {
        match side {
            Side::Ask => &self.asks,
            Side::Bid => &self.bids,
        }
    }

    pub fn get_side_mut(&mut self, side: Side) -> &mut BTreeMap<u64, Vec<Order>> {
        match side {
            Side::Ask => &mut self.asks,
            Side::Bid => &mut self.bids,
        }
    }

    pub fn get_book_side_price_level(&self, order_id: u64) -> (Side, u64) {
        let (side, price) = self
            .orders_to_price_level
            .get(&order_id)
            .expect("invalid state, order is missing");
        (*side, *price)
    }

    pub fn get_order(&self, order_id: u64) -> &Order {
        let (side, price) = self.get_book_side_price_level(order_id);
        let book_side = self.get_side(side);
        let orders = book_side
            .get(&price)
            .expect("invalid state, price level is missing");
        let order = orders
            .iter()
            .find(|o| o.market_order_id == order_id)
            .expect("invalid state, order is missing");
        order
    }

    pub fn get_order_mut(&mut self, order_id: u64) -> &mut Order {
        let (side, price) = self.get_book_side_price_level(order_id);
        let book_side = self.get_side_mut(side);
        let orders = book_side
            .get_mut(&price)
            .expect("invalid state, price level is missing");
        let order = orders
            .iter_mut()
            .find(|o| o.market_order_id == order_id)
            .expect("invalid state, order is missing");
        order
    }

    pub fn add_order(&mut self, order: Order) {
        let market_order_id = order.market_order_id;
        let side = order.side;
        let price = order.price;

        if side == Side::Ask {
            self.asks.entry(price).or_default().push(order);
        } else {
            self.bids.entry(price).or_default().push(order);
        }

        self.orders_to_price_level
            .insert(market_order_id, (side, price));
    }

    pub fn remove_order(&mut self, order_id: u64) -> Order {
        self.orders_to_price_level.remove(&order_id);
        let (side, price) = self.get_book_side_price_level(order_id);
        let book_side = self.get_side_mut(side);
        let level = book_side
            .get_mut(&price)
            .expect("invalid state, price level missing");

        let order = level
            .iter()
            .position(|o| o.market_order_id == order_id)
            .map(|i| level.remove(i))
            .expect("invalid state, order missing");

        if level.is_empty() {
            book_side.remove(&price);
        }

        order
    }
}

