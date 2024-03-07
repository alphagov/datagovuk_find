FROM ghcr.io/alphagov/datagovuk_find:v2.41.0

USER root
ENV BUNDLE_WITHOUT=""
ENV RAILS_ENV=development
RUN install_packages \
    g++ git gpg libc-dev libcurl4-openssl-dev libgdbm-dev libssl-dev \
    libmariadb-dev-compat libpq-dev libyaml-dev make xz-utils
RUN bundle install

USER app
