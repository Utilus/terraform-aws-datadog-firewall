#!/usr/bin/env bash

URL=$1
KEY=$2
LIMIT=$3

curl "${URL}/${KEY}.json" | jq \
            --arg values_key "${KEY}" \
            --argjson array_limit "${LIMIT}" \
            '.[$values_key] .prefixes_ipv4 | [ limit($array_limit; .[]) ] | { ips: join(",") }'
