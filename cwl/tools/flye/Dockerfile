# Docker container for Flye

FROM ubuntu:latest

ARG flyeVer=2.8.1

LABEL software="Flye"
LABEL software.version="2.8.1"
LABEL description="Flye is a de novo assembler for single molecule sequencing reads, such as those produced by PacBio and Oxford Nanopore Technologies."
LABEL website="https://github.com/fenderglass/Flye"
LABEL license="https://github.com/fenderglass/Flye/blob/flye/LICENSE"

# install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python3 \
        python3-setuptools \
        build-essential \
        zlib1g-dev \
        wget && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

# for singularity compatibility
ENV LC_ALL=C

# install Flye
WORKDIR /opt
RUN wget -q https://github.com/fenderglass/Flye/archive/${flyeVer}.tar.gz && \
    tar zxf ${flyeVer}.tar.gz && \
    rm ${flyeVer}.tar.gz && \
    cd Flye-${flyeVer} && \
    make && \
    ln -s /opt/Flye-${flyeVer}/bin/flye /usr/local/bin

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]