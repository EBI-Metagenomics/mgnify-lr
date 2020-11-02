# Docker container for NanoPlot

FROM conda/miniconda3:latest

ARG nanoplotVer=1.33.1

ENV DEBIAN_FRONTEND noninteractive
RUN conda update -n base -c defaults conda && \
    conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda install nanoplot && \
    conda clean -a


# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

LABEL software="NanoPlot"
LABEL software.version=${nanoplotVer}
LABEL description="Plotting suite for Oxford Nanopore sequencing data and alignments"
LABEL website="https://github.com/wdecoster/NanoPlot"
LABEL license="https://github.com/wdecoster/NanoPlot/blob/master/LICENSE"

CMD ["/bin/bash", "-c"]