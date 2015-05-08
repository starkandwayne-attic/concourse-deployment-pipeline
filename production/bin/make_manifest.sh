#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR/..
DIR=$(pwd)

stage=$(basename $DIR)

if [[ ! -f releases/concourse/version ]]; then
  echo "missing resource input ${stage}/releases/concourse/version"
  exit 1
fi
CONCOURSE_VERSION=$(cat releases/concourse/version)

if [[ ! -f releases/garden-linux/version ]]; then
  echo "missing resource input ${stage}/releases/garden-linux/version"
  exit 1
fi
GARDEN_LINUX_VERSION=$(cat releases/garden-linux/version)

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
    concourse: "$CONCOURSE_VERSION"
    garden-linux: "$GARDEN_LINUX_VERSION"
  stemcell:
    version: "$STEMCELL_VERSION"
EOF

spiff merge \
  pipeline/base.yml \
  environment/networks.yml \
  environment/director.yml \
  environment/name.yml \
  manifests/pipeline-inputs.yml
