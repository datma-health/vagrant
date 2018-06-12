#!/bin/bash

echo "Starting Provisioning..."

yum update -y -q
yum install -y -q wget
yum install -y -q git

yum install -y xauth
if [ ! -f /home/vagrant/.Xauthority ]; then
	sudo -u vagrant touch /home/vagrant/.Xauthority
fi

yum install -y -q emacs
timedatectl set-timezone "America/Los_Angeles"

yum install -y -q java-1.8.0-devel
export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
export JRE_HOME=/usr/lib/jvm/jre

wget -q http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.rpm
yum install -y -q scala-2.11.8.rpm
rm scala-2.11.8.rpm

source /vagrant/provision_spark_hadoop.sh
