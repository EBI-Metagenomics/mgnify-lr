FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python3 \
        python3-pip \
        samtools \
        tabix \
        bcftools \
        minimap2

RUN pip3 install medaka