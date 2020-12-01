# Dockerfile for assembly_stats

FROM alpine:latest

RUN apk add --no-cache bash perl

COPY calc_stats.pl /usr/local/bin
RUN chmod +x /usr/local/bin/calc_stats.pl

LABEL software="assemblyStats"
LABEL software.version="0.0.1"
LABEL description="Quick tool to calculate assembly stats in a Fasta/Fastq input"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]