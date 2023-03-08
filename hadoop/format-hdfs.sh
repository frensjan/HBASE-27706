#!/usr/bin/env bash

if ! [[ -d "/hadoop/dfs/name" ]]; then
  echo "Formatting HDFS"
  hdfs namenode -format
fi
