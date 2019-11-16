#!/usr/bin/env bash

set -o errexit

# Create the container
container=$(buildah from registry.access.redhat.com/ubi8/ubi)
buildah config --label io.k8s.description="OCP Project Pruner" --label io.k8s.display-name="OCP Project Pruner" --env PATH='$PATH:/usr/local/bin' $container
buildah add $container include/prune-ocp-projects.sh /usr/local/bin/
buildah run $container -- curl -Lo /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.2/linux/oc.tar.gz
buildah run $container -- tar -C /usr/local/bin/ -xzf /tmp/oc.tar.gz
buildah run $container -- rm /tmp/oc.tar.gz
buildah config --cmd /usr/local/bin/prune-ocp-projects.sh $container

buildah commit $container prune-ocp-projects:latest
