#!/bin/bash

if [[ `hostname` == *master* ]]; then
  if [ ! -d ~/.ssh ]; then
    mkdir ~/.ssh
    chmod 700 ~/.ssh
  fi
  rm -f ~/.ssh/id_rsa*
  sudo chown -R vagrant ~/.ssh
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 0600 ~/.ssh/authorized_keys
  ssh-keyscan -H localhost >> ~/.ssh/known_hosts &&
  ssh-keyscan -H "0.0.0.0" >> ~/.ssh/known_hosts

  cp ~/.ssh/id_rsa.pub /source/vagrant/master_id_rsa.pub
else
  sudo chown -R vagrant /home/vagrant/.ssh
  cat /source/vagrant/master_id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
fi

source /vagrant/reset_eth1.sh
