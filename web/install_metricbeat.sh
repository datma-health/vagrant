SCRIPT_PATH="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
SCRIPT_DIR="$(dirname "${cur_file}")"
pushd ${SCRIPT_DIR}

# Get the GPK Key for installing Elastic components
if [[ -f /etc/yum.repos.d/elastic.repo ]]; then
  sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
  sudo cp configs/elastic.repo /etc/yum.repos.d/
fi

# MetricBeat
if [[ -d /etc/metricbeat ]]; then
  echo "Metricbeat seems to be already installed"
else
  echo "Installing MetricBeat ..."
  sudo yum install -y metricbeat
  if [[ $# -eq 2 ]]; then
    if [[ $1 -eq "--configure" ]]; then
       # configure metriceat 
       sudo cp /etc/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.yml.orig
       sudo cp configs/metricbeat/metricbeat.yml /etc/metricbeat/metricbeat.yml
    fi
  fi 
  sudo metricbeat modules enable system
  #vi /etc/metricbeat/modules.d/system.yml 
  sudo metricbeat setup
  sudo service metricbeat start
  sudo systemctl restart metricbeat
  sudo systemctl status metricbeat
  echo "Installing MetricBeat DONE"
fi

echo
popd
