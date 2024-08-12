FROM ghcr.io/alphagov/datagovuk_find:v2.41.0
# FROM localhost:50635/datagovuk_find:dev

USER root
ENV BUNDLE_WITHOUT=""
ENV RAILS_ENV=development
COPY docker/debian-keys.asc /etc/apt/keyrings/debian-keys.asc
RUN arch=$(dpkg --print-architecture) && \
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/debian-keys.asc] http://deb.debian.org/debian trixie main" > /etc/apt/sources.list.d/debian.list && \
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/debian-keys.asc] http://deb.debian.org/debian-security/ trixie-security main" >> /etc/apt/sources.list.d/debian.list && \
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/debian-keys.asc] http://deb.debian.org/debian trixie-updates main" >> /etc/apt/sources.list.d/debian.list
RUN install_packages \
    g++ git gpg libc-dev libcurl4-openssl-dev libgdbm-dev libssl-dev \
    libmariadb-dev-compat libpq-dev libyaml-dev make xz-utils chromium \
    chromium-common chromium-sandbox chromium-sandbox chromium-driver
RUN bundle install

WORKDIR $APP_HOME
COPY ./spec ./spec

# USER app
