FROM rhel7:latest

MAINTAINER Ricardo Zanini <ricardozanini@gmail.com>

ARG OC_CLIENT_DOWNLOAD_URL

LABEL io.k8s.description="Truncate Cassandra tag index tables" \
      io.k8s.display-name="Truncate Cassandra Tables Job"

ENV PATH=$PATH:/usr/local/bin

ADD include/truncate-cassandra-tag-metrics.sh /usr/local/bin/

RUN curl ${OC_CLIENT_DOWNLOAD_URL} | tar -C /usr/local/bin/ -xzf -
RUN chmod +x /usr/local/bin/truncate-cassandra-tag-metrics.sh

CMD [ "/usr/local/bin/truncate-cassandra-tag-metrics.sh" ]