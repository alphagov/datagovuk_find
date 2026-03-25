# build Dockerfile before building this image
FROM datagovuk_find

USER root
COPY ./spec ./spec
ENV BUNDLE_WITHOUT=""
ENV RAILS_ENV=development
ENV GOVUK_TEST_CHROME_NO_SANDBOX=1
RUN apt-get update && apt-get install -y \
    g++ git gpg libc-dev libcurl4-openssl-dev libgdbm-dev libssl-dev \
    libmariadb-dev-compat libpq-dev libyaml-dev make xz-utils \
    software-properties-common vim wget 
RUN bundle install
RUN bin/yarn
RUN rails assets:precompile

# Ubuntu 24.04 will always use snap to install chromium 
# so use an alternative PPA to install chromiumn and chromiun-driver
RUN add-apt-repository ppa:xtradeb/apps -y && \
    apt update && \
    apt install -y chromium chromium-driver

USER app
