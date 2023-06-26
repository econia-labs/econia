#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Please provide the replacement string as the first argument."
    exit 1
fi

addr=""

if [ "$1" == "dev" ]; then
    addr="0xc0de0000fe693e08f668613c502360dc48508197401d2ac1ae79571498cd8b74"
elif [ "$1" == "test" ]; then
    addr="0x40b119411c6a975fca28f1ba5800a8a418bba1e16a3f13b1de92f731e023d135"
elif [ "$1" == "main" ]; then
    addr="0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c"
else
    echo "Invalid environment specified: $1. Please provide 'dev', 'test', or 'main' as the first argument."
    exit 1
fi

replacement="$addr"
file="econia_config.template"

if [ ! -f "$file" ]; then
    echo "The file '$file' does not exist."
    exit 1
fi

awk -v replace="$replacement" '{gsub("ECONIA_ADDRESS", replace)} 1' "$file" > econia_config.json