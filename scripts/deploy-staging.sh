#!/bin/bash

set -eu

cf zero-downtime-push $CF_APP -f staging-manifest.yml --show-app-log=true
