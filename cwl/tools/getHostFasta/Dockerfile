# Dockerfile for getHostFasta

FROM alpine:latest

RUN apk add --no-cache bash python3
#RUN apt update && apt upgrade -y && apt install -y wget 

COPY getHostFasta.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/getHostFasta.sh
COPY getFastaFromEnsemblFTP.py /usr/local/bin/
RUN chmod a+x /usr/local/bin/getFastaFromEnsemblFTP.py

LABEL software="getHostFasta"
LABEL software.version="0.0.1"
LABEL description="Quick tool to retrieve Ensembl genome sequence for host, getHostFasta.sh <species/url>"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]