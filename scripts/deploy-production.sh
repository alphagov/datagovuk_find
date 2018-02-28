#!/bin/bash

set -e

cf zero-downtime-push $CF_APP -f production-manifest.yml --show-app-log=true
