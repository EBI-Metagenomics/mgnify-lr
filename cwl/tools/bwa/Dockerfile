# Docker container for BWA

FROM ubuntu:latest 

# install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        samtools \
        wget && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
ENV bwamem2Ver=2.1
RUN wget -q https://github.com/bwa-mem2/bwa-mem2/releases/download/v${bwamem2Ver}/bwa-mem2-${bwamem2Ver}_x64-linux.tar.bz2 && \
    tar jxf bwa-mem2-${bwamem2Ver}_x64-linux.tar.bz2 && \
    mv bwa-mem2-${bwamem2Ver}_x64-linux/bwa-mem2* /usr/local/bin/ && \
    rm -rf bwa-mem2-${bwamem2Ver}_x64-linux*

COPY bwa-mem2.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/bwa-mem2.sh
COPY bwa-mem2_filterHostFq.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/bwa-mem2_filterHostFq.sh


LABEL software="BWA-mem2"
LABEL software.version="2.1"
LABEL description="Bwa-mem2 is the next version of the bwa-mem algorithm in bwa. It produces alignment identical to bwa and is ~1.3-3.1x faster depending on the use-case, dataset and the running machine."
LABEL website="https://github.com/bwa-mem2/bwa-mem2"
LABEL license="https://github.com/bwa-mem2/bwa-mem2/blob/master/LICENSE"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]