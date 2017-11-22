#!/bin/bash

rm manifest.yml || true
ln -s staging-app-manifest.yml manifest.yml
cf bgd publish-data-beta-staging staging-app-manifest.yml

rm manifest.yml
ln -s staging-worker-manifest.yml manifest.yml
cf bgd publish-data-beta-staging-worker staging-worker-manifest.yml

rm manifest.yml
