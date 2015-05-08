#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..
DIR=$(pwd)

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

mkdir -p manifests
cat >manifests/pipeline-inputs.yml <<EOF
---
meta:
  release_versions:
    logstash_docker: "$LOGSTASH_DOCKER_VERSION"
    docker: "$DOCKER_VERSION"
  stemcell:
    version: "$STEMCELL_VERSION"
EOF

spiff merge \
  pipeline/logstash-docker-boshrelease/deployment.yml \
  pipeline/logstash-docker-boshrelease/jobs.yml \
  pipeline/logstash-docker-boshrelease/run-container-image-embedded.yml \
  pipeline/logstash-docker-boshrelease/infrastructure-warden.yml \
  environment/networking.yml \
  environment/scaling.yml \
  environment/director.yml \
  environment/name.yml \
  manifests/pipeline-inputs.yml
