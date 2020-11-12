# Docker contained for Ideel

FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python3-matplotlib

COPY ideel.py /usr/local/bin/
RUN chmod +x /usr/local/bin/ideel.py

LABEL software="ideel"
LABEL software.version="0.0.1"
LABEL description="ideel is histogram report for mgnify-lr"
LABEL website="https://github.com/EBI-Metagenomics/mgnify-lr"
LABEL license="https://github.com/EBI-Metagenomics/mgnify-lr/blob/master/LICENSE"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]