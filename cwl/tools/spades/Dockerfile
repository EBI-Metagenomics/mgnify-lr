# Docker container for SPAdes

FROM ubuntu:latest

ARG spadesVer=3.15.2

LABEL software="SPAdes"
LABEL software.version="3.15.2"
LABEL description="SPAdes – St. Petersburg genome assembler – is an assembly toolkit containing various assembly pipelines"
LABEL website="https://github.com/ablab/spades"
LABEL license="GPLv2"

# install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python \
        wget && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

# for singularity compatibility
ENV LC_ALL=C

# install SPAdes
WORKDIR /opt
RUN wget -q https://github.com/ablab/spades/releases/download/v${spadesVer}/SPAdes-${spadesVer}-Linux.tar.gz && \
    tar zxf SPAdes-${spadesVer}-Linux.tar.gz && \
    rm SPAdes-${spadesVer}-Linux.tar.gz && \
    ln -s /opt/SPAdes-${spadesVer}-Linux/bin/* /usr/local/bin

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]