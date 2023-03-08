#!/usr/bin/env bash

set -e
source "$(dirname -- "$0")/util.sh"

echo "Checking if data is available"
echo ""
hbase_shell "scan 'ns:tbl'" | grep -E 'bar.*cf2:bar.*value=bar|baz.*cf1:baz.*value=baz|foo.*cf1:foo.*value=foo|qux.*cf3:qux.*value=qux'
echo ""
echo "🎉"
