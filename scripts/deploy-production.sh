#!/bin/bash

rm manifest.yml || true
ln -s production-app-manifest.yml manifest.yml
cf bgd publish-data-beta production-app-manifest.yml


rm manifest.yml
ln -s production-worker-manifest.yml manifest.yml
cf bgd publish-data-beta-worker production-worker-manifest.yml

rm manifest.yml
