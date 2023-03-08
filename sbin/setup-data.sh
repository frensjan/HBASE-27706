#!/usr/bin/env bash

set -e
source "$(dirname -- "$0")/util.sh"

DROP_TABLE_SCRIPT="$(
  cat <<'EOF'
disable 'ns:tbl'
drop 'ns:tbl'
EOF
)"

DROP_NS_SCRIPT="$(
  cat <<'EOF'
drop_namespace 'ns'
EOF
)"

CREATE_SCRIPT="$(
  cat <<'EOF'
create_namespace 'ns'
create 'ns:tbl', {NAME => 'cf1'}, {NAME => 'cf2', COMPRESSION => 'GZ'}, {NAME => 'cf3', COMPRESSION => 'ZSTD'}, SPLITS => ['a', 'b', 'c']
put 'ns:tbl', 'foo', 'cf1:foo', 'foo'
put 'ns:tbl', 'bar', 'cf2:bar', 'bar'
put 'ns:tbl', 'baz', 'cf1:baz', 'baz'
put 'ns:tbl', 'qux', 'cf3:qux', 'qux'
flush 'ns:tbl'
EOF
)"

echo "Checking if test namespace exists"
if hbase_shell "list_namespace" | grep ns; then
  echo "Dropping ns namespace in order to reset"
  hbase_shell "$DROP_TABLE_SCRIPT" || echo "unable to drop table!"
  hbase_shell "$DROP_NS_SCRIPT"
fi

echo "Creating namespace, table and adding data"
hbase_shell "$CREATE_SCRIPT"
