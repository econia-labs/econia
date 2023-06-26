#!/bin/bash

#!/bin/bash

# Function to display script usage
function display_usage {
    echo "Usage: $0 -network <main|test|dev> -postgres <postgres_string> -redis <redis_string>"
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --network)
            network="$2"
            shift
            shift
            ;;
        --postgres)
            postgres="$2"
            shift
            shift
            ;;
        --redis)
            redis="$2"
            shift
            shift
            ;;
        *)
            display_usage
            ;;
    esac
done

# Validate and process the arguments
if [[ -z $network || -z $postgres || -z $redis ]]; then
    display_usage
fi

# Rest of your script logic
echo "Network: $network"
echo "Postgres: $postgres"
echo "Redis: $redis"

./genesis.sh $network;
./waypoint.sh $network;
./econia_config_address.sh $network;
./fullnode_config.sh $postgres;
./econia_config_redis.sh $redis;
