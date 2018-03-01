#!/bin/bash

set -e

rm manifest.yml || true
ln -s staging-manifest.yml manifest.yml
cf zero-downtime-push $CF_APP -f manifest.yml
rm manifest.yml
