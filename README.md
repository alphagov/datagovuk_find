[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# data.gov.uk Find

This repository contains the beta-stage frontend component of data.gov.uk

## Prerequisites

You will need to install the following for development.

  * [rbenv](https://github.com/rbenv/rbenv) or similar to manage ruby versions
  * [bundler](https://rubygems.org/gems/bundler) to manage gems
  * [elasticsearch](https://www.elastic.co/) database
  * [postgresql](https://www.postgresql.org/)database
  * [yarn](https://yarnpkg.com/en/) to manage node packages
  * [data.gov.uk Publish](https://github.com/alphagov/datagovuk_publish/) to populate elasticsearch

Most of these can be installed with Homebrew on a Mac.

## Getting Started

First create a `.env` file with the following contents.

```
PUBLISH_URL= # URL to preview for CSV previews
SECRET_KEY_BASE="anything"
ES_HOST= # override if not on 127.0.0.1:9200
```

Now run the following commands to complete your setup.

```
bundle install
rake db:setup
yarn install
```

Then run `rails s` to and navigate to `http://localhost:3000`.
