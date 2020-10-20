# Dockerfile for getHostFasta

FROM ubuntu:latest

RUN apt update && apt upgrade -y && apt install -y wget 

COPY getHostFasta.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/getHostFasta.sh

LABEL software="getHostFasta"
LABEL software.version="0.0.1"
LABEL description="Quick tool to retrieve Ensembl genome sequence for host, getHostFasta.sh <species/url>"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]