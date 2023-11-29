ARG ruby_version=3.2.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version

FROM $builder_image AS builder

WORKDIR /srv/app/datagovuk_find

RUN apt-get update
RUN apt-get install -y nodejs

COPY ./ /srv/app/datagovuk_find

RUN gem install bundler && \
    bundle install 

RUN rails assets:precompile

RUN bin/yarn 
