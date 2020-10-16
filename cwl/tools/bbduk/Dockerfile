FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        default-jre-headless \
        wget

ENV bbmapVer=38.87
WORKDIR /opt
RUN wget -q https://sourceforge.net/projects/bbmap/files/BBMap_${bbmapVer}.tar.gz && \
    tar xzf BBMap_${bbmapVer}.tar.gz && \
    rm BBMap_${bbmapVer}.tar.gz && \
    rm -rf bbmap/resources && \
    ln -s /opt/bbmap/*.sh /usr/local/bin/


LABEL software="BBTools"
LABEL software.version="38.87"
LABEL description="BBTools is a suite of fast, multithreaded bioinformatics tools designed for analysis of DNA and RNA sequence data."
LABEL website="https://jgi.doe.gov/data-and-tools/bbtools/"
LABEL license="Open Source"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]