FROM ubuntu

COPY EntryPoint.sh /

# The following statement should be modified based on the location of the SoapUI tarball.
COPY SoapUI-5.4.0-linux-bin.tar /
RUN tar -xf SoapUI-5.4.0-linux-bin.tar

ENV PATH=$PATH:/SoapUI-5.4.0/bin

RUN apt-get update
RUN apt-get -y install git
RUN apt-get install -y default-jre

RUN ["chmod", "+x", "./EntryPoint.sh"]

ENTRYPOINT ["./EntryPoint.sh"]
