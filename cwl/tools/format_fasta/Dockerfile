# Dockerfile for assembly_stats

FROM alpine:latest

RUN apk add --no-cache bash perl

COPY formatFasta.pl /usr/local/bin
RUN chmod +x /usr/local/bin/formatFasta.pl

LABEL software="formatFasta"
LABEL software.version="0.0.1"
LABEL description="Quick tool to format an input file as Fasta"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]