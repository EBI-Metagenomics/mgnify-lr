# Dockerfile for Prodigal
FROM alpine:latest

ENV prodigalVer=2.6.3

RUN apk add --no-cache bash

WORKDIR /usr/local/bin
RUN wget -q -O prodigal https://github.com/hyattpd/Prodigal/releases/download/v${prodigalVer}/prodigal.linux
RUN chmod +x /usr/local/bin/prodigal

RUN mkdir /data
WORKDIR /data

LABEL software="prodigal"
LABEL software.version="2.6.3"
LABEL description=""
LABEL website="https://github.com/hyattpd/Prodigal"
LABEL license="https://github.com/hyattpd/Prodigal/blob/GoogleImport/LICENSE"

CMD ["/bin/bash", "-c"]