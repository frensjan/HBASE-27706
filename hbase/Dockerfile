ARG BASE_IMAGE=eclipse-temurin:11-jdk


# Builder image to download HBase and extract it to /usr/local/hbase

FROM $BASE_IMAGE AS builder

ARG HADOOP_VERSION
ENV HADOOP_FILE=hadoop-$HADOOP_VERSION.tar.gz
ARG MIRROR_URL=https://dlcdn.apache.org/hadoop/core/hadoop-$HADOOP_VERSION

ADD $MIRROR_URL/$HADOOP_FILE /tmp

RUN cd /tmp && \
    mkdir -p /usr/local/hadoop && \
    tar --strip-components=1 -xzf $HADOOP_FILE -C /usr/local/hadoop

ARG HBASE_VERSION
ARG HBASE_QUALIFIER
ENV HBASE_ARCHIVE_NAME=hbase-$HBASE_VERSION$HBASE_QUALIFIER-bin.tar.gz
ARG MIRROR_URL=https://dlcdn.apache.org/hbase/$HBASE_VERSION/$HBASE_ARCHIVE_NAME
ADD $MIRROR_URL /tmp

RUN cd /tmp && \
    mkdir -p /usr/local/hbase && \
    tar --strip-components=1 -xzf $HBASE_ARCHIVE_NAME -C /usr/local/hbase


# Runtime image with hbase from the builder image.

FROM $BASE_IMAGE

ENV HADOOP_HOME /usr/local/hadoop
ENV HBASE_HOME /usr/local/hbase

ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV PATH $PATH:$HBASE_HOME/bin

COPY --from=builder $HADOOP_HOME $HADOOP_HOME
COPY --from=builder $HBASE_HOME $HBASE_HOME

WORKDIR $HBASE_HOME

VOLUME /hbase
VOLUME /usr/local/hbase/logs

EXPOSE 2181
EXPOSE 16000
EXPOSE 16010
EXPOSE 16020
EXPOSE 16030
