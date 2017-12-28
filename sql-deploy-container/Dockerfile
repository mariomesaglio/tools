FROM ubuntu

COPY EntryPoint.sh /

# The following statement should be modified based on the location of the sqlplus rpm package.
COPY oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm /
COPY oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm /
COPY oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm /

RUN apt-get update
RUN apt-get -y install alien
RUN apt-get -y install libaio1
RUN apt-get -y install git
RUN alien -i oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm
RUN alien -i oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm
RUN alien -i oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm

# The following statement should be modified based on the SQLPlus version
ENV ORACLE_HOME=/usr/lib/oracle/12.2
ENV PATH=$PATH:$ORACLE_HOME/client64/bin
ENV LD_LIBRARY_PATH=$ORACLE_HOME/client64/lib

RUN ldconfig
RUN ["chmod", "+x", "./EntryPoint.sh"]

ENTRYPOINT ["./EntryPoint.sh"]
