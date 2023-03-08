#!/usr/bin/env bash

set -e
source "$(dirname -- "$0")/util.sh"

echo "Checking gz support"
hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/testfile gz

echo "Checking zstd support"
hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/zstd zstd