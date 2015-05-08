#!/bin/bash

pipeline_name=$1; shift
pipeline=$1; shift
credentials=$1; shift
trigger_job=$1; shift
set -e

fly_target=${fly_target:-"bosh-lite"}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "Concourse: ${fly_target}"

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

usage() {
  echo "USAGE: run-pipeline.sh name pipeline.yml credentials.yml [trigger-job]"
  exit 1
}

if [[ "${credentials}X" == "X" ]]; then
  usage
fi
pipeline=$(realpath $pipeline)
if [[ ! -f ${pipeline} ]]; then
  usage
fi
credentials=$(realpath $credentials)
if [[ ! -f ${credentials} ]]; then
  usage
fi

pushd $DIR
  yes y | fly -t ${fly_target} configure -c ${pipeline} --vars-from ${credentials} ${pipeline_name}
  if [[ "${trigger_job}X" != "X" ]]; then
    if [[ "${ATC_URL}X" == "X" ]]; then
      echo "Set $ATC_URL to be able to trigger jobs"
    else
      curl $ATC_URL/jobs/${trigger_job}/builds -X POST
      fly -t ${fly_target} watch -j ${trigger_job}
    fi
  fi
popd
