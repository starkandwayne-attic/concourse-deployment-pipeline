#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

message=$1; shift
if [[ "${message}X" == "X" ]]; then
  echo "USAGE: git-add-stage-changes.sh 'commit message'"
  exit 1
fi

set -e

git config --global user.email "nobody@concourse.ci"
git config --global user.name "Concourse"

pushd $DIR/..
  # TODO - this is a bit unclean; how do we get them out of the git repo in first place?
  rm -rf ../candidate-assets
  rm -rf ../pipeline-assets
  rm -rf stemcell
  rm -rf releases
  echo "Checking for changes in $(pwd)..."
  if [[ "$(git status -s)X" != "X" ]]; then
    git add . --all
    git commit -m "${message}"
  fi
popd
