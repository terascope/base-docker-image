#!/bin/bash

set -e

printf '\n* BUILDING node:10.18.1...\n\n'
docker build \
    --build-arg 'NODE_VERSION=10.18.1' \
    --compress \
    --tag terascope/node-base:10.18.1 .

printf '\n* BUILDING node:12.14.1...\n\n'
docker build \
    --build-arg 'NODE_VERSION=12.14.1' \
    --compress \
    --tag terascope/node-base:12.14.1 .
