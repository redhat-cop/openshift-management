FROM centos:7

MAINTAINER Marcos Entenza <mak@redhat.com>

LABEL io.k8s.description="AWS EBS snaphot manager for OCP" \
      io.k8s.display-name="AWS EBS snaphot manager for OCP"

ENV PATH=$PATH:/usr/local/bin
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_DEFAULT_REGION=${AWS_REGION}
ENV NSPACE=${NSPACE}
ENV VOL=${VOL}

ADD  include/create_snapshot.sh /usr/local/bin/

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
rm -fr /var/cache/yum/* && \
yum clean all && \
INSTALL_PKGS="python2-pip wget" && \
yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
rpm -V $INSTALL_PKGS && \
yum clean all && \
pip install --upgrade pip && \
pip install awscli && \
curl https://mirror.openshift.com/pub/openshift-v3/clients/3.9.19/linux/oc.tar.gz | tar -C /usr/local/bin/ -xzf - && \
chmod +x /usr/local/bin/create_snapshot.sh


CMD [ "/usr/local/bin/create_snapshot.sh", "${NSPACE}", "${VOL}" ]
