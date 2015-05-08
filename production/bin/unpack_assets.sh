#!/bin/bash

assets_tgz=$1; shift
pipeline_stage_dir=$1; shift

set -e

tar xfz ${assets_tgz}

ls -opR pipeline-assets/

rm -rf $pipeline_stage_dir/bin
rm -rf $pipeline_stage_dir/pipeline
rm -rf $pipeline_stage_dir/releases
rm -rf $pipeline_stage_dir/stemcell

cp -r pipeline-assets/* $pipeline_stage_dir/
