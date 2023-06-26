use core::panic;
use std::fs::File;
use std::io::{self, BufRead, BufReader, BufWriter, Write, Read};
use clap::{Parser};
use reqwest::blocking::Client;
use std::process::{Command, exit};

const MAINNET_ADDR: &str = "0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c";
const TESTNET_ADDR: &str = "0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135";
const DEVNET_ADDR: &str = "0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74";

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[arg(short, long, value_name = "REDIS_URI")]
    redis: String,

    #[arg(short, long, value_name = "POSTGRES_URI")]
    postgres: String,

    #[arg(short, long, value_name = "NETWORK_NAME")]
    network: String,
}


fn execute_command(args: &[String]) -> () {
    let command = args.get(0).expect("No command provided");
    let args = &args[1..];

    let output = Command::new(command)
        .args(args)
        .output()
        .expect("Failed to execute command");

    if output.status.success() {
        let stdout = String::from_utf8_lossy(&output.stdout);
        println!("Command executed successfully:\n{}", stdout);
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr);
        eprintln!("Command execution failed:\n{}", stderr);
        exit(1);
    }
}


fn download_file(url: &str, file_path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();
    let mut response = client.get(url).send()?;
    if !response.status().is_success() {
        return Err(format!("Request failed with status: {}", response.status()).into());
    }
    let mut file = File::create(file_path)?;
    let mut content = vec![];
    match response.read_to_end(&mut content) {
        Err(_) => panic!("Failed to read remote file"),
        _ => {},
    }
    file.write_all(&content)?;

    Ok(())
}

fn download_waypoint_file(network: &str) -> Result<(), Box<dyn std::error::Error>>  {
    match network {
        "main" => download_file(
            "https://github.com/aptos-labs/aptos-networks/raw/main/mainnet/waypoint.txt", 
            "./waypoint.txt", 
        ),
        "test" => download_file(
            "https://github.com/aptos-labs/aptos-networks/raw/main/testnet/waypoint.txt", 
            "./waypoint.txt", 
        ),
        "dev" => download_file(
            "https://github.com/aptos-labs/aptos-networks/raw/main/devnet/waypoint.txt", 
            "./waypoint.txt", 
        ),
        _ => panic!("Expected `main`, `test`, or `dev` as a --network name"),
    }
}

fn download_genesis_file(network: &str) -> Result<(), Box<dyn std::error::Error>>  {
    match network {
        "main" => download_file(
            "https://github.com/aptos-labs/aptos-networks/raw/main/mainnet/genesis.blob", 
            "./genesis.blob", 
        ),
        "test" => download_file(
            "https://github.com/aptos-labs/aptos-networks/raw/main/testnet/genesis.blob", 
            "./genesis.blob",  
        ),
        "dev" => download_file(
            "https://github.com/aptos-labs/aptos-networks/raw/main/devnet/genesis.blob", 
            "./genesis.blob",
        ),
        _ => panic!("Expected `main`, `test`, or `dev` as a --network name"),
    }
}

fn replace_string_in_file(
    input_path: &str,
    output_path: &str,
    search_str: &str,
    replace_str: &str,
) -> io::Result<()> {
    let input_file = File::open(input_path)?;
    let reader = BufReader::new(input_file);
    
    let output_file = File::create(output_path)?;
    let mut writer = BufWriter::new(output_file);

    for line in reader.lines() {
        let line = line?;
        let modified_line = line.replace(search_str, replace_str);
        writer.write_all(modified_line.as_bytes())?;
        writer.write_all(b"\n")?;
    }
    Ok(())
}

fn replace_address_in_file(network: &str) -> io::Result<()> {
    match network {
        "main" => replace_string_in_file(
            "./econia_config.template", 
            "./econia_config.json", 
            "$ECONIA_ADDR", 
            &MAINNET_ADDR,
        ),
        "test" => replace_string_in_file(
            "./econia_config.template", 
            "./econia_config.json", 
            "$ECONIA_ADDR", 
            &TESTNET_ADDR,
        ),
        "dev" => replace_string_in_file(
            "./econia_config.template", 
            "./econia_config.json", 
            "$ECONIA_ADDR", 
            &DEVNET_ADDR,
        ),
        _ => panic!("Expected `main`, `test`, or `dev` as a --network name"),
    }
}

fn main() {
    let cli = Cli::parse();
    let e = download_genesis_file(&cli.network);
    match e {
        Err(_) => panic!("failed to get genesis file"),
        _ => {},
    }

    let e2 = download_waypoint_file(&cli.network);
    match e2 {
        Err(_) => panic!("failed to get waypoint file"),
        _ => {},
    }
    let _ = replace_address_in_file(&cli.network);
    let econia_config_path = "./econia_config.json";
    let _ = replace_string_in_file(
        "./econia_config.template", 
        econia_config_path, 
        "$REDIS_URI", 
        &cli.redis,
    );
    std::env::set_var("ECONIA_CONFIG_PATH", econia_config_path);
    let _ = replace_string_in_file(
        "./fullnode_config.template", 
        "./fullnode.yaml",
        "$POSTGRES_URI",
        &cli.postgres,
    );
    execute_command(&[
        "./aptos-node".to_string(),
        "-f".to_string(),
        "./fullnode.yaml".to_string()
    ]);
    
}
