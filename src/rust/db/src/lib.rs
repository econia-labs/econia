use diesel::associations::HasTable;
use diesel::prelude::*;
use diesel::{Connection, PgConnection};
use models::market::{NewRecognizedMarketEvent, RecognizedMarketEvent};
use models::order::{
    CancelOrderEvent, ChangeOrderSizeEvent, FillEvent, NewCancelOrderEvent,
    NewChangeOrderSizeEvent, NewFillEvent, NewPlaceLimitOrderEvent, NewPlaceMarketOrderEvent,
    NewPlaceSwapOrderEvent, PlaceLimitOrderEvent, PlaceMarketOrderEvent, PlaceSwapOrderEvent,
};
use models::{
    bar::{Bar, NewBar},
    market::{MarketRegistrationEvent, NewMarketRegistrationEvent},
};

use crate::{
    error::DbError,
    models::coin::{Coin, NewCoin},
};

pub mod error;
pub mod models;
pub mod query;
pub mod schema;

pub type Result<T> = std::result::Result<T, DbError>;

pub fn establish_connection(url: &str) -> Result<PgConnection> {
    PgConnection::establish(&url).map_err(DbError::ConnectionError)
}

pub fn add_bar(conn: &mut PgConnection, bar: &NewBar) -> Result<Bar> {
    diesel::insert_into(Bar::table())
        .values(bar)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn create_coin(conn: &mut PgConnection, coin: &NewCoin) -> Result<Coin> {
    diesel::insert_into(Coin::table())
        .values(coin)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_market_registration_event(
    conn: &mut PgConnection,
    event: &NewMarketRegistrationEvent,
) -> Result<MarketRegistrationEvent> {
    if event.base_name_generic.is_some() {
        assert!(event.base_account_address.is_none());
        assert!(event.base_module_name.is_none());
        assert!(event.base_struct_name.is_none());
    }

    diesel::insert_into(MarketRegistrationEvent::table())
        .values(event)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_recognized_market_event(
    conn: &mut PgConnection,
    event: &NewRecognizedMarketEvent,
) -> Result<RecognizedMarketEvent> {
    diesel::insert_into(RecognizedMarketEvent::table())
        .values(event)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_cancel_order_event(
    conn: &mut PgConnection,
    event: &NewCancelOrderEvent,
) -> Result<CancelOrderEvent> {
    diesel::insert_into(CancelOrderEvent::table())
        .values(event)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_change_order_size_event(
    conn: &mut PgConnection,
    event: &NewChangeOrderSizeEvent,
) -> Result<ChangeOrderSizeEvent> {
    diesel::insert_into(ChangeOrderSizeEvent::table())
        .values(event)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_fill_event(conn: &mut PgConnection, event: &NewFillEvent) -> Result<FillEvent> {
    diesel::insert_into(FillEvent::table())
        .values(event)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_place_limit_order_event(
    conn: &mut PgConnection,
    event: &NewPlaceLimitOrderEvent,
) -> Result<PlaceLimitOrderEvent> {
    diesel::insert_into(PlaceLimitOrderEvent::table())
        .values(event)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_place_market_order_event(
    conn: &mut PgConnection,
    event: &NewPlaceMarketOrderEvent,
) -> Result<PlaceMarketOrderEvent> {
    diesel::insert_into(PlaceMarketOrderEvent::table())
        .values(event)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}

pub fn add_place_swap_order_event(
    conn: &mut PgConnection,
    event: &NewPlaceSwapOrderEvent,
) -> Result<PlaceSwapOrderEvent> {
    diesel::insert_into(PlaceSwapOrderEvent::table())
        .values(event)
        .on_conflict_do_nothing()
        .get_result(conn)
        .map_err(DbError::QueryError)
}
