[![Stories in Ready](https://badge.waffle.io/datagovuk/find_data_beta.png?label=ready&title=Ready)](https://waffle.io/datagovuk/find_data_beta?utm_source=badge)
# Find Data Beta

In order for the app to work, it needs the following environment variables
to be set.

**PUBLISH_URL**

This should be the URL of a working publish data.  If you don't want to run
a copy locally when working on find, then you can use
https://publish-data-beta.herokuapp.com but you will need to encode the
basic auth details in the URL https://username:password@publish-data-beta.herokuapp.com

You should always remember to remove the trailing slash from these URLs.

**SECRET_KEY_BASE**

This should be a random string (for development)

**ES_HOST**

Only if you don't want to use 127.0.0.1:9200 (the default).  Don't forget to remove
the trailing slash.
