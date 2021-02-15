# Dockerfile for AssemblyStats

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

COPY calc_stats.pl /usr/local/bin/
COPY gen_stats_json.pl /usr/local/bin/
RUN chmod +x /usr/local/bin/*

LABEL software="AssemblyStats"
LABEL software.version="0.0.4"
LABEL description="Tools to compute assembly statistics (N50, coverage, contigs, ...)"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]