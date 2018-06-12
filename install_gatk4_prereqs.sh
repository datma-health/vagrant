#!/bin/bash

# Prerequisites
echo "Installing GATK4 Prerequisites..."

sudo yum install -y epel-release
https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash
sudo yum install -y git-lfs
git lfs install
sudo yum install -y R

echo "Installing GATK4 Prerequisites DONE"

