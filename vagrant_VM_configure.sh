#!/bin/bash

echo_cmd() {
  tput smso
  echo $1
  tput rmso
}

echo_cmd "Vagrant VM setup..."
export VAGRANT_BASIC_PROVISION=".vagrant.basic.provision"
rm -f $VAGRANT_BASIC_PROVISION
vagrant up

# workaround for vbguest not really working with VirtualBox
echo_cmd "Installing vbguest plugin..."
vagrant vbguest --do install --no-cleanup

# need to restart for disable_selinux and guest additions to take effect
echo_cmd "Vagrant VM provision..."
touch $VAGRANT_BASIC_PROVISION
vagrant reload --provision
rm -f $VAGRANT_BASIC_PROVISION

echo_cmd "Vagrant VM ready!!"
