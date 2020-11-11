#!/bin/bash

# create a conda enviroment for mgnify-lr
# (C) 2020 EMBL-EBI

echo "creating conda enviroment"
conda create --name mgnify-lr -f conda_env.yml

echo "adding extra scripts"
TARGET="$CONDA_PREFIX/env/mgnify-lr/bin"
for SCRIPT in $(cat conda_scripts.txt)
do
    cp $SCRIPT $TARGET
    chmod +x $TARGET/$(basename $SCRIPT)
done
