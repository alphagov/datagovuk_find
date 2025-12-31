[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# data.gov.uk Find

This repository contains the beta-stage frontend component of data.gov.uk

## How to run this repo locally

There are currently 3 ways to run this repo locally:

1. Via  [govuk-dgu-charts](https://github.com/alphagov/govuk-dgu-charts) - An end to end setup from ckan to Solr to Find. This is the closest stack to the Find app running on EKS. Instructions for how to setup and run Find this way available on the linked repo.
2. Via [docker stack in ckanext-datagovuk](https://github.com/alphagov/ckanext-datagovuk) - This will be the fastest way to see your changes deployed and interact with a stack containing some seeded test data. It is also possible to run tests on it and debug issues within the containers.
3. Manual installation - this will give the fastest way to run the tests. Instructions for this below.

## Manual installation
### Prerequisites

You will need to install the following for development.

  * [rbenv](https://github.com/rbenv/rbenv) or similar to manage ruby versions
  * [bundler](https://rubygems.org/gems/bundler) to manage gems
  * [yarn](https://yarnpkg.com/en/) to manage node packages

Most of these can be installed with Homebrew on a Mac.

### Getting Started

First run `bin/setup` to bundle, etc. Then run `rails s`.

## Deployment

See [the developer docs on data.gov.uk deployment](https://docs.publishing.service.gov.uk/manual/data-gov-uk-deployment.html)

## Example application URLs

- Find landing page: https://data.gov.uk
- Search results: https://data.gov.uk/search?filters%5Btopic%5D=Environment
- Dataset: https://data.gov.uk/dataset/ce5f9a81-742d-4446-8610-2ec138e1b7e5/st-john-s-lake-intertidal-biotope-map-tamar-estuary-plymouth
- Dataset with publisher login: https://data.gov.uk/dataset/cf725d50-6535-4f8b-bc98-5ab01aa866a7/grants-to-voluntary-community-and-social-enterprise-organisations-local-government-transparency-code
- Support page: https://data.gov.uk/support
- Publisher login page: https://data.gov.uk/publishers
