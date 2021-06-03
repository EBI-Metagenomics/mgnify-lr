#!/bin/bash

# Script to launch a LSF job using toil for the MGnify-lr pipeline
# (c) 2021 EMBL- EBI

# clone of mgnify-lr repo
export PIPELINE_FOLDER=/nfs/production/metagenomics/production/mgnify-lr

# pipeline run dir
export PIPELINE_RUN_DIR=/hps/nobackup2/production/metagenomics/results/assemblies


# defaults
export TYPE=assembly                                    # analysis type: {assembly, hybrid, polish}
export FORWARD_READS=null                               # path to illumina first pair reads fastq file
export REVERSE_READS=null                               # path to illumina second pair reads fastq file
export SINGLE=null                                      # path to long-read fastq file
export TECH=nanopore                                    # long-reads technology {nanopore, pacbio}
export HOSTFA=null                                      # path to genome fasta for host filtering
export UNIPROT=$PIPELINE_FOLDER/cwl/db/uniprot.dmnd     # path to uniprot index (diamond)
export MEDAKA=r941_min_high_g360                        # medaka model to use
export MINILL=50                                        # minimal size for illumina reads
export MINNANO=200                                      # minimal size for nanopore reads
export MINCONTIG=500                                    # minimal size for assembled contigs
export PROJECTID=null                                   # Project ID to store results ([ESD]RPXXXX)
export NAME=null                                        # File prefix for output files
export DOCKER="True"                                    # flag to use singularity+docker
export RESTART="False"                                  # flag to try to restart a failed run

# Default memory if not specified or step needs more that the one defined in CWL
export MEMORY=100
# number of cores to run
export NUM_CORES=32
# lsf queue limit
export LIMIT_QUEUE=100

# Parse parameters
while getopts :a:d:f:h:l:m:n:r:s:t:u:z:i:j:k:g:c:p:x: option; do
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
    if [ "$FORWARD_READS" == "null" ]
    then
        echo "Hybrid mode detected, missing first short-read file (-f)"
        exit 1
    fi
    if [ "$REVERSE_READS" == "null" ]
    then
        echo "Hybrid mode detected, missing second short-read file (-r)"
        exit 1
    fi
    
    if [ "$NAME" == "null" ]
    then
        NAME=$(basename "$FORWARD_READS" _1.fastq.gz)
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
module load singularity/3.5.0
export SINGULARITY_HOME=$PIPELINE_FOLDER/singularity
export SINGULARITY_CACHEDIR=$SINGULARITY_HOME/cache
export SINGULARITY_TMPDIR=$SINGULARITY_HOME/tmp
export SINGULARITY_LOCALCACHEDIR=$SINGULARITY_HOME/local_tmp
export SINGULARITY_PULLFOLDER=$SINGULARITY_HOME/pull
export SINGULARITY_BINDPATH=$SINGULARITY_HOME/scratch
export CWL_SINGULARITY_CACHE=$SINGULARITY_HOME/cache

# ----------------------------- Toil and envs -----------------------------
# Create job groups so we do not run too many jobs at the same time for parallelizable steps.
export JOB_GROUP=mgnify-lr
bgadd -L "${LIMIT_QUEUE}" /"${USER}_${JOB_GROUP}" > /dev/null
bgmod -L "${LIMIT_QUEUE}" /"${USER}_${JOB_GROUP}" > /dev/null

# using bigmem queue by default
export TOIL_LSF_ARGS="-P bigmem -q production-rh74 -g /${USER}_${JOB_GROUP}"
MEMORY="${MEMORY}G"

echo "Activating envs"
if [ "$DOCKER" == "True" ]
then
    # Activate just toil env as tools will be run in containers
    source "$PIPELINE_FOLDER/miniconda3/bin/activate" toil-5.2.0
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
    echo "Create empty ${LOG_DIR}, ${JOB_TOIL_FOLDER}, ${TMPDIR} and ${OUT_DIR_FINAL}"
    mkdir -p "${LOG_DIR}" "${OUT_DIR_FINAL}" "${JOB_TOIL_FOLDER}" "${TMPDIR}"
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

echo "Toil start: $(date)"

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

echo "launching TOIL/CWL job as $NAME, Docker: $DOCKER, Restart: $RESTART"
CMD="toil-cwl-runner \
  --preserve-entire-environment \
  --enable-dev \
  --logFile $LOG_DIR/$NAME.log \
  --jobStore $JOB_TOIL_FOLDER/$NAME \
  --outdir $OUT_DIR_FINAL \
  --batchSystem lsf \
  --disableCaching \
  --tmpdir-prefix $TMPDIR \
  --tmp-outdir-prefix $TMPDIR \
  --defaultMemory $MEMORY \
  --defaultCores $NUM_CORES \
  --retryCount 5 \
  --stats \
  --doubleMem \
  $USEDOCKER \
  $USERESTART \
  $CWL \
  $RUN_YML"

echo "$CMD"
$CMD
EXIT_CODE=$?


echo "Toil finish: $(date)"
sleep 1m

if [ "$EXIT_CODE" == "0" ]
then
    echo "retriving run stats"
    toil stats --raw "$JOB_TOIL_FOLDER/$NAME" > "$OUT_DIR_FINAL/toil_stats.json"

    if [ -e "$OUT_DIR_FINAL/assembly_stats.json" ]
    then
        echo "adding run stats in assembly_stats.json"
        python3 $PIPELINE_FOLDER/cwl/utils/addRunStats.py \
                    -t "$OUT_DIR_FINAL/toil_stats.json" \
                    -a "$OUT_DIR_FINAL/assembly_stats.json"
    else
        echo "no assembly_stats.json found"
    fi

    if [ "$PROJECTID" == "null" ]
    then
        echo "no project_id, not moving results"
    else
        echo "moving results to final destination"
        RAW_READS=${SINGLE}
        if [ -e "$FORWARD_READS" ]; then RAW_READS="$RAW_READS,$FORWARD_READS,$REVERSE_READS"; fi

        GRAPH_PARAM=" "
        if [ "$TYPE" == "hybrid" ]
        then
            GRAPH_PARAM="-f $OUT_DIR_FINAL/*.fastg -g $OUT_DIR_FINAL/*.gfa"
        fi
        
        CMD="bash $PIPELINE_FOLDER/cwl/utils/prepare_upload.sh \
            -p $PROJECTID \
            -c $OUT_DIR_FINAL/${NAME}_final.fasta \
            -r $RAW_READS \
            -a $OUT_DIR_FINAL/assembly_stats.json \
            -y $RUN_YML \
            ${GRAPH_PARAM}"
        echo "$CMD"
        $CMD
    fi
else
    echo "JOB FAILED, NOT FINAL STEPS"
fi

echo "EXIT: $EXIT_CODE"
