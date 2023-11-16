#!/bin/bash

set -eux

build () {
  if [ "${ARCH}" = "amd64" ]; then
    docker build . -t "ghcr.io/alphagov/${APP}:${1}" -f "docker/Dockerfile"
  else
    docker buildx build --platform "linux/${ARCH}" . -t "ghcr.io/alphagov/${APP}:${1}" -f "docker/Dockerfile"
  fi
}

DOCKER_TAG="${GITHUB_SHA}"

build "${DOCKER_TAG}"

if [[ -n ${DRY_RUN:-} ]]; then
  echo "Dry run; not pushing to registry"
else
  docker push "ghcr.io/alphagov/${APP}:${DOCKER_TAG}"
fi
