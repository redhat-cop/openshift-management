FROM centos:7

LABEL io.k8s.description="OCP Project Pruner" \
      io.k8s.display-name="OCP Project Pruner"

ENV PATH=$PATH:/usr/local/bin

ADD include/prune-ocp-projects.sh /usr/local/bin/

RUN curl https://mirror.openshift.com/pub/openshift-v3/clients/3.9.19/linux/oc.tar.gz | tar -C /usr/local/bin/ -xzf -
RUN chmod +x /usr/local/bin/prune-ocp-projects.sh

CMD [ "/usr/local/bin/prune-ocp-projects.sh" ]
