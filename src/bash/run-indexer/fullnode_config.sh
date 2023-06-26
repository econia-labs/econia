#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Please provide the replacement string as the first argument."
    exit 1
fi

replacement="$1"
file="fullnode_config.template"

if [ ! -f "$file" ]; then
    echo "The file '$file' does not exist."
    exit 1
fi

awk -v replace="$replacement" '{gsub("POSTGRES_URI", replace)} 1' "$file" > fullnode.yaml