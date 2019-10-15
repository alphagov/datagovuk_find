[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# data.gov.uk Find

This repository contains the beta-stage frontend component of data.gov.uk

## Prerequisites

You will need to install the following for development.

  * [rbenv](https://github.com/rbenv/rbenv) or similar to manage ruby versions
  * [bundler](https://rubygems.org/gems/bundler) to manage gems
  * [elasticsearch](https://www.elastic.co/) search engine
  * [postgresql](https://www.postgresql.org/) database
  * [yarn](https://yarnpkg.com/en/) to manage node packages
  * [data.gov.uk Publish](https://github.com/alphagov/datagovuk_publish/) to populate elasticsearch

Most of these can be installed with Homebrew on a Mac.

## Getting Started

First run `bin/setup` to bundle, etc. Then run `rails s`.

## Deployment

You can track the deployments on travis - https://travis-ci.org/alphagov/datagovuk_find. 

### Staging

To deploy to staging merge a PR into master.

Test that your changes are working here - https://staging.data.gov.uk before releasing to Production.

### Production

To deploy to production you need to tag the release, the tag needs to be in this format - `v9.9.9` where 9 is a number and the leading `v` is required. E.g. `v0.1.11` is valid, `0.1.11` is not.

## Developing against production elasticsearch

Grab the full URL (including HTTP Basic username and password) from the paas.
You can do this with `cf env find-data-beta`.

Open up an SSH tunnel to allow access to the elasticsearch instance:
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
