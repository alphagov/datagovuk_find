#!/bin/bash

set -eu

if [[ $(docker images | grep ^datagovuk_find) ]]; then
    docker build -t dev.datagovuk_find -f docker/dev.Dockerfile .
  else
    docker build -t datagovuk_find -f docker/Dockerfile .
    docker build -t dev.datagovuk_find -f docker/dev.Dockerfile .
fi