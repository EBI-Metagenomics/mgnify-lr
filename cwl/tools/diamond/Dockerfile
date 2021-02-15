# Dockerfile for DIAMOND
FROM ubuntu:latest

ENV diamondVer=2.0.7

RUN apt update && \
    apt upgrade -y && \
    apt install -y wget

WORKDIR /usr/local/bin
RUN wget -q https://github.com/bbuchfink/diamond/releases/download/v${diamondVer}/diamond-linux64.tar.gz \
    && tar zxf diamond-linux64.tar.gz \
    && rm diamond-linux64.tar.gz \
    && chmod a+x diamond

RUN mkdir /data
WORKDIR /data

LABEL software="DIAMOND"
LABEL software.version="2.0.7"
LABEL description="DIAMOND is a sequence aligner for protein and translated DNA searches, designed for high performance analysis of big sequence data"
LABEL website="https://github.com/bbuchfink/diamond"
LABEL license="https://github.com/bbuchfink/diamond/blob/master/LICENSE"

CMD ["/bin/bash", "-c"]