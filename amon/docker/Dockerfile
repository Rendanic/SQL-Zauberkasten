FROM oraclelinux:7-slim

ARG release=19
ARG update=25

ENV ORACLE_HOME=/usr/lib/oracle/${release}.${update}/client64
ENV LD_LIBRARY_PATH=/usr/lib/oracle/${release}.${update}/client64/lib

RUN  yum -y install oracle-release-el7 && \
     yum -y install \
        oracle-instantclient${release}.${update}-basic \
        oracle-instantclient${release}.${update}-devel \
        oracle-instantclient${release}.${update}-sqlplus \
        wget \
        gzip && \
     rm -rf /var/cache/yum

RUN cd /tmp/ \
    && wget -q https://github.com/asimondev/amon/raw/refs/heads/master/bin/v2/amon_19c_ol7.gz \
    && gunzip amon_19c_ol7.gz \
    && chmod 755 amon_19c_ol7 \
    && mv amon_19c_ol7 /usr/local/bin/amon

CMD ["amon"]
