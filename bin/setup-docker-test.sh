#!/bin/bash
# source this script before running tests in docker ckan to set the correct env vars
export RAILS_ENV=test
export ES_INDEX=datasets-test
export CKAN_REDIRECTION_URL=testdomain

# install chrome for tests
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install -y ./google-chrome-stable_current_amd64.deb
