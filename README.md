[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# data.gov.uk Find

This repository contains the beta-stage frontend component of data.gov.uk

## Prerequisites

You will need to install the following for development.

  * [https://github.com/rbenv/rbenv](rbenv) or similar to manage ruby versions
  * [https://rubygems.org/gems/bundler](bundler) to manage gems
  * [https://www.elastic.co/](elasticsearch) database
  * [https://www.postgresql.org/](postgresql) database
  * [https://www.npmjs.com/](npm) to manage node packages
  * [https://github.com/alphagov/datagovuk_publish/](data.gov.uk Publish) to populate elasticsearch

Most of these can be installed with Homebrew on a Mac.

## Getting Started

First create a `.env` file with the following contents.

```
PUBLISH_URL= # URL to preview for WMS previews
SECRET_KEY_BASE="anything"
ES_HOST= # override if not on 127.0.0.1:9200
```

Now run the following commands to complete your setup.

```
bundle install
rake db:setup
npm install
```

Then run `rails s` to and navigate to `http://localhost:3000`.
