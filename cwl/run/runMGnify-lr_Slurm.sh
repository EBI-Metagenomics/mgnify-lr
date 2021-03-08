#!/bin/bash

# Script to launch a LSF job using toil for the MGnify-lr pipeline
# (c) 2020 EMBL- EBI

# defaults
export TYPE=null             # analysis type: {assembly, hybrid}
export FORWARD_READS=null    # path to illumina first pair reads fastq file
export REVERSE_READS=null    # path to illumina second pair reads fastq file
export SINGLE=null           # path to long read fastq file
export TECH=null             # long-reads technology {nanopore, pacbio}
export HOSTFA=null           # path to genome fasta if host filtering is used
export UNIPROT=/data/juan/mgnify-lr/cwl/db/uniprot.dmnd   # path to uniprot index (diamond)
export MEDAKA=r941_min_high_g360  # medaka model to use
export MINILL=50             # minimal size for illumina reads
export MINNANO=200           # minimal size for nanopore reads
export MINCONTIG=500         # minimal size for assembled contigs
export DOCKER="True"         # flag to use docker
export RESTART="False"       # flag to try to restart a failed run

# max limit of memory that would be used by toil to restart
export MEMORY=40
# number of cores to run toil
export NUM_CORES=8

# clone of mgnify-lr repo
export PIPELINE_FOLDER=/data/juan/mgnify-lr/cwl
# run_folder
export RUN_DIR=/data/juan/runs

while getopts :a:d:f:h:l:m:n:r:s:t:u:z:i:j:k:g:c:x: option; do
    case "${option}" in
        m) MEMORY=${OPTARG};;
        n) NUM_CORES=${OPTARG};;
        t) TYPE=${OPTARG};;
        f) FORWARD_READS=${OPTARG};;
        r) REVERSE_READS=${OPTARG};;
        a) NAME_RUN=${OPTARG};;
        s) SINGLE=${OPTARG};;
        h) TECH=${OPTARG};;
        g) HOSTFA=${OPTARG};;
        u) UNIPROT=${OPTARG};;
        d) DOCKER=${OPTARG};;
        l) LIMIT_QUEUE=${OPTARG};;
        k) MEDAKA=${OPTARG};;
        i) MINILL=${OPTARG};;
        j) MINNANO=${OPTARG};;
        c) MINCONTIG=${OPTARG};;
        x) RESTART=${OPTARG};;
        *) echo "invalid option: $option"; exit;;
    esac
done
# ----------------------------- Toil and envs -----------------------------
export TOIL_SLURM_ARGS=""

echo "Activating envs"
source /data/juan/miniconda3/bin/activate toil

# ----------------------------- preparation -----------------------------
# work dir
export WORK_DIR=${RUN_DIR}/work-dir
export JOB_TOIL_FOLDER=${WORK_DIR}/job-store-wf
export TMPDIR=${WORK_DIR}/tmp/${NAME_RUN}

# result dir
export OUT_DIR=${RUN_DIR}
export LOG_DIR=${OUT_DIR}/log-dir/${NAME_RUN}
export OUT_DIR_FINAL=${OUT_DIR}/results/${NAME_RUN}
export OUT_JSON=${OUT_DIR_FINAL}/out.json

if [ "$RESTART" == "False" ]
then
    echo "Create empty ${LOG_DIR} and ${OUT_DIR_FINAL}"
    mkdir -p "${LOG_DIR}" "${OUT_DIR_FINAL}" "${JOB_TOIL_FOLDER}"
else 
    echo "restart mode detected, reusing dirs"
fi

# ----------------------------- configs  -----------------------------
export RUN_YML=${OUT_DIR_FINAL}/${NAME_RUN}.yml
export YML_SCRIPT=${PIPELINE_FOLDER}/utils/createYML.py

export PARAM="-m $TYPE -r $SINGLE -l $MINNANO -k $MEDAKA -c $MINCONTIG -p $NAME_RUN -t $TECH"

if [ "$UNIPROT" != "null" ]; then PARAM="$PARAM -u $UNIPROT"; fi
if [ "$HOSTFA" != "null" ]; then PARAM="$PARAM -g $HOSTFA"; fi

case $TYPE in
    assembly)
        export CWL=${PIPELINE_FOLDER}/workflows/long_read_assembly.cwl
    ;;
    hybrid)
        PARAM="$PARAM -1 $FORWARD_READS -2 $REVERSE_READS -i $MINILL"
        export CWL=${PIPELINE_FOLDER}/workflows/hybrid_read_assembly.cwl
    ;;
    *)
        echo "unsuported analysis types: $TYPE"
        exit 1
    ;;
esac

if [ "$RESTART" == "False" ]
then
    echo "creating YAML file:"
    echo python3 $YML_SCRIPT $PARAM -o $RUN_YML
    python3 $YML_SCRIPT $PARAM -o $RUN_YML
else 
    echo "reusing YAML file: $RUN_YML"
fi

# ----------------------------- running pipeline -----------------------------
echo "Running with:
CWL: ${CWL}
YML: ${RUN_YML}"

echo "Toil start: $(date)"

cd ${WORK_DIR} || exit

if [ "$RESTART" == "False" ]
then
    if [ "${DOCKER}" == "True" ]
    then
        echo "launching TOIL/CWL job with Docker as ${NAME_RUN}"
        toil-cwl-runner \
            --preserve-entire-environment \
            --enable-dev \
            --logFile ${LOG_DIR}/${NAME_RUN}.log \
            --jobStore ${JOB_TOIL_FOLDER}/${NAME_RUN} \
            --outdir ${OUT_DIR_FINAL} \
            --batchSystem slurm \
            --disableCaching \
            --defaultMemory ${MEMORY} \
            --defaultCores ${NUM_CORES} \
            --retryCount 5 \
            --stats \
            ${CWL} ${RUN_YML} > ${OUT_JSON}
        EXIT_CODE=$?
    elif [ "${DOCKER}" == "False" ]
    then
        echo "launching TOIL/CWL job as ${NAME_RUN}"
        toil-cwl-runner \
            --preserve-entire-environment \
            --enable-dev \
            --logFile ${LOG_DIR}/${NAME_RUN}.log \
            --jobStore ${JOB_TOIL_FOLDER}/${NAME_RUN} \
            --outdir ${OUT_DIR_FINAL} \
            --no-container \
            --batchSystem slurm \
            --disableCaching \
            --defaultMemory ${MEMORY} \
            --defaultCores ${NUM_CORES} \
            --retryCount 5 \
            --stats \
            ${CWL} ${RUN_YML} > ${OUT_JSON}
        EXIT_CODE=$?
    fi
else
    echo "relaunching TOIL/CWL job as ${NAME_RUN}"
    toil-cwl-runner \
        --restart \
        --disableCaching \
        --preserve-entire-environment \
        --logDebug \
        --jobStore ${JOB_TOIL_FOLDER}/${NAME_RUN} \
        --enable-dev \
        --outdir ${OUT_DIR_FINAL} \
        ${CWL} ${YML}  >> ${OUT_JSON} 
    EXIT_CODE=$?
fi


echo "Toil finish: $(date)"
sleep 1m

echo "EXIT: $EXIT_CODE"
