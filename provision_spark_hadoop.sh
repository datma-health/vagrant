#!/bin/bash

SPARK_VERSION=2.4.0
HADOOP_VER=2.9
HADOOP_MICRO_VER=2
SPARK=spark-$SPARK_VERSION-bin-hadoop2.7

INSTALL_DIR=/usr/local
SPARK_DIR=$INSTALL_DIR/$SPARK

SOURCE_DIR=/vagrant
SOURCE_LOCAL_DIR=$SOURCE_DIR/local

SPARK_LOCAL_DIR=/usr/local/spark

CURRENT_DIR=`pwd`

#Uncomment if you want a real hadoop cluster instead of a pseudo configured cluster
#INSTALL_HADOOP_CLUSTER=True

echo "Starting Spark-Hadoop Installation..."

if [ -d $SPARK_DIR ]; then
	echo "Spark is already installed!"
else
	echo "Installing spark..."

	if [ ! -f $SOURCE_LOCAL_DIR/$SPARK.tgz ]; then
		mkdir $SOURCE_LOCAL_DIR
		cd $SOURCE_LOCAL_DIR
		wget -nv --trust-server-names "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=spark/spark-$SPARK_VERSION/$SPARK.tgz"
	fi
	cd $INSTALL_DIR
	tar -zvxf $SOURCE_LOCAL_DIR/$SPARK.tgz
	chown -R vagrant:vagrant $SPARK_DIR
	rm -f $SPARK_LOCAL_DIR
	ln -s $INSTALL_DIR/$SPARK $SPARK_LOCAL_DIR

	echo "Installing spark DONE"
fi

if [[ $PATH == *$SPARK_LOCAL_DIR* ]]; then
	echo "PATH already has Spark"
else
	echo "Setting up spark environment ..."
	echo "#!/bin/sh" >> spark.sh
	echo "export SPARK_HOME=${SPARK_LOCAL_DIR}" >> spark.sh
	echo "export PATH=${SPARK_LOCAL_DIR}/bin:${SPARK_LOCAL_DIR}/sbin:\$PATH" >> spark.sh
	mv spark.sh /etc/profile.d/spark.sh
	source /etc/profile.d/spark.sh

	# Setup spark cluster
	if [[ `hostname` == *master* ]]; then
		# Setup configuration
		echo "Setting up spark-cluster Master environment"

		IP=$MASTER_IP
		MASTER=`hostname -s`
		echo "SPARK_MASTER_HOST=$IP" > ${SPARK_HOME}/conf/spark-env.sh
		echo "SPARK_LOCAL_IP=$IP" >> ${SPARK_HOME}/conf/spark-env.sh
		# Setup /etc/hosts with spark slaves
		echo "localhost" > ${SPARK_HOME}/conf/slaves
		echo "$IP $MASTER" >> /etc/hosts
		ip_segment1_3=`echo $IP | cut -d. -f1-3`
		ip_segment4=`echo $IP | cut -d. -f4`
		echo $ip_segment1_3 $ip_segment4
		for (( i=1; i<=$NUM_SLAVES; i++ ))
		do
			ip_segment4=$(( $ip_segment4+1 ))
			SLAVE_IP=${ip_segment1_3}.${ip_segment4}
			SLAVE_NAME=oda-slave-$i
			echo $SLAVE_IP $SLAVE_NAME
			echo $SLAVE_IP >> ${SPARK_HOME}/conf/slaves
			echo $SLAVE_IP $SLAVE_NAME >> /etc/hosts
		done
	fi

	sudo -u vagrant /vagrant/spark_setup.sh

	echo "Setting up spark environment DONE"
fi

HADOOP_FULL_VER=$HADOOP_VER.$HADOOP_MICRO_VER
HADOOP=hadoop-$HADOOP_FULL_VER

HADOOP_DIR=$INSTALL_DIR/$HADOOP
HADOOP_LOCAL_DIR=/usr/local/hadoop

INSTALL_HADOOP="true"
if [[ $INSTALL_HADOOP == "true" ]]; then
	if [ -d $HADOOP_DIR ]; then
		echo "Hadoop is already installed!"
	else
		echo "Installing hadoop..."
		if [ ! -f $SOURCE_LOCAL_DIR/$HADOOP.tar ]; then
			cd $SOURCE_LOCAL_DIR
			wget -nv --trust-server-names "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hadoop/common/$HADOOP/$HADOOP.tar.gz"
			gunzip $HADOOP.tar.gz
		fi
		cd $INSTALL_DIR
		tar -xf $SOURCE_LOCAL_DIR/$HADOOP.tar
		chown -R vagrant:vagrant $INSTALL_DIR/$HADOOP
		rm -f $HADOOP_LOCAL_DIR
		ln -s $INSTALL_DIR/$HADOOP $HADOOP_LOCAL_DIR

		echo "Installing hadoop DONE"
	fi

	if [[ $PATH == *$HADOOP_LOCAL_DIR* ]]; then
		echo "PATH already has Hadoop"
	else
		echo "Setting up spark-hadoop environment..."

		echo "#!/bin/sh" >> hadoop.sh
		if [ -n $JAVA_HOME ];
		then
			echo "Setting up Java Environment"
			mkdir /usr/java
			if [[ -L /usr/java/latest || -d /usr/java/latest ]]; then
				rm /usr/java/latest
			fi
			ln -s /usr/lib/jvm/java-1.8.0 /usr/java/latest
			echo "export JAVA_HOME=/usr/java/latest" >> hadoop.sh
		fi
		echo "export PATH=$HADOOP_LOCAL_DIR/bin:$HADOOP_LOCAL_DIR/sbin:\$PATH" >> hadoop.sh
		echo "export HADOOP_HOME=$HADOOP_LOCAL_DIR" >> hadoop.sh
		HADOOP_LIBS="$HADOOP_LOCAL_DIR/lib/native:/usr/java/latest/jre/lib/amd64/server"
		echo "if [[ -n \$LD_LIBRARY_PATH ]]; then export LD_LIBRARY_PATH=$HADOOP_LIBS:\$LD_LIBRARY_PATH; else export LD_LIBRARY_PATH=$HADOOP_LIBS; fi" >> hadoop.sh
		echo "export CLASSPATH=`$HADOOP_LOCAL_DIR/bin/hadoop classpath --glob`" >> hadoop.sh
		echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" >> hadoop.sh
		echo "export HADOOP_OPTS=-Djava.library.path=\$HADOOP_HOME/lib/native" >> hadoop.sh
		sudo mv hadoop.sh /etc/profile.d/hadoop.sh
		source /etc/profile.d/hadoop.sh

		if [ -z $INSTALL_HADOOP_CLUSTER ]; then
			#setup hadoop configuration as a pseudo-distributed cluster on a single node
			cp -fr /vagrant/pseudo-cluster-hadoop-config/* $HADOOP_LOCAL_DIR/etc/hadoop
		else
		# setup initial hadoop configuration files for fully distributed operation
			mkdir /opt/hadoop
			chown -R vagrant:vagrant /opt/hadoop
			mkdir /opt/volume
			mkdir /opt/volume/namenode
			mkdir /opt/volume/datanode
			chown -R vagrant:vagrant /opt/volume
			cp -fr /vagrant/hadoop-config/* $HADOOP_LOCAL_DIR/etc/hadoop
		fi

		# create a logs directory, otherwise there seem to be errors
		sudo -u vagrant mkdir $HADOOP_LOCAL_DIR/logs

		# Installing GCS Connector
		wget -nv https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-latest-hadoop2.jar
		cp gcs-connector-latest-hadoop2.jar ${HADOOP_HOME}/share/hadoop/common
		cp gcs-connector-latest-hadoop2.jar ${SPARK_HOME}/jars
		rm gcs-connector-latest-hadoop2.jar

		echo "export CLASSPATH=`$HADOOP_LOCAL_DIR/bin/hadoop classpath --glob`" >> hadoop.sh

		# Setting HADOOP_CONF_DIR in Spark env hooks Spark into HDFS
		echo "HADOOP_CONF_DIR=$HADOOP_LOCAL_DIR/etc/hadoop" >> ${SPARK_HOME}/conf/spark-env.sh

		if [[ `hostname` == *master* ]]; then
			echo "Configuring/Starting hadoop"
			. /etc/profile.d/hadoop.sh
			sudo -u vagrant JAVA_HOME=$JAVA_HOME $HADOOP_LOCAL_DIR/bin/hdfs namenode -format
			sudo -u vagrant JAVA_HOME=$JAVA_HOME $HADOOP_LOCAL_DIR/sbin/start-dfs.sh
			echo "Configuring/Starting hadoop DONE"
		fi

		echo "Setting up spark-hadoop environment DONE"
	fi

fi

cd $CURRENT_DIR

