FROM concourse/concourse-ci
# https://github.com/concourse/concourse/blob/master/ci/dockerfiles/concourse-ci/Dockerfile

RUN gem list bosh | grep bosh | awk '{print $1}' | xargs -L1 gem uninstall -a -I
RUN gem install bosh_cli --no-rdoc --no-ri

# TODO: base image doesn't have sqlite.h
# RUN gem install bosh_cli_plugin_micro --no-rdoc --no-ri
