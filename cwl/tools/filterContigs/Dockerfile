# Dockerfile for filterContigs

FROM alpine:latest

RUN apk add --no-cache bash perl

COPY filterContigs.pl /usr/local/bin
RUN chmod +x /usr/local/bin/filterContigs.pl

LABEL software="removeSmallContigs"
LABEL software.version="0.0.3"
LABEL description="Quick tool to filter contigs by size a Fastas input"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]