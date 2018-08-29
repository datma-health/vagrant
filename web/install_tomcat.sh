#!/bin/bash

yum install -y net-tools

wget -q http://mirrors.ocf.berkeley.edu/apache/tomcat/tomcat-8/v8.5.33/bin/apache-tomcat-8.5.33.tar.gz
tar -xf apache-tomcat-8.5.33.tar.gz

echo "Run apache-tomcat-8.5.33/bin/startup.sh to start Tomcat"

PORT=`grep "Connector port.*HTTP/1.1" server.xml | grep -o -E '[0-9]+' | head -1`
echo "Connector Port is configured to $PORT for the Tomcat server"
echo "   Forward Port=$PORT in Vagrantfile to a host port for monitoring the server"
echo "   master.vm.network "forwarded_port", guest:$PORT, host:<Port #>"
echo "   Restart vagrant with the command for the forwarded port to take effect - vagrant restart --provision"

