Pipeline to deploy Logstash Docker
==================================

This project is an example http://concourse.ci pipeline for deploying the https://github.com/cloudfoundry-community/logstash-docker-boshrelease/ BOSH release.

[![](https://badge.imagelayers.io/drnic/logstash-docker-pipeline.svg)](https://imagelayers.io/?images=drnic/logstash-docker-pipeline:latest)

There are several `pipeline*.yml` to choose from:

-	`pipeline-try-anything.yml` will deploy a single VM from current upstream BOSH releases & stemcells. Any new releases or stemcells, or changes to `try-anything/environment` or `try-anything/pipeline` templates will trigger a new deployment. It will indeed "try anything".

![try-anything](http://cl.ly/image/0D001Z450e1e/try-anything.png)

-	`pipeline-try-first-then-production.yml` will run two deployments. The first BOSH deployment is like `pipeline-try-anything.yml`. If it successfully deploys, then the winning combination of release/stemcell/templates is passed through to the production deployment.

![try-anything-production](http://cl.ly/image/3w15021g2c1W/try-anything_straight_to_production.png)

-	`pipeline-try-pre-prod-prod.yml` protects production by one additional stage `pre-production`. The `pre-production` stage is triggered by any successful `try-anything` deployment. It first deploys based on the last successful `production`, then upgrades to the last successful `try-anything`. If success, this becomes the candidate for `production`'s next deployment. In this pipeline `deploy-production` job is manually triggered only - based on last successful `deploy-pre-production` job candidate.

![pre-prod](http://cl.ly/image/3s3P271d3703/pre-prod.png)

The example pipelines all assume the deployments are via the same BOSH - as such only the entry deployment `try-anything` is responsible for uploading releases & stemcells. Other deployments assume that releases & stemcells are uploaded, and benefit from packages being pre-compiled.

Usage
-----

The example pipelines above are designed to be deployed in sequence to grow out your pipeline.

The templates in `try-anything`, `pre-production` and `production` are for bosh-lite; so bootup bosh-lite. It is convenient to deployment http://concourse.ci into that bosh-lite too. Due to the amount of Docker images and BOSH assets being downloaded, deploying bosh-lite to AWS might be a good idea.

Next, create a `credentials.yml` based on `credentials.yml.example`.

Next, deploy the `try-anything` pipeline:

```
./run-pipeline.sh logstash-docker pipeline-try-anything.yml credentials.yml
```

Once it is working, you can expand your pipeline to feed into a `production` deployment:

```
./run-pipeline.sh logstash-docker pipeline-try-first-then-production.yml credentials.yml
```

The `deploy-production` job should trigger immediately because the `deploy-try-anything` job has already previously succeeded.

Finally, to add further deployment protection to `production` you might want to pre-deploy all changes through a `pre-production` deployment.

```
./run-pipeline.sh logstash-docker pipeline-try-pre-prod-prod.yml credentials.yml
```

Building/updating the base Docker image for tasks
-------------------------------------------------

Each task within all job build plans uses the same base Docker image for all dependencies. Using the same Docker image is a convenience. This section explains how to re-build and push it to Docker Hub.

All the resources used in the pipeline are shipped as independent Docker images and are outside the scope of this section.

```
./run-pipeline.sh logstash-docker-image pipeline-build-docker-image.yml credentials.yml job-build-task-image
```

This will ask your targeted Concourse to pull down this project repository, and build the `task_docker_image/Dockerfile`, and push it to a Docker image on Docker Hub.
