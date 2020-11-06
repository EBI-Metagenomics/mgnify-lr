# Dockerfile for minimap2

FROM ubuntu:latest

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        wget \
        samtools

ENV minimap2Ver=2.17
WORKDIR /opt
RUN wget -q https://github.com/lh3/minimap2/releases/download/v${minimap2Ver}/minimap2-${minimap2Ver}_x64-linux.tar.bz2 && \
    tar jxf minimap2-${minimap2Ver}_x64-linux.tar.bz2 && \
    cp minimap2-${minimap2Ver}_x64-linux/minimap2 /usr/local/bin && \
    rm -rf minimap2-${minimap2Ver}_x64-linux*

COPY minimap2_filter.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/minimap2_filter.sh

LABEL software="Minimap2"
LABEL software.version="2.17"
LABEL description="Minimap2 is a versatile sequence alignment program that aligns DNA or mRNA sequences against a large reference database."
LABEL website="https://github.com/lh3/minimap2"
LABEL license="https://github.com/lh3/minimap2/blob/master/LICENSE.txt"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]