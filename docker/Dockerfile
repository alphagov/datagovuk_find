ARG ruby_version=3.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version

FROM $builder_image AS builder

WORKDIR $APP_HOME
COPY Gemfile* .ruby-version ./
RUN bundle install
COPY . ./
RUN ES_HOST=x rails assets:precompile && rm -fr log


FROM $base_image

WORKDIR $APP_HOME
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder $APP_HOME .

USER app
CMD ["puma"]

LABEL org.opencontainers.image.source=https://github.com/alphagov/datagovuk_find
