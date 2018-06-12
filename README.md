## Vagrant files for a Spark-Hadoop VM Cluster to test software from Omics Data Automation, Inc.

## License
See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).

Open [Vagrantfile](Vagrantfile) and change the variables - ip, memory, cpus, num_slaves, slave_memory and slave_cpus. The default is to start up a master-only Spark-Hadoop cluster. Also, take note of the default forwarded port numbers especially if you have other servers and/or VMs using the ports.

Invoke [vagrant_VM_configure](vagrant_VM_configure.sh) to install the spark-hadoop cluster. 

Install and build scripts are currently available for 
* [GenomicsDB](https://github.com/nalinigans/GenomicsDB), 
* [GATK4](https://github.com/broadinstitute/gatk) and 
* [OpenCV](https://opencv.org).

Check out the settings at the head of respective scripts to make any changes in versions, build and install parameters before invoking them.
  
