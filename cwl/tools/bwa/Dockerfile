# Docker container for BWA

FROM ubuntu:latest AS builder

# install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        build-essential \
        zlib1g-dev \
        git && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# compile BWA
RUN git clone https://github.com/lh3/bwa.git && \
    cd bwa && \
    make

# create running container
FROM ubuntu:latest

COPY --from=builder /opt/bwa/bwa /usr/local/bin/

LABEL software="BWA"
LABEL software.version="0.7.17"
LABEL description="BWA is a software package for mapping DNA sequences against a large reference genome, such as the human genome."
LABEL website="https://github.com/lh3/bwa"
LABEL license="GPLv3"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]