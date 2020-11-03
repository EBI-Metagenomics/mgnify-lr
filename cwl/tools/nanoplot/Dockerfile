# Docker container for NanoPlot

FROM ubuntu:latest AS builder

ARG nanoplotVer=1.33.1

ENV DEBIAN_FRONTEND noninteractive
# install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        zlib1g-dev \
        bzip2 \
        libbz2-dev \
        liblzma-dev \
        libcurl4-gnutls-dev \
        libncurses5-dev \
        libssl-dev \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-venv

RUN python3 -m venv /opt/venv

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

# install NanoPlot and deps
RUN pip3 install matplotlib psutil requests NanoPlot==${nanoplotVer} 

# main container
FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python3-minimal && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv

# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

# for singularity compatibility
ENV LC_ALL=C

LABEL software="NanoPlot"
LABEL software.version="1.33.1"
LABEL description="Plotting suite for Oxford Nanopore sequencing data and alignments"
LABEL website="https://github.com/wdecoster/NanoPlot"
LABEL license="https://github.com/wdecoster/NanoPlot/blob/master/LICENSE"

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]
