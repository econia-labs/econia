#[path = "../tests/helpers.rs"]
mod helpers;

use bigdecimal::{BigDecimal, FromPrimitive};
use chrono::{DateTime, Duration, TimeZone, Utc};
use db::{
    add_maker_event, add_taker_event, create_coin, establish_connection,
    models::{
        bar::{Bar, NewBar},
        coin::NewCoin,
        events::{MakerEventType, NewMakerEvent, NewTakerEvent},
        market::NewMarketRegistrationEvent,
        order::Side,
    },
    register_market,
};
use diesel::{prelude::*, PgConnection};
use helpers::{load_config, reset_tables};
use indicatif::ProgressBar;
use rand::{rngs::ThreadRng, Rng};

fn place_random_orders(
    conn: &mut PgConnection,
    market_id: u64,
    side: Side,
    init_price: u64,
    num_orders: u64,
    rng: &mut ThreadRng,
) {
    let market_id_bd = &BigDecimal::from_u64(market_id).unwrap();
    let mut price = init_price;

    for i in 0..num_orders {
        let id = if side == Side::Bid {
            market_id * 1000 + i
        } else {
            market_id * 1000 + 100 + i
        };
        price = if side == Side::Bid {
            price - rng.gen_range(0..1000)
        } else {
            price + rng.gen_range(0..1000)
        };
        let size = rng.gen_range(10000..100000);

        add_maker_event(
            conn,
            &NewMakerEvent {
                market_id: market_id_bd,
                side,
                market_order_id: &id.into(),
                user_address: "0x123",
                custodian_id: None,
                event_type: MakerEventType::Place,
                size: &BigDecimal::from_u64(size).unwrap(),
                price: &BigDecimal::from_u64(price).unwrap(),
                time: Utc::now(),
            },
        )
        .unwrap();

        add_taker_event(
            conn,
            &NewTakerEvent {
                market_id: market_id_bd,
                side,
                market_order_id: &id.into(),
                maker: "0x123",
                custodian_id: None,
                size: &BigDecimal::from_u64(size >> 2).unwrap(),
                price: &BigDecimal::from_u64(price).unwrap(),
                time: Utc::now(),
            },
        )
        .unwrap();
    }
}

fn add_random_bars(
    conn: &mut PgConnection,
    market_id: u64,
    end_date: DateTime<Utc>,
    num_bars: u64,
    rng: &mut ThreadRng,
) {
    let market_id_bd = BigDecimal::from_u64(market_id).unwrap();

    let end_date = Utc
        .timestamp_opt((end_date.timestamp() / 60) * 60, 0)
        .unwrap();

    // println!(
    //     "start time: {}",
    //     (end_date - Duration::minutes(num_bars as i64)).timestamp()
    // );
    // println!("end time: {}", end_date.timestamp());

    let mut price = 10000;
    let mut bars = vec![];

    let pb = ProgressBar::new(num_bars);
    for i in 0..num_bars {
        let start_time = end_date - Duration::minutes((num_bars - i) as i64);
        let mut fill_prices = vec![];

        for _ in 0..10 {
            price = price - rng.gen_range(-100..100);
            if price < 0 {
                price = 0
            }
            fill_prices.push(price);
        }

        let open = *fill_prices.first().unwrap();
        let close = *fill_prices.last().unwrap();
        let low = *fill_prices.iter().min().unwrap();
        let high = *fill_prices.iter().max().unwrap();

        bars.push(NewBar {
            market_id: market_id_bd.clone(),
            start_time,
            open: BigDecimal::from(open),
            high: BigDecimal::from(high),
            low: BigDecimal::from(low),
            close: BigDecimal::from(close),
            volume: BigDecimal::from(rng.gen_range(1..10000)),
        });

        if (i + 1) % 400 == 0 {
            let _: Vec<Bar> = diesel::insert_into(db::schema::bars_1m::table)
                .values(&bars)
                .get_results(conn)
                .unwrap();
            bars = vec![];
        }

        pb.inc(1);
    }
    let _: Vec<Bar> = diesel::insert_into(db::schema::bars_1m::table)
        .values(&bars)
        .get_results(conn)
        .unwrap();
}

fn main() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

    let mut rng = rand::thread_rng();

    // Delete all entries in the tables used before running tests.
    reset_tables(conn);

    let aptos_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x1",
            module_name: "aptos_coin",
            struct_name: "AptosCoin",
            symbol: "APT",
            name: "Aptos Coin",
            decimals: 8,
        },
    )
    .unwrap();

    let tusdc_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
            module_name: "test_usdc",
            struct_name: "TestUSDCoin",
            symbol: "tUSDC",
            name: "Test USDC",
            decimals: 6,
        },
    )
    .unwrap();

    let teth_coin = create_coin(
        conn,
        &NewCoin {
            account_address: "0x7c36a610d1cde8853a692c057e7bd2479ba9d5eeaeceafa24f125c23d2abf942",
            module_name: "test_eth",
            struct_name: "TestETHCoin",
            symbol: "tETH",
            name: "Test ETH",
            decimals: 6,
        },
    )
    .unwrap();

    // APT-tUSDC market
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: &0.into(),
            time: Utc::now(),
            base_account_address: Some(&aptos_coin.account_address),
            base_module_name: Some(&aptos_coin.module_name),
            base_struct_name: Some(&aptos_coin.struct_name),
            base_name_generic: None,
            quote_account_address: &tusdc_coin.account_address,
            quote_module_name: &tusdc_coin.module_name,
            quote_struct_name: &tusdc_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap();

    // tETH-tUSDC market
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: &1.into(),
            time: Utc::now(),
            base_account_address: Some(&teth_coin.account_address),
            base_module_name: Some(&teth_coin.module_name),
            base_struct_name: Some(&teth_coin.struct_name),
            base_name_generic: None,
            quote_account_address: &tusdc_coin.account_address,
            quote_module_name: &tusdc_coin.module_name,
            quote_struct_name: &tusdc_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap();

    // APT-tETH market
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: &2.into(),
            time: Utc::now(),
            base_account_address: Some(&aptos_coin.account_address),
            base_module_name: Some(&aptos_coin.module_name),
            base_struct_name: Some(&aptos_coin.struct_name),
            base_name_generic: None,
            quote_account_address: &teth_coin.account_address,
            quote_module_name: &teth_coin.module_name,
            quote_struct_name: &teth_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap();

    // APT-PERP market
    register_market(
        conn,
        &NewMarketRegistrationEvent {
            market_id: &3.into(),
            time: Utc::now(),
            base_account_address: None,
            base_module_name: None,
            base_struct_name: None,
            base_name_generic: Some("APT-PERP"),
            quote_account_address: &tusdc_coin.account_address,
            quote_module_name: &tusdc_coin.module_name,
            quote_struct_name: &tusdc_coin.struct_name,
            lot_size: &1000.into(),
            tick_size: &1000.into(),
            min_size: &1000.into(),
            underwriter_id: &0.into(),
        },
    )
    .unwrap();

    let now = Utc::now() + Duration::days(7);
    for market_id in 0..4 {
        println!(
            "Initializing entries for market with market_id {}",
            market_id + 1
        );

        place_random_orders(conn, market_id, Side::Bid, 100_000, 20, &mut rng);
        place_random_orders(conn, market_id, Side::Ask, 100_000, 20, &mut rng);

        add_random_bars(conn, market_id, now, 14 * 24 * 60, &mut rng);
    }
}
