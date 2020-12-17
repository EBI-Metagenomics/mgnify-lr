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
export DOCKER="False"        # flag to use singularity+docker

# max limit of memory that would be used by toil to restart
export MEMORY=120
export RESTART_MEMORY=120G
# number of cores to run toil
export NUM_CORES=8
# lsf queue limit
export LIMIT_QUEUE=100

# clone of mgnify-lr repo
export PIPELINE_FOLDER=/hps/nobackup2/production/metagenomics/jcaballero/mgnify-lr/cwl
# run_folder
export RUN_DIR=/homes/jcaballero/workdir/runs

while getopts :a:d:f:h:l:m:n:r:s:t:u:z:i:j:k:g:c: option; do
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
        z) RESTART_MEMORY=${OPTARG};;
        k) MEDAKA=${OPTARG};;
        i) MINILL=${OPTARG};;
        j) MINNANO=${OPTARG};;
        c) MINCONTIG=${OPTARG};;
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
    export TOIL_LSF_ARGS="-P bigmem -q production-rh74 -g /${USER}_${JOB_GROUP}"
else
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

echo "Create empty ${LOG_DIR} and ${OUT_DIR_FINAL}"
mkdir -p "${LOG_DIR}" "${OUT_DIR_FINAL}" "${JOB_TOIL_FOLDER}"

# ----------------------------- configs  -----------------------------
export RUN_YML=${OUT_DIR_FINAL}/${NAME_RUN}.yml
export YML_SCRIPT=${PIPELINE_FOLDER}/utils/createYML.py

export PARAM="-m $TYPE -r $SINGLE -l $MINNANO -k $MEDAKA -c $MINCONTIG -p $NAME_RUN -t $TECH"

if [ "$UNIPROT" != "null" ]; then PARAM="$PARAM -u $UNIPROT"; fi
if [ "$HOSTFA" != "null" ]; then PARAM="$PARAM -g $HOSTFA"; fi

case $TYPE in
    assembly)
        if [ "$HOSTFA" == "null" ]
        then
            export CWL=${PIPELINE_FOLDER}/workflows/long_read_assembly_noHost.cwl
        else
            export CWL=${PIPELINE_FOLDER}/workflows/long_read_assembly.cwl
        fi
        ;;
    polish)
        PARAM="$PARAM -1 $FORWARD_READS -2 $REVERSE_READS -i $MINILL"
        if [ "$HOSTFA" == "null" ]
        then
            export CWL=${PIPELINE_FOLDER}/workflows/long_read_assembly_noHost_polish.cwl
        else
            export CWL=${PIPELINE_FOLDER}/workflows/long_read_assembly_polish.cwl
        fi
        ;;
    hybrid)
        PARAM="$PARAM -1 $FORWARD_READS -2 $REVERSE_READS -i $MINILL"
        if [ "$HOSTFA" == "null" ]
        then
            export CWL=${PIPELINE_FOLDER}/workflows/hybrid_read_assembly_noHost.cwl
        else
            export CWL=${PIPELINE_FOLDER}/workflows/hybrid_read_assembly.cwl
        fi
        ;;
    *)
        echo "unsuported analysis: $TYPE"
        exit 1
        ;;
esac

echo "creating YAML file:"
echo python3 $YML_SCRIPT $PARAM -o $RUN_YML
python3 $YML_SCRIPT $PARAM -o $RUN_YML

# ----------------------------- running pipeline -----------------------------
echo "Running with:
CWL: ${CWL}
YML: ${RUN_YML}"

mkdir -p "${TMPDIR}"  && \
echo "Toil start: $(date)"

cd ${WORK_DIR} || exit

if [ "${DOCKER}" == "True" ]; then
    toil-cwl-runner \
      --preserve-entire-environment --enable-dev --disableChaining \
      --logFile ${LOG_DIR}/${NAME_RUN}.log \
      --jobStore ${JOB_TOIL_FOLDER}/${NAME_RUN} --outdir ${OUT_DIR_FINAL} \
      --singularity --batchSystem lsf --disableCaching \
      --defaultMemory ${MEMORY} --defaultCores ${NUM_CORES} --retryCount 5 \
      --cleanWorkDir=never --clean=never --stats \
    ${CWL} ${RUN_YML} > ${OUT_JSON}
    EXIT_CODE=$?
elif [ "${DOCKER}" == "False" ]; then
    toil-cwl-runner \
      --preserve-entire-environment --enable-dev --disableChaining \
      --logFile ${LOG_DIR}/${NAME_RUN}.log \
      --jobStore ${JOB_TOIL_FOLDER}/${NAME_RUN} --outdir ${OUT_DIR_FINAL} \
      --no-container --batchSystem lsf --disableCaching \
      --defaultMemory ${MEMORY} --defaultCores ${NUM_CORES} --retryCount 5 \
      --cleanWorkDir=never --clean=never --stats \
    ${CWL} ${RUN_YML} > ${OUT_JSON}
    EXIT_CODE=$?
fi

echo "Toil finish:" ; date ; sleep 1m

echo "EXIT: $EXIT_CODE"
