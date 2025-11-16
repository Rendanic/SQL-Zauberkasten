FROM container-registry.oracle.com/os/oraclelinux:9-slim

ARG instantclient_version=19.29

ENV ORACLE_HOME=/usr/lib/oracle/${instantclient_version}/client64
ENV LD_LIBRARY_PATH=/usr/lib/oracle/${instantclient_version}/client64/lib

RUN  microdnf -y install oracle-instantclient-release-el9 \
     && microdnf -y install \
        oracle-instantclient${instantclient_version}-basic \
        oracle-instantclient${instantclient_version}-devel \
        oracle-instantclient${instantclient_version}-sqlplus \
        wget \
        gzip

RUN cd /tmp/ \
    && wget -q https://github.com/asimondev/amon/releases/download/v2.0.1/amon.tar \
    && tar -xf amon.tar ./amon_19c_ol9.gz \
    && gunzip ./amon_19c_ol9.gz \
    && chmod 755 amon_19c_ol9 \
    && mv amon_19c_ol9 /usr/local/bin/amon \
    && rm -f /tmp/amon* \
    && microdnf clean all

CMD ["amon"]
