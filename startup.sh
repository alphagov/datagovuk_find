#/usr/bin/env bash

set -e
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

bundle check || bundle install

if [[ $1 == "--paas-integration" ]] ; then
  if ! command -v cf &> /dev/null
  then
    echo "Could not find the cf command line tool - https://docs.cloud.service.gov.uk/get_started.html"
    exit
  fi

  cf target -o gds-data-gov-uk -s data-gov-uk-staging 

  export VCAP_SERVICES=$(
    cf curl "/v3/apps/$(cf app --guid find-data-beta-integration)/env" |
    ruby -rjson -e '\
    vcap_services = JSON.parse(STDIN.read).dig("system_env_json", "VCAP_SERVICES"); \
    credentials = vcap_services.dig("opensearch", 0, "credentials"); \
    uri = credentials.dig("uri"); \
    credentials["uri"] = uri.sub(/@.*$/, "@localhost:9200"); \
    puts JSON.dump vcap_services'
  )
  OPENSEARCH_HOST=$(
    ruby -rjson -e '\
    credentials = JSON.parse(ENV["VCAP_SERVICES"]).dig("opensearch", 0, "credentials"); \
    hostname = credentials["hostname"]; \
    port = credentials["port"]; \
    puts "#{hostname}:#{port}"'
  )
  cf ssh -N -L "9200:${OPENSEARCH_HOST}" find-data-beta-integration &

  RAILS_ENV=integration \
  RACK_ENV=integration \
  CKAN_REDIRECTION_URL=ckan.integration.publishing.service.gov.uk \
  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_WEBSITE_ROOT=https://www.gov.uk \
  ELASTICSEARCH_VERIFY_SSL=FALSE \
  rails s
else
  echo "ERROR: other startup modes are not supported"
  exit 1
fi