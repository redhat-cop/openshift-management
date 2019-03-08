FROM centos:7

MAINTAINER Ricardo Zanini <ricardozanini@gmail.com>

LABEL io.k8s.description="Truncate Cassandra tag index tables" \
      io.k8s.display-name="Truncate Cassandra Tables Job"

ENV PATH=$PATH:/usr/local/bin

ADD include/truncate-cassandra-tag-metrics.sh /usr/local/bin/

RUN curl https://mirror.openshift.com/pub/openshift-v3/clients/3.9.19/linux/oc.tar.gz | tar -C /usr/local/bin/ -xzf -
RUN chmod +x /usr/local/bin/truncate-cassandra-tag-metrics.sh

CMD [ "/usr/local/bin/truncate-cassandra-tag-metrics.sh" ]
