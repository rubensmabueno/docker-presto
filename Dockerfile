FROM openjdk:8-alpine
MAINTAINER Rubens Minoru Andako Bueno <rubensmabueno@hotmail.com>

RUN set -ex && \
    apk upgrade --no-cache && \
    apk add --no-cache curl python snappy nss

# Installing JMX Exporter
WORKDIR /tmp

ENV JMX_PROMETHEUS_JAVAAGENT_VERSION 0.3.1
ENV JMX_PROMETHEUS_JAVAAGENT_HOME /opt/jmx_prometheus_javaagent
ENV JMX_PROMETHEUS_JAVAAGENT_PORT 5556
ENV JMX_PROMETHEUS_JAVAAGENT_CONFIG ${JMX_PROMETHEUS_JAVAAGENT_HOME}/config.yml

RUN mkdir -p ${JMX_PROMETHEUS_JAVAAGENT_HOME} && \
    curl -s https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_PROMETHEUS_JAVAAGENT_VERSION}/jmx_prometheus_javaagent-${JMX_PROMETHEUS_JAVAAGENT_VERSION}.jar > ${JMX_PROMETHEUS_JAVAAGENT_HOME}/jmx_prometheus_javaagent.jar

# Installing Presto
WORKDIR /tmp

ENV PRESTO_VERSION 0.280
ENV PRESTO_HOME /opt/presto
ENV PRESTO_ETC_DIR /etc/presto
ENV PRESTO_DATA_DIR /data

RUN mkdir -p ${PRESTO_HOME} && \
    mkdir -p ${PRESTO_ETC_DIR}/catalog && \
    curl -s https://repo1.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz | tar --strip 1 -xzC ${PRESTO_HOME} && \
    curl -s https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar > /usr/local/bin/presto && \
    chmod +x /usr/local/bin/presto && \
    mkdir ${PRESTO_HOME}/scripts && \
    rm -rf /tmp/*

ADD config/node.properties /etc/presto/node.properties
ADD config/log.properties /etc/presto/log.properties
ADD config/jvm.config /opt/presto/etc/jvm.config
ADD config/catalog /etc/presto/catalog

WORKDIR ${PRESTO_HOME}

ENV JAVA_OPTS "-server"

CMD ["./bin/launcher", "--config=/etc/presto/config.properties", "--log-levels-file=/etc/presto/log.properties", "--node-config=/etc/presto/node.properties", "run"]
