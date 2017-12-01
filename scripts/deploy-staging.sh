#!/bin/bash

rm manifest.yml || true
ln -s staging-manifest.yml manifest.yml
cf bgd find-data-beta-staging staging-manifest.yml

rm manifest.yml
