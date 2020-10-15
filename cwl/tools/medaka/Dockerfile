FROM ubuntu:latest as builder

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python3 \
        python3-pip \
        build-essential \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        git \
        bzip2 \
        libffi-dev \
        libncurses5-dev \
        libcurl4-gnutls-dev \
        libssl-dev \
        cmake \
        curl \
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

# compile minimap2
RUN git clone https://github.com/lh3/minimap2 && \
    cd minimap2 && \
    make && \
    cp minimap2 /usr/local/bin

# get and install tabix
RUN git clone https://github.com/samtools/htslib.git && \
    cd htslib && \
    make && \
    make install

# get and install bcftools
RUN git clone git://github.com/samtools/bcftools.git && \
    cd bcftools && \
    make && \
    make install

RUN pip3 install --user medaka

# create target container
FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python3

COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder /root/.local/bin /root/.local

LABEL software="Medaka"
LABEL software.version="1.1.3"
LABEL description="Medaka is a tool to create consensus sequences and variant calls from nanopore sequencing data."
LABEL website="https://github.com/nanoporetech/medaka"
LABEL license="https://github.com/nanoporetech/medaka/blob/master/LICENSE.md"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash" "-c"]