#!/bin/bash

target=$(docker images |grep 'python_base' |awk '{print $3}')
if [ "$target" = "" ]; then
  echo "Building docker image python_base:3.6"
  docker build -t python_base:3.6 -f ./Dockerfile.local .
fi
