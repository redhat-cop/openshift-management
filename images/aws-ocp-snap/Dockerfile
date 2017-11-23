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
wget -O /usr/local/src/oc-v3.6.1.tar.gz https://github.com/openshift/origin/releases/download/v3.6.1/openshift-origin-client-tools-v3.6.1-008f2d5-linux-64bit.tar.gz && \
tar zxf /usr/local/src/oc-v3.6.1.tar.gz -C /usr/local/src/ --strip-components=1 2> /dev/null && \
cp -p /usr/local/src/oc /usr/local/bin/ && \
rm -rf /usr/local/src/* && \
chmod +x /usr/local/bin/create_snapshot.sh



CMD [ "/usr/local/bin/create_snapshot.sh", "${NSPACE}", "${VOL}" ]
