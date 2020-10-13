# Docker container for BWA

FROM ubuntu:latest

LABEL software="BWA"
LABEL software.version="0.7.17"
LABEL description="BWA is a software package for mapping DNA sequences against a large reference genome, such as the human genome."
LABEL website="https://github.com/lh3/bwa"
LABEL license="GPLv3"

# install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        bwa \
        samtools && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]