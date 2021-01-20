#!/bin/bash

# Script to launch a LSF job using toil for the MGnify-lr pipeline
# (c) 2020 EMBL- EBI

# defaults
export TYPE=null             # analysis type: {assembly, hybrid, polish}
export FORWARD_READS=null    # path to illumina first pair reads fastq file
export REVERSE_READS=null    # path to illumina second pair reads fastq file
export SINGLE=null           # path to nanopore read fastq file
export TECH=null             # long-reads technology (nanopore/pacbio)
export HOSTFA=null           # path to genome fasta
export UNIPROT=null          # path to uniprot index (diamond)
export MEDAKA=r941_min_high_g360  # medaka model to use
export MINILL=50             # minimal size for illumina reads
export MINNANO=200           # minimal size for nanopore reads
export MINCONTIG=500         # minimal size for assembled contigs
export DOCKER="True"         # flag to use singularity+docker
export RESTART="False"       # flag to try to restart a failed run

# max limit of memory that would be used by toil to restart
export MEMORY=100
# number of cores to run toil
export NUM_CORES=8
# lsf queue limit
export LIMIT_QUEUE=100

## Singularity CACHE
module load singularity/3.5.0
export SINGULARITY_HOME=/hps/nobackup2/production/metagenomics/jcaballero/singularity
export SINGULARITY_CACHEDIR=$SINGULARITY_HOME/cache
export SINGULARITY_TMPDIR=$SINGULARITY_HOME/tmp
export SINGULARITY_LOCALCACHEDIR=$SINGULARITY_HOME/local_tmp
export SINGULARITY_PULLFOLDER=$SINGULARITY_HOME/pull
export SINGULARITY_BINDPATH=$SINGULARITY_HOME/scratch
export CWL_SINGULARITY_CACHE=$SINGULARITY_HOME/cache

# clone of mgnify-lr repo
export PIPELINE_FOLDER=/hps/nobackup2/production/metagenomics/jcaballero/mgnify-lr/cwl
# run_folder
export RUN_DIR=/hps/nobackup2/production/metagenomics/jcaballero/runs

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
# Create job groups so we do not run too many jobs at the same time for parallelizable steps.
export JOB_GROUP=mgnify-lr
bgadd -L "${LIMIT_QUEUE}" /"${USER}_${JOB_GROUP}" > /dev/null
bgmod -L "${LIMIT_QUEUE}" /"${USER}_${JOB_GROUP}" > /dev/null

if [ "$MEMORY" -ge "100" ]
then
    echo "High memory requested, using bigmem queue"
    export TOIL_LSF_ARGS="-P bigmem -q production-rh74 -g /${USER}_${JOB_GROUP}"
else
    echo "Using regular queue"
    export TOIL_LSF_ARGS="-q production-rh74 -g /${USER}_${JOB_GROUP}"
fi
MEMORY="${MEMORY}G"

echo "Activating envs"
source /hps/nobackup2/production/metagenomics/jcaballero/miniconda3/bin/activate mgnify-lr

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
        export CWL=${PIPELINE_FOLDER}/workflows/long_read_assembly_noHost.cwl
    ;;
    hybrid)
        PARAM="$PARAM -1 $FORWARD_READS -2 $REVERSE_READS -i $MINILL"
        export CWL=${PIPELINE_FOLDER}/workflows/hybrid_read_assembly_noHost.cwl
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
        echo "launching TOIL/CWL job with Singularity/Docker as ${NAME_RUN}"
        toil-cwl-runner \
            --preserve-entire-environment \
            --enable-dev \
            --logFile ${LOG_DIR}/${NAME_RUN}.log \
            --jobStore ${JOB_TOIL_FOLDER}/${NAME_RUN} \
            --outdir ${OUT_DIR_FINAL} \
            --singularity \
            --batchSystem lsf \
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
            --batchSystem lsf \
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
