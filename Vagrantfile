# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'ipaddr'

# The master node will get the following ip as its address.
# The slave instances will have ip+i as their ip addresses.
# TODO: Change IP below if you are running on the servers!!
# Current allocation for the lowest order octet:
# Brian: 20s
# Michael: 80s
# Melvin: 30s
# Nalini : 40s
# Scott : 50s
# Clay : 60s
# Hollis : 80s
# others : 90s
$user = ENV['USER']
case $user 
when "nalini" 
  $ip = "192.168.33.20"
else
  $ip = "192.168.33.90"
end
$memory = 4096
$cpus = 2

#number of slave instances have to be less than 10
$num_slaves = 0
$slave_memory = 2048
$slave_cpus = 2

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). 
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  config.vm.define "master_"+$user, primary: true do |master|
    master.vm.hostname = "oda-master"

    # configure Spark/Hadoop ports
    master.vm.network "forwarded_port", guest:8080, host:8081 # Spark Web UI
    master.vm.network "forwarded_port", guest:9000, host:9001 # Hadoop port forwarding
    master.vm.network "forwarded_port", guest: 50070, host: 50071 # Hadoop HDFS NameNode HTTP UI
    master.vm.network "forwarded_port", guest: 8088, host: 8089 # Hadoop Yarn ResourceManager HTTP UI
    master.vm.network "private_network", ip: $ip

    # configure ELK ports
    master.vm.network "forwarded_port", host: 9200, guest: 9200 # Elasticsearch
    master.vm.network "forwarded_port", host: 9300, guest: 9300 # Elasticsearch
    master.vm.network "forwarded_port", host: 5000, guest: 5000 # Logtash
    master.vm.network "forwarded_port", host: 5601, guest: 5601 # Kibana

    master.vm.provider "virtualbox" do |v|
      v.gui = false
      v.memory = $memory
      v.cpus = $cpus
      v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    end
  end

  current_ip = IPAddr.new($ip)
  (1..$num_slaves).each do |i|
    config.vm.define "slave-%d"%[i] do |slave|
      slave.vm.hostname = "oda-slave-%d"%[i]

      # Create a private network, which allows host-only access to the machine
      # using a specific IP.
      current_ip = current_ip.succ
      slave.vm.network "private_network", ip: current_ip.to_s

      slave.vm.provider "virtualbox" do |v|
        v.gui = false
        v.memory = $memory
        v.cpus = $cpus
        v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
      end
    end
  end

  # Provision General Prerequisites
  config.vm.provision :shell, inline: "yum clean all"
  config.vm.provision :shell, inline: "yum update -y -q"
  config.vm.provision :shell, inline: "yum install -y -q kernel-devel"
  config.vm.provision :shell, inline: "yum install -y -q  xorg-x11-drivers xorg-x11-utils"
  config.vm.provision :shell, inline: "yum update -y -q"
  config.vm.provision :shell, path: "disable_selinux.sh"

  config.vm.synced_folder "..", "/source"

  config.vm.provision :shell, path: "provision.sh", env: {"INSTALL_HADOOP"=>"true", "MASTER_IP"=>$ip, "NUM_SLAVES"=>$num_slaves}

  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
end
