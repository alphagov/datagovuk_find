[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# Find Data Beta

## Set up the app

Get the code:
`git clone git@github.com:datagovuk/find_data_beta.git`

Set up the app's dependencies:
`cd find_data_beta`
`.bin/setup`

## Run the app

Run the app on port XXXX (defaults to 3000):
`rails server -p XXXX`

## ElasticSearch

If you want to run ElasticSearch on your development machine:
* `brew install elasticsearch`
* `elasticsearch`


# Vagrant

To run the app in a local VM with vagrant, install Vagrant and Virtualbox, then:

Create the VM and install packages:
```
$ vagrant up
```

Install Rails (edit the file first if you want to use a different elasticsearch server):
```
$ vagrant ssh -c /vagrant/tools/vagrant-dev-setup.sh
```


Run the app:
```
$ vagrant ssh -c "cd /vagrant && bundle install && rails s"
```
