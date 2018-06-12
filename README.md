### Vagrant files for a Spark-Hadoop VM Cluster to test software from Omics Data Automation, Inc.
Not suited for production environments.

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
Centos 7 is the only target OS supported.

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
```shell
#!bash
./vagrant_VM_configure.sh
```

To test HDFS and Spark, bring up a vagrant shell(vagrant ssh from the folder containing Vagrantfile on the host machine)
```shell
~/vagrant: vagrant ssh
[vagrant@oda-master ~]$ which start-dfs.sh
/usr/local/hadoop/sbin/start-dfs.sh
[vagrant@oda-master ~]$ start-dfs.sh
Starting namenodes on [oda-master]
The authenticity of host 'oda-master (127.0.0.1)' can't be established.
...
[vagrant@oda-master ~]$ hdfs dfs -mkdir /tmp
18/06/12 14:48:48 INFO gcs.GoogleHadoopFileSystemBase: GHFS version: 1.8.1-hadoop2
[vagrant@oda-master ~]$ hdfs dfs -ls /
18/06/12 14:48:54 INFO gcs.GoogleHadoopFileSystemBase: GHFS version: 1.8.1-hadoop2
Found 1 items
drwxr-xr-x   - vagrant supergroup          0 2018-06-12 14:48 /tmp
[vagrant@oda-master ~]$ 

```

The Vagrant target VM and the host machine share two folders.
* host folder containing Vagrantfile is mapped to /vagrant in the target VM
* parent folder to the folder containing Vagrantfile is mapped to /source in the target VM.
```shell
~/vagrant: vagrant ssh
[vagrant@oda-master ~]$ ls /vagrant
build_gatk4.sh             disable_selinux.sh             install_opencv_prereqs.sh  provision.sh                  README.md       Vagrantfile~
build_genomicsdb_distr.sh  hadoop-config                  LICENSE.md                 provision.sh~                 reset_eth1.sh   vagrant_VM_configure.sh
build_genomicsdb.sh        install_gatk4_prereqs.sh       local                      provision_spark_hadoop.sh     spark_setup.sh  vagrant_VM_configure.sh~
build_opencv.sh            install_genomicsdb_prereqs.sh  master_id_rsa.pub          pseudo-cluster-hadoop-config  Vagrantfile
[vagrant@oda-master ~]$ ls /source/vagrant
build_gatk4.sh             disable_selinux.sh             install_opencv_prereqs.sh  provision.sh                  README.md       Vagrantfile~
build_genomicsdb_distr.sh  hadoop-config                  LICENSE.md                 provision.sh~                 reset_eth1.sh   vagrant_VM_configure.sh
build_genomicsdb.sh        install_gatk4_prereqs.sh       local                      provision_spark_hadoop.sh     spark_setup.sh  vagrant_VM_configure.sh~
build_opencv.sh            install_genomicsdb_prereqs.sh  master_id_rsa.pub          pseudo-cluster-hadoop-config  Vagrantfile
[vagrant@oda-master ~]$ 
```

Install and build scripts are currently available for 
* [GenomicsDB](https://github.com/nalinigans/GenomicsDB), 
* [GATK4](https://github.com/broadinstitute/gatk) and 
* [OpenCV](https://opencv.org).

Check out the settings at the head of respective scripts to make any changes in versions, build and install parameters before invoking them. All scripts are invokable from a vagrant shell. 

For example, invoke build_opencv.sh to install prerequisites, build and install OpenCV into your Vagrant VM instance. Bring up a new instance of vagrant shell to get your apps locate the OpenCV libraries and binaries.
```shell
~/vagrant: vagrant ssh
[vagrant@oda-master ~]$ cd /vagrant
[vagrant@oda-master vagrant]$ ./build_opencv.sh
...
- Installing: /usr/local/bin/opencv_version
-- Set runtime path of "/usr/local/bin/opencv_version" to "/usr/local/lib64"
Setting up OpenCV environment ...
ENV_FILE=/etc/profile.d/opencv.sh
Installing OpenCV DONE
[vagrant@oda-master vagrant]$
```


  
