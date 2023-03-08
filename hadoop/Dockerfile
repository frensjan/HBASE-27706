ARG BASE_IMAGE=eclipse-temurin:11-jdk


# Builder image to download Hadoop and extract it to /usr/local/hadoop

FROM $BASE_IMAGE AS builder

ARG HADOOP_VERSION
ENV HADOOP_FILE=hadoop-$HADOOP_VERSION.tar.gz
ARG MIRROR_URL=https://dlcdn.apache.org/hadoop/core/hadoop-$HADOOP_VERSION

ADD $MIRROR_URL/$HADOOP_FILE /tmp

RUN cd /tmp && \
    mkdir -p /usr/local/hadoop && \
    tar --strip-components=1 -xzf $HADOOP_FILE -C /usr/local/hadoop


# Runtime image with hadoop from the builder image.

FROM $BASE_IMAGE

ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

COPY --from=builder $HADOOP_HOME $HADOOP_HOME

WORKDIR $HADOOP_HOME
COPY hdfs-site.xml etc/hadoop

COPY format-hdfs.sh sbin
RUN chmod +x sbin/*.sh && \
    chown 1024:1024 sbin/*.sh

CMD ["/bin/bash"]

VOLUME /hadoop
VOLUME /usr/local/hadoop/logs

EXPOSE 9870
EXPOSE 50070
EXPOSE 8088
EXPOSE 19888
EXPOSE 16010
