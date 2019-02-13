#!/bin/bash

SCRIPT_PATH="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
SCRIPT_DIR="$(dirname "${cur_file}")"
pushd ${SCRIPT_DIR}

# Get the GPK Key for installing Elastic components
if [[ ! -f /etc/yum.repos.d/elastic.repo ]]; then
  sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
  sudo cp configs/elastic.repo /etc/yum.repos.d/
fi

# FileBeat
if [[ -d /etc/filebeat ]]; then
  echo "Filebeat seems to be already installed"
else
  echo "Installing FileBeat..."
  sudo yum install -y filebeat
  sudo systemctl enable filebeat
  if [[ $# -eq 2 ]]; then
    if [[ $1 -eq "--configure" ]]; then
       # configure filebeat 
       echo "Copying preconfigured filebeat.yml"
       sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.orig
       sudo cp configs/filebeat/filebeat.yml /etc/filebeat/filebeat.yml
    fi
  fi
  echo "Enabling System Logs to be collected"
  sudo filebeat modules enable system
  # Set var.convert_timezone: true in system.yml to show logs in local timezone
  sudo cp /etc/filebeat/Modules.d/system.yml /etc/filebeat/Modules.d/system.yml.orig
  sudo cp configs/filebeat/Modules.d/system.yml /etc/filebeat/Modules.d/system.yml
  sudo filebeat setup
  sudo service filebeat start
  sudo systemctl restart filebeat
  sudo systemctl status filebeat
  echo "Installing FileBeat DONE"
fi
echo

popd
