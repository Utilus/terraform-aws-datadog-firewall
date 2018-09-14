#!/usr/bin/env bash

URL=$1
KEY=$2
LIMIT=$3

curl "${URL}/${KEY}.json" | jq \
                --arg values_key "${KEY}" \
                '.[$values_key] .prefixes_ipv4 | map(gsub("[0-9]+.[0-9]+.[0-9]+/32"; "0.0.0/8")) | unique | { ips: join(",") }'
