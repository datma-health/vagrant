#!/bin/bash

# Get the GPK Key for installing Elastic components
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo cp /source/vagrant/configs/elastic.repo /etc/yum.repos.d/

# ElasticSearch
echo "Installing ElasticSearch..."
sudo yum install -y elasticsearch 
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-geoip
sudo cp /vagrant/web/configs/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
echo "ElasticSearch listening on port 9200?"
sudo netstat -tulpn | grep 9200
echo "Installing ElasticSearch DONE"
echo

# Kibana
echo "Installing Kibana..."
sudo yum install -y kibana
sudo cp /vagrant/web/configs/kibana/kibana.yml /etc/kibana/kibana.yml
sudo systemctl enable kibana
sudo systemctl start kibana
echo "Kibana listening on port 5601?"
sudo netstat -tulpn | grep 5601
echo "Installing Kibana DONE"

# LogStash
echo "Installing LogStash..."
sudo yum install -y logstash
sudo systemctl enable logstash
sudo systemctl start logstash
echo "Installing LogStash DONE"
echo

# FileBeat
echo "Installing FileBeat..."
sudo yum install -y filebeat
sudo systemctl enable filebeat
# Configure system logs
# cp config/filebeat.yml
sudo filebeat modules enable system
sudo filebeat setup
sudo service filebeat start
sudo systemctl restart filebeat
sudo systemctl status filebeat
echo "Installing FileBeat DONE"
echo

# MetricBeat
sudo yum install metricbeat
echo "Installing MetricBeat ..."
#sudo vi /etc/metricbeat/metricbeat.yml 
sudo metricbeat modules enable system
#vi /etc/metricbeat/modules.d/system.yml 
sudo metricbeat setup
sudo service metricbeat start
sudo systemctl restart metricbeat
sudo systemctl status metricbeat
echo "Installing MetricBeat DONE"
echo

curl -X GET http://localhost:9200
