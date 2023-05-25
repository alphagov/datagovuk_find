#!/bin/bash
# source this script before running tests in docker ckan to set the correct env vars
export RAILS_ENV=test
export ES_INDEX=datasets-test
export CKAN_DOMAIN=testdomain

# install chrome for tests
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
apt-get install -y ./google-chrome-stable_current_amd64.deb
apt --fix-broken install -y
wget https://chromedriver.storage.googleapis.com/113.0.5672.63/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mv chromedriver /usr/bin/chromedriver
chown root:root /usr/bin/chromedriver
chmod +x /usr/bin/chromedriver
