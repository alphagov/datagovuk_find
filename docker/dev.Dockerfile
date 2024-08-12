FROM ghcr.io/alphagov/datagovuk_find:v2.41.0
# FROM localhost:50635/datagovuk_find:dev

USER root
ENV BUNDLE_WITHOUT=""
ENV RAILS_ENV=test
ENV ES_INDEX=datasets-test
ENV CKAN_DOMAIN=testdomain

# COPY docker/debian-keys.asc /etc/apt/keyrings/debian-keys.asc
# RUN arch=$(dpkg --print-architecture) && \
#     echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/debian-keys.asc] http://deb.debian.org/debian trixie main" > /etc/apt/sources.list.d/debian.list && \
#     echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/debian-keys.asc] http://deb.debian.org/debian-security/ trixie-security main" >> /etc/apt/sources.list.d/debian.list && \
#     echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/debian-keys.asc] http://deb.debian.org/debian trixie-updates main" >> /etc/apt/sources.list.d/debian.list
RUN install_packages \
    g++ git gpg libc-dev libcurl4-openssl-dev libgdbm-dev libssl-dev \
    libmariadb-dev-compat libpq-dev libyaml-dev make xz-utils wget unzip \
    xdg-utils libxrandr2 fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 \
    libatspi2.0-0 libcairo2 libcups2 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libgtk-3-0 \
    libgtk-4-1 libnspr4 libnss3 libpango-1.0-0 libu2f-udev libvulkan1 libxcomposite1 \
    libxdamage1 libxfixes3 libxkbcommon0
    # chromium chromium-common chromium-sandbox chromium-sandbox chromium-driver

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    apt --fix-broken install -y && \
    wget https://chromedriver.storage.googleapis.com/113.0.5672.63/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/bin/chromedriver && \
    chown root:root /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver

RUN bundle install

WORKDIR $APP_HOME
COPY ./spec ./spec

# USER app
