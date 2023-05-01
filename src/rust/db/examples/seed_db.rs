#[path = "../tests/helpers.rs"]
mod helpers;

use chrono::Utc;
use db::{
    create_coin, establish_connection,
    models::{coin::NewCoin, market::NewMarketRegistrationEvent},
    register_market,
};
use helpers::{load_config, reset_tables};

fn main() {
    let config = load_config();
    let conn = &mut establish_connection(config.database_url).unwrap();

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
}
