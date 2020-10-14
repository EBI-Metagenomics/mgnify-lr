# Docker container for Samtools

FROM ubuntu:latest AS builder

# install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        build-essential \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        wget && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# compile Samtools
ENV samtoolsVer=1.11
RUN wget -q https://github.com/samtools/samtools/releases/download/${samtoolsVer}/samtools-${samtoolsVer}.tar.bz2 && \
    tar jxf samtools-${samtoolsVer}.tar.bz2 && \
    cd samtools-${samtoolsVer} && \
    ./configure --without-curses && \
    make && \
    make install

# create target container
FROM alpine:latest

COPY --from=builder /usr/local/bin/* /usr/local/bin/

LABEL software="Samtools"
LABEL software.version="1.11"
LABEL description="Samtool is a software package for mpileup and other tools for handling SAM, BAM, CRAM"
LABEL website="https://github.com/samtools/samtools"
LABEL license="https://github.com/samtools/samtools/blob/develop/LICENSE"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]