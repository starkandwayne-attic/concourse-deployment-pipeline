#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
manifest=${manifest:-"manifests/manifest.yml"}

set -e

cd $DIR/..
mkdir -p manifests
stage=$(basename $DIR)

if [[ ! -f releases/logstash-docker/version ]]; then
  echo "missing resource input ${stage}/releases/logstash-docker/version"
  exit 1
fi
LOGSTASH_DOCKER_VERSION=$(cat releases/logstash-docker/version)

if [[ ! -f releases/docker/version ]]; then
  echo "missing resource input ${stage}/releases/docker/version"
  exit 1
fi
DOCKER_VERSION=$(cat releases/docker/version)

if [[ ! -f stemcell/version ]]; then
  echo "missing resource input ${stage}/stemcell/version"
  exit 1
fi
STEMCELL_VERSION=$(cat stemcell/version)

cat >manifests/pipeline-inputs.yml <<EOF
---
meta:
  release_versions:
    logstash_docker: "$LOGSTASH_DOCKER_VERSION"
    docker: "$DOCKER_VERSION"
  stemcell:
    version: "$STEMCELL_VERSION"
EOF


./bin/make_manifest.sh $@ > $manifest
