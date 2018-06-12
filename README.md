### Vagrant files for a Spark-Hadoop VM Cluster to test software from Omics Data Automation, Inc.

### License
See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).

#### Prerequisites
[Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) installations for your host.

Before using a Vagrant machine with the shared folder functionality, you should install the 
vagrant-vbguest plugin:
```
#!bash
vagrant plugin install vagrant-vbguest
```

#### Supported Platforms
Centos 7 is the only target OS supported. Note that this vagrant configuration is not suited for production environments.

Open [Vagrantfile](Vagrantfile) and change the variables - ip, memory, cpus, num_slaves, slave_memory and slave_cpus. The default is to start up a master-only Spark-Hadoop cluster. Also, take note of the default forwarded port numbers especially if you have other servers and/or VMs using the ports.
```ruby
# The master node will get the following ip as its address.
# The slave instances will have ip+i as their ip addresses.
$ip = "192.168.33.10"
$memory = 4096
$cpus = 2

# number of slave instances have to be less than 10
$num_slaves = 0
$slave_memory = 2048
$slave_cpus = 2
```

Invoke [vagrant_VM_configure](vagrant_VM_configure.sh) to install the spark-hadoop cluster. 
```
#!bash
./vagrant_VM_configure.sh
```

Install and build scripts are currently available for 
* [GenomicsDB](https://github.com/nalinigans/GenomicsDB), 
* [GATK4](https://github.com/broadinstitute/gatk) and 
* [OpenCV](https://opencv.org).

Check out the settings at the head of respective scripts to make any changes in versions, build and install parameters before invoking them.
  
