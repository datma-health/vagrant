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
$ip = "192.168.33.92"
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

  config.vbguest.auto_update = false
  
  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = true	

  #config.ssh.insert_key = false

  config.vm.define "master", primary: true do |master|
    master.vm.hostname = "oda-master"

    # Spark Web UI
    master.vm.network "forwarded_port", guest:8080, host:8080

    # Hadoop port forwarding: TODO change this port if running on server
    master.vm.network "forwarded_port", guest:9000, host:9000

    # Hadoop HDFS NameNode HTTP UI
    config.vm.network "forwarded_port", guest: 50070, host: 50070

    # Hadoop YARN ResourceManager HTTP UI
    config.vm.network "forwarded_port", guest: 8088, host: 8088

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    master.vm.network "private_network", ip: $ip

    config.vm.provider "virtualbox" do |v|
      v.gui = false
      v.memory = $memory
      v.cpus = $cpus
      v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
      v.customize ["modifyvm", :id, "--nic2", "hostonly"]
      v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
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

      config.vm.provider "virtualbox" do |v|
        v.gui = false
        v.memory = $memory
        v.cpus = $cpus
        v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
        v.customize ["modifyvm", :id, "--nic2", "hostonly"]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
      end
    end
  end

  # Workaround for vbguest not really working with VirtualBox. Ugly!!
  # Start vagrant up followed 
  if !File.exist?(".vagrant.basic.provision")
    # Provision General Prerequisites
    config.vm.provision :shell, inline: "yum install -y -q kernel-devel"  
    config.vm.provision :shell, path: "disable_selinux.sh"
  else
    # Add synched folder and continue with the rest of provisioning
    config.vm.synced_folder "..", "/source"
    config.vm.provision :shell, path: "provision.sh", env: {"INSTALL_HADOOP"=>"true", "MASTER_IP"=>$ip, "NUM_SLAVES"=>$num_slaves}
  end

  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
end
