#!/bin/bash
# This local-run script is used with the ckanext-datagovuk docker compose stack

echo '===== Local datagovuk find run ====='

mkdir -p /var/log/find
rm -rf /srv/app/datagovuk_find/tmp/pids/
rails s -b 0.0.0.0 2>&1 | tee /var/log/find/find.log
