[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# data.gov.uk Find

This repository contains the beta-stage frontend component of data.gov.uk

## How to run this repo locally

There are currently 2 ways to run this repo locally:

1. Via  [docker-ckan](https://github.com/alphagov/docker-ckan) - An end to end setup from ckan to opensearch to Find. This is the presently most supported means for running Find and is recommended for local development. Instructions for how to setup and run Find this way available on the linked repo.
2. Manual installation. Instructions for this below.
3. Via [govuk-docker](https://github.com/alphagov/govuk-docker) - You can `make` Find as you would any other repo supported by govuk-docker using this method. This is the quickest means to setup Find however this will not give you a complete visual setup and is primarily for running tests.

## Manual installation
### Prerequisites

You will need to install the following for development.

  * [rbenv](https://github.com/rbenv/rbenv) or similar to manage ruby versions
  * [bundler](https://rubygems.org/gems/bundler) to manage gems
  * [opensearch](https://opensearch.org/) search engine
  * [postgresql](https://www.postgresql.org/) database
  * [yarn](https://yarnpkg.com/en/) to manage node packages
  * [data.gov.uk Publish](https://github.com/alphagov/datagovuk_publish/) to populate opensearch

Most of these can be installed with Homebrew on a Mac.

### Getting Started

First run `bin/setup` to bundle, etc. Then run `rails s`.

## Deployment

Continuous Integration has been setup using Github Actions. 
  - Tests are run on pull requests.
  - Deployments to Staging happen automatically when marging branches into the `main` branch.
  - In order to carry out a release to production a developer in the govuk team will need to create a release tag with a  leading `v` and [approve](https://docs.github.com/en/actions/managing-workflow-runs/reviewing-deployments) of the deployment in Github Actions.

Further information about the deploying to PaaS are in the developer documents here: 

https://docs.publishing.service.gov.uk/manual/data-gov-uk-deployment.html#paas-staging-and-production-environments

### Staging

To deploy to staging merge a PR into `main`.

Test that your changes are working here - https://find-data-beta-staging.cloudapps.digital before releasing to Production.

(There is also https://staging.data.gov.uk but it currently has an [authentication configuration issue](https://github.com/alphagov/paas-ip-authentication-route-service/pull/10)).

### Production

To deploy to production you need to tag the release, the tag needs to be in this format - `v9.9.9` where 9 is a number and the leading `v` is required. E.g. `v0.1.11` is valid, `0.1.11` is not.

Then the deployment needs to be [approved](https://docs.github.com/en/actions/managing-workflow-runs/reviewing-deployments).

## Developing against production opensearch

Grab the full URL (including HTTP Basic username and password) from the paas.
You can do this with `cf env find-data-beta`.

Open up an SSH tunnel to allow access to the opensearch instance:
```
cf ssh -N -L <es-port>:<es-host>:<es-port> find-data-beta
```

You can use any port you like for the local connection (i.e., the first `<es-port>`)
but I would recommend using the same port as the remote side to reduce confusion.

Set the following environment variables (via direnv or other method of your choice):
- `ES_HOST="https://<username>:<password>@localhost:<es-port>"`
- `ES_INDEX="datasets-production"`

If you're using direnv you'll need to add `export ` in front of those lines in
your `.envrc`.

After (re)starting your Rails server, any requests to your local instance will
behave the same as production.

If you're having connection issues, try opening new tabs in your terminal to
ensure all your environment variables are cleared and refreshed.

## Testing on docker ckan

Source the `bin/setup-docker-test.sh` script in order to set up the environment variables for testing and install chrome on the debian docker container.
