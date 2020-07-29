#!/usr/bin/env sh
#shellcheck shell=sh

set -x

REPO=mikenye
IMAGE=nginx-ldap-auth-portal
PLATFORMS="linux/amd64,linux/arm/v7,linux/arm64"

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build latest
docker buildx build -t "${REPO}/${IMAGE}:latest" --compress --push --platform "${PLATFORMS}" .

# Get nginx version
docker pull "${REPO}/${IMAGE}:latest"
VERSION=$(docker run --rm --entrypoint nginx "${REPO}/${IMAGE}:latest" -v 2>&1 | cut -d '/' -f 2 | tr -d ' ')

# Build nginx version specific
docker buildx build -t "${REPO}/${IMAGE}:nginx_${VERSION}" --compress --push --platform "${PLATFORMS}" .
