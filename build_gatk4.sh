#!/bin/bash

source install_gatk4_prereqs.sh

# Build
cd $HOME
git clone https://github.com/broadinstitute/gatk.git

#cd gatk
./gradlew bundle


