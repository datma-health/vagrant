#!/bin/bash

if [[ `hostname` == *master* ]]; then
  rm -f ~/.ssh/id_rsa*
  sudo chown -R vagrant ~/.ssh
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

  cp ~/.ssh/id_rsa.pub /source/vagrant/master_id_rsa.pub
else
  sudo chown -R vagrant /home/vagrant/.ssh
  cat /source/vagrant/master_id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
fi

source /vagrant/reset_eth1.sh
