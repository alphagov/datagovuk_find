#!/bin/bash
# This setup script is used with the docker-ckan dev stack

echo '===== Setup datagovuk find ====='

mkdir -p /var/log/find
rm -rf /srv/app/datagovuk_find/tmp/pids/
rails s -b 0.0.0.0 2>&1 | tee /var/log/find/find.log
