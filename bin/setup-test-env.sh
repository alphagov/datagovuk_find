#!/bin/bash
# source this script before running tests in docker ckan to set the correct env vars
export RAILS_ENV=test
export ES_INDEX=datasets-test
export CKAN_DOMAIN=testdomain
