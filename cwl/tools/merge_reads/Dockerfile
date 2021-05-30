# Dockerfile for merge_reads

FROM ubuntu:latest

RUN apt update && \
    apt upgrade -y

COPY merge_reads.pl /usr/local/bin/
RUN chmod +x /usr/local/bin/merge_reads.pl

LABEL software="Merge Reads"
LABEL software.version="0.0.2"
LABEL description="This is a simple tool to merge paired-end Fastq files."

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]
