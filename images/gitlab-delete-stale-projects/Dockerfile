FROM registry.access.redhat.com/ubi8/ubi

LABEL maintainer="Red Hat Services"

# Update image
RUN dnf update -y && rm -rf /var/cache/yum

RUN dnf install -y python3; yum clean all

RUN python3 -m pip install requests

ENV LOG_LEVEL=INFO
ENV DRY_RUN=TRUE

USER root
RUN yum install -y python3-pip
USER 1001

ADD gitlab-cleanup.py .

CMD ["python3", "gitlab-cleanup.py"]
