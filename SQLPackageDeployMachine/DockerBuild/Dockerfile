FROM ubuntu

COPY EntryPoint.sh /
COPY oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm /

RUN apt-get update
RUN apt-get -y install wget
RUN apt-get -y install alien
RUN apt-get -y install libaio1
RUN alien -i oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm
RUN echo /usr/lib/oracle/12.1/client/lib > /etc/ld.so.conf.d/oracle.conf
RUN ldconfig
RUN ["chmod", "+x", "./EntryPoint.sh"]

ENTRYPOINT ["./EntryPoint.sh"]
