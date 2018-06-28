#!/bin/bash

set -e

# Usage: deploy.sh <app_name> <manifest_prefix>
#
#   Command-line arguments:
#   <app_name>         name of a cf app
#   <manifest_prefix>  name (before _manifest.yml) of a manifest file in the project root
#
#   For this script to work, you need the following env vars to be set:
#       CF_API:   cf api endpoint. You can find this out with `cf api`
#       CF_SPACE: cf space. you'll have selected this when logging in
#       CF_USER:  your cf username
#       CF_PASS:  your cf password
#
#   You must also have cf-cli installed with the cf-blue-green-deployment plugin. You don't need to be logged in.
#   The script will attempt to install it for you.
#   The plugin can be found here: (https://github.com/bluemixgaragelondon/cf-blue-green-deploy)

if [[ -z $CF_API ]]
then
  echo 'CF_API is not set'
  exit 1
fi

if [[ -z $CF_USER ]]
then
  echo 'CF_USER is not set'
  exit 1
fi

if [[ -z $CF_PASS ]]
then
  echo 'CF_PASS is not set'
  exit 1
fi

if [[ -z $CF_SPACE ]]
then
  echo 'CF_SPACE is not set'
  exit 1
fi

CF_APP=$1
CF_ENV=$2
if [[ -z $CF_APP ]]
then
  echo 'please specify the app you wish to push to as your first argument'
  exit 1
fi

if [[ -z $CF_ENV ]]
then
  CF_ENV='staging'
fi

cf login -a $CF_API -u $CF_USER -p $CF_PASS -s $CF_SPACE
cf add-plugin-repo CF-Community https://plugins.cloudfoundry.org
cf install-plugin autopilot -r CF-Community -f
cf zero-downtime-push $CF_APP -f $CF_ENV-manifest.yml --show-app-log=true
