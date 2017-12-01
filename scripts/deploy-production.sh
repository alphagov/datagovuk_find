#!/bin/bash

rm manifest.yml || true
ln -s production-manifest.yml manifest.yml
cf bgd find-data-beta production-manifest.yml

rm manifest.yml
