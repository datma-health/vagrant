#!/bin/bash

SCRIPT_PATH="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
SCRIPT_DIR="$(dirname "${cur_file}")"
pushd ${SCRIPT_DIR}

# Get the GPK Key for installing Elastic components
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo cp configs/elastic.repo /etc/yum.repos.d/

# ElasticSearch
if [[ -d /etc/elasticsearch ]]; then
  echo "ElasticSearch seems to be already installed"
else
  echo "Installing ElasticSearch..."
  sudo yum install -y elasticsearch 
  sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-geoip
  sudo cp configs/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
  sudo systemctl daemon-reload
  sudo systemctl enable elasticsearch.service
  sudo systemctl start elasticsearch.service
  echo "ElasticSearch listening on port 9200?"
  sudo netstat -tulpn | grep 9200
  echo "Installing ElasticSearch DONE"
fi
echo

# Kibana
if [[ -d /etc/kibana ]]; then
  echo "Kibana seems to be already installed"
else
  echo "Installing Kibana..."
  sudo yum install -y kibana
  sudo cp configs/kibana/kibana.yml /etc/kibana/kibana.yml
  sudo systemctl enable kibana
  sudo systemctl start kibana
  echo "Kibana listening on port 5601?"
  sudo netstat -tulpn | grep 5601
  echo "Installing Kibana DONE"
fi
echo

# LogStash
if [[ -d /etc/logstash ]]; then
  echo "Logstash seems to be already installed"
else
  echo "Installing LogStash..."
  sudo yum install -y logstash
  sudo systemctl enable logstash
  sudo systemctl start logstash
  echo "Installing LogStash DONE"
fi
echo

source install_filebeat.sh
source install_metricbeat.sh

popd

echo "Test if ElasticSearch is navigable..."
curl -X GET http://localhost:9200
echo "Testinn ElasticSearch DONE"
echo
