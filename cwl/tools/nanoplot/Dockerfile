# Docker container for NanoPlot

FROM ubuntu:latest

ARG nanoplotVer=1.33.0

LABEL software="NanoPlot"
LABEL software.version="1.33.0"
LABEL description="Plotting suite for Oxford Nanopore sequencing data and alignments"
LABEL website="https://github.com/wdecoster/NanoPlot"
LABEL license="https://github.com/wdecoster/NanoPlot/blob/master/LICENSE"

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
        locales && \
    locale-gen en_US.UTF-8 && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

# for singularity compatibility
ENV LC_ALL=C

# update pip, install NanoPlot
# matplotlib 3.1.3 to avoid warnings about some color API that isn't public anymore
RUN python3 -m pip install -U pip && \
 pip3 install matplotlib==3.1.3 psutil requests NanoPlot==${nanoplotVer} 

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]