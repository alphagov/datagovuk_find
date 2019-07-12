#!/bin/bash

set -eu

cf zero-downtime-push $CF_APP -f production-manifest.yml --show-app-log=true
