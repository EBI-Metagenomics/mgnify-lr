FROM alpine:latest

RUN apk add --no-cache bash

COPY removeSmallReads.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/removeSmallReads.sh

LABEL software="removeSmallReads"
LABEL software.version="0.0.1"
LABEL description="Quick tool to remove small reads in a Fastq input"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]