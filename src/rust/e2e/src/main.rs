use std::{collections::HashMap, future::Future, pin::Pin};

use anyhow::Result;
use clap::Parser;
use colored::Colorize;
use futures::{stream::FuturesUnordered, StreamExt};
use indicatif::ProgressStyle;
use market_registration::test_market_registration;
use metadata::Metadata;
use utils::{init, Args, State};

mod market_registration;
mod utils;

fn message(success: bool, name: &str) -> String {
    let status = if success { "OK".green() } else { "FAIL".red() };
    let name = if name.len() > 20 {
        format!("{}...", &name[..17])
    } else {
        name.to_string()
    };
    format!("{name}: {status}")
}

async fn run_tests(state: State) -> Result<()> {
    let mut successes: HashMap<String, Vec<String>> = HashMap::new();
    let mut fails: HashMap<String, Vec<(String, anyhow::Error)>> = HashMap::new();
    {
        let mut v: FuturesUnordered<Pin<Box<dyn Future<Output = Metadata<Result<()>>>>>> =
            FuturesUnordered::new();
        v.push(Box::pin(test_market_registration(&state)));

        let i = indicatif::ProgressBar::new(v.len() as u64);
        i.set_style(
            ProgressStyle::with_template(
                "[{elapsed_precise:.green}] {wide_bar:.blue/blue} {pos}/{len} {msg:<26}",
            )
            .unwrap()
            .progress_chars("#>-"),
        );
        while let Some(result) = v.next().await {
            let (namespace, name, result) = result.decompose();
            i.set_message(message(result.is_ok(), &name));
            if result.is_ok() {
                successes
                    .entry(namespace)
                    .and_modify(|v| v.push(name.to_string()))
                    .or_insert(vec![name.to_string()]);
            } else {
                if !fails.contains_key(&namespace) {
                    fails.insert(namespace.clone(), vec![]);
                }
                fails
                    .entry(namespace)
                    .and_modify(|v| v.push((name.to_string(), result.err().unwrap())));
            }
            i.inc(1);
        }
        i.finish();
    }

    println!("Successes:");
    successes.iter().for_each(|(namespace, v)| {
        println!("-> {namespace}");
        v.iter().for_each(|name| println!("  -> {}", name.green()))
    });

    println!("Fails:");
    fails.iter().for_each(|(namespace, v)| {
        println!("-> {namespace}");
        v.iter()
            .for_each(|(name, err)| println!("  -> {} (error: {:?})", name.red(), err))
    });

    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();
    let state = init(&args).await;

    run_tests(state).await
}
