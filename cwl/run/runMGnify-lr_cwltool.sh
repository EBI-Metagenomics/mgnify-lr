#!/bin/bash

# Script to launch a GCP-Slurm job using cwltool for the MGnify-lr pipeline
# (c) 2020 EMBL- EBI

# clone of mgnify-lr repo
export PIPELINE_FOLDER=/home/jcaballero_ebi_ac_uk/mgnify-lr

# pipeline run dir
export PIPELINE_RUN_DIR=/home/jcaballero_ebi_ac_uk/data

# defaults
export TYPE=null                                        # analysis type: {assembly, hybrid, polish}
export FORWARD_READS=null                               # path to illumina first pair reads fastq file
export REVERSE_READS=null                               # path to illumina second pair reads fastq file
export SINGLE=null                                      # path to long read fastq file
export TECH=null                                        # long-reads technology {nanopore, pacbio}
export HOSTFA=null                                      # path to genome fasta if host filtering is used
export UNIPROT=$PIPELINE_FOLDER/cwl/db/uniprot.dmnd     # path to uniprot index (diamond)
export MEDAKA=r941_min_high_g360                        # medaka model to use
export MINILL=50                                        # minimal size for illumina reads
export MINNANO=200                                      # minimal size for nanopore reads
export MINCONTIG=500                                    # minimal size for assembled contigs
export PROJECTID=null                                   # Project ID to store results ([ESD]RPXXXX)
export NAME=null                                        # File prefix for output files
export DOCKER="True"                                    # flag to use docker
export RESTART="False"                                  # flag to try to restart a failed run

# max limit of memory that would be used by toil to restart
export MEMORY=100
# number of cores to run toil
export NUM_CORES=32


export RUN_DIR=/data/juan/runs

while getopts :a:d:f:h:l:m:n:r:s:t:u:z:i:j:k:g:p:c:x: option; do
    case "${option}" in
        m) MEMORY=${OPTARG};;
        n) NUM_CORES=${OPTARG};;
        t) TYPE=${OPTARG};;
        f) FORWARD_READS=${OPTARG};;
        r) REVERSE_READS=${OPTARG};;
        a) NAME=${OPTARG};;
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
        p) PROJECTID=${OPTARG};;
        x) RESTART=${OPTARG};;
        *) echo "invalid option: $option"; exit;;
    esac
done

# Input validations
if [ "$PROJECTID" == "null" ]
then
    echo "PROJECTID (-p) is missing"
    exit 1
fi

if [ "$SINGLE" == "null" ]
then
    echo "Long-reads fastq file (-s) is missing"
    exit 1
fi


if [ "$TYPE" != "assembly" ]
then
    if [ "$FORWARD" == "null" ]
    then
        echo "Hybrid mode detected, missing first short-read file (-f)"
        exit 1
    fi
    if [ "$REVERSE" == "null" ]
    then
        echo "Hybrid mode detected, missing second short-read file (-r)"
        exit 1
    fi
    
    if [ "$NAME" == "null" ]
    then
        NAME=$(basename "$FORWARD" _1.fastq.gz)
    fi
fi

if [ -f "$SINGLE" ]
then
    if [ "$NAME" == "null" ]
    then
        NAME=$(basename "$SINGLE" .fastq.gz)
    fi
else
    echo "Long-read file $SINGLE is not readable" 
    exit 1
fi


## Singularity CACHE
module load singularity/3.7.3
export SINGULARITY_HOME=$PIPELINE_FOLDER/singularity
export SINGULARITY_CACHEDIR=$SINGULARITY_HOME/cache
export SINGULARITY_TMPDIR=$SINGULARITY_HOME/tmp
export SINGULARITY_LOCALCACHEDIR=$SINGULARITY_HOME/local_tmp
export SINGULARITY_PULLFOLDER=$SINGULARITY_HOME/pull
export SINGULARITY_BINDPATH=$SINGULARITY_HOME/scratch
export CWL_SINGULARITY_CACHE=$SINGULARITY_HOME/cache

MEMORY="${MEMORY}G"

echo "Activating envs"
if [ "$DOCKER" == "True" ]
then
    # Activate just toil env as tools will be run in containers
    source "$PIPELINE_FOLDER/miniconda3/bin/activate" toil-5.3.0
else
    # Activate full conda env with tools
    source "$PIPELINE_FOLDER/miniconda3/bin/activate" mgnify-lr
fi

# ----------------------------- preparation -----------------------------
# run_folder
PROJPREFIX=$(echo "$PROJECTID" | perl -lane 'print $1 if (m/([EDS]RP\d\d\d\d)/)')
export RUN_DIR=$PIPELINE_RUN_DIR/$PROJPREFIX/$PROJECTID/toil
if [ ! -d "$RUN_DIR" ]; then mkdir -p "$RUN_DIR"; fi

# work dir
export WORK_DIR=${RUN_DIR}/work-dir
export JOB_TOIL_FOLDER=${WORK_DIR}/job-store-wf
export TMPDIR=${WORK_DIR}/tmp/${NAME}

# result dir
export OUT_DIR=${RUN_DIR}
export LOG_DIR=${OUT_DIR}/log-dir/${NAME}
export OUT_DIR_FINAL=${OUT_DIR}/results/${NAME}
export OUT_JSON=${OUT_DIR_FINAL}/out.json

if [ "$RESTART" == "False" ]
then
    echo "Create empty ${LOG_DIR}, ${JOB_TOIL_FOLDER} and ${OUT_DIR_FINAL}"
    mkdir -p "${LOG_DIR}" "${OUT_DIR_FINAL}" "${JOB_TOIL_FOLDER}"
else 
    echo "restart mode detected, reusing dirs"
fi

# ----------------------------- configs  -----------------------------
export RUN_YML=${OUT_DIR_FINAL}/${NAME}.yaml
export YML_SCRIPT=${PIPELINE_FOLDER}/cwl/utils/createYML.py

export PARAM="-m $TYPE -r $SINGLE -l $MINNANO -k $MEDAKA -c $MINCONTIG -p $NAME -t $TECH -u $UNIPROT"

if [ "$HOSTFA" != "null" ]; then PARAM="$PARAM -g $HOSTFA"; fi

case $TYPE in
    assembly)
        export CWL=${PIPELINE_FOLDER}/cwl/workflows/long_read_assembly.cwl
    ;;
    hybrid)
        PARAM="$PARAM -1 $FORWARD_READS -2 $REVERSE_READS -i $MINILL"
        export CWL=${PIPELINE_FOLDER}/cwl/workflows/hybrid_read_assembly.cwl
    ;;
    polish)
        PARAM="$PARAM -1 $FORWARD_READS -2 $REVERSE_READS -i $MINILL"
        export CWL=${PIPELINE_FOLDER}/cwl/workflows/long_read_assembly_polish.cwl
    ;;
    *)
        echo "unsuported analysis types: $TYPE"
        exit 1
    ;;
esac

if [ "$RESTART" == "False" ]
then
    echo "creating YAML file:"
    echo "python3 $YML_SCRIPT $PARAM -o $RUN_YML"
    python3 "$YML_SCRIPT" $PARAM -o "$RUN_YML"
else 
    echo "reusing YAML file: $RUN_YML"
fi

# ----------------------------- running pipeline -----------------------------
echo "Running with:
CWL: $CWL
YML: $RUN_YML"

echo "Job start: $(date)"

cd "$WORK_DIR" || exit

if [ "$RESTART" == "False" ]
then
    USERESTART=" "
else
    USERESTART="--restart"
fi

if [ "$DOCKER" == "True" ]
then
    USEDOCKER="--singularity"
else
    USEDOCKER="--no-container"
fi

echo "launching CWL job as $NAME, Docker: $DOCKER, Restart: $RESTART"
CMD="cwltool \
  --preserve-entire-environment \
  --enable-dev \
  --tmp-outdir-prefix $TMPDIR \
  --tmpdir-prefix $TMPDIR \
  $USEDOCKER \
  $CWL \
  $RUN_YML"

echo "$CMD"
$CMD
EXIT_CODE=$?


echo "Job finish: $(date)"
sleep 1m

echo "EXIT: $EXIT_CODE"
