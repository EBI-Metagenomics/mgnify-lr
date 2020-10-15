# Docker file for Pilon

FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV pilonVer=1.23

LABEL software="pilon"
LABEL software.version="1.23"
LABEL description="Pilon is a software tool to automatically improve draft assemblies and to find variation among strains, including large event detection."
LABEL website="https://github.com/broadinstitute/pilon"
LABEL license="https://github.com/broadinstitute/pilon/blob/master/LICENSE"

# install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        default-jre-headless \
        wget

WORKDIR /opt
RUN wget -q https://github.com/broadinstitute/pilon/releases/download/v${pilonVer}/pilon-${pilonVer}.jar && \
    mv pilon-${pilonVer}.jar pilon.jar

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]
