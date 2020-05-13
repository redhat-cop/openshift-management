FROM registry.access.redhat.com/ubi8/ubi

LABEL io.k8s.description="OCP Project Pruner" \
      io.k8s.display-name="OCP Project Pruner"

ENV PATH=$PATH:/usr/local/bin

ADD include/prune-ocp-projects.sh /usr/local/bin/

RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.4/linux/oc.tar.gz | tar -C /usr/local/bin/ -xzf - && \
    chmod +x /usr/local/bin/prune-ocp-projects.sh

CMD [ "/usr/local/bin/prune-ocp-projects.sh" ]
