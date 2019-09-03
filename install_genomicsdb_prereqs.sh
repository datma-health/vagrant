#!/bin/bash

MAVEN=apache-maven
MAVEN_VERSION=3.3.9

CMAKE_BUILD_TYPE=Debug
CMAKE_INSTALL_PREFIX=$HOME

OPENSSL_VERSION=1.0.2o

pushd `dirname $0`
VAGRANT_DIR=`pwd`
popd

check_rc() {
  if [[ $# -eq 1 ]]; then
    if [[ -z $1 ]]; then
      echo "make returned $1. Quitting GenomicsDB Build"
      exit $1
    fi
  fi
}

install_protobuf() {
  if [[ $# -ne 1 ]]; then
    echo "Could not install protobuf. Specify protobuf version and retry" $0 $1 
    return 1
  fi

  echo
  PROTOBUF_VER=$1
  echo "Installing Protobuf $PROTOBUF_VER..."
  PROTOBUF_DIR=$HOME/protobuf-$PROTOBUF_VER

  if [ -d $PROTOBUF_DIR ]; then
    echo "Protobuf Version ${PROTOBUF_VER} is already installed"
    return 0
  fi

  cd $HOME
  mkdir $PROTOBUF_DIR
  cd $PROTOBUF_DIR
  git clone -b $PROTOBUF_VER --single-branch https://github.com/google/protobuf.git && cd protobuf
  if [ -f $VAGRANT_DIR/vagrant/protobuf-${PROTOBUF_VER}.autogen.sh.patch ]; then
    cp $VAGRANT_DIR/vagrant/protobuf-${PROTOBUF_VER}.autogen.sh.patch autogen.sh
  fi
  ./autogen.sh
  echo "./configure --prefix=$PROTOBUF_DIR --with-pic"
  ./configure --prefix=$PROTOBUF_DIR --with-pic
  check_rc $!
  echo "export PROTOBUF_LIBRARY=$PROTOBUF_DIR" > ~/env-protobuf-$PROTOBUF_VER.sh
  make -j4 && make install
  check_rc $!
  echo "export PATH=\$PROTOBUF_LIBRARY/bin:\$PATH" >> ~/env-protobuf-$PROTOBUF_VER.sh
  echo "export LD_LIBRARY_PATH=\$PROTOBUF_LIBRARY/lib:\$LD_LIBRARY_PATH" >> ~/env-protobuf-$PROTOBUF_VER.sh
  echo "if [[ -z \$C_INCLUDE_PATH ]]; then" >> ~/env-protobuf-$PROTOBUF_VER.sh
  echo "  export C_INCLUDE_PATH=\$PROTOBUF_LIBRARY/include:\$C_INCLUDE_PATH" >> ~/env-protobuf-$PROTOBUF_VER.sh
  echo "else" >> ~/env-protobuf-$PROTOBUF_VER.sh
  echo "  export C_INCLUDE_PATH=\$PROTOBUF_LIBRARY/include" >> ~/env-protobuf-$PROTOBUF_VER.sh
  echo "fi" >> ~/env-protobuf-$PROTOBUF_VER.sh
  echo "Installing Protobuf DONE"
  cd $HOME
}

install_curl() {
  if [ -f /usr/local/lib/libcurl.a ]; then
    echo "Curl already installed"
    return 0
  fi

  cd $HOME

  echo "Installing CURL..."

  git clone https://github.com/curl/curl.git &&
  pushd curl &&
  autoreconf -i &&
  ./configure --prefix /usr/local --enable-lib-only &&
  make && sudo make install &&
  popd &&
  echo "Installing CURL DONE"
}

if [ -d $HOME/GenomicsDB ]; then
  echo "GenomicsDB already exists"
  read -r -p "Press [y/Y] to delete GenomicsDB and continue installing/building\n" response
  if [[ $response =~ ^[yY] ]]; then
    rm -fr $HOME/GenomicsDB
  else
    exit 0
  fi
fi  

# GenomicsDB prereq
sudo yum -y install centos-release-scl
sudo yum -y install devtoolset-3
grep "source /opt/rh/devtoolset-3/enable" ~/.bashrc || echo 'source /opt/rh/devtoolset-3/enable' >> ~/.bashrc

sudo yum -y install autoconf automake libtool curl libcurl-devel make g++ unzip
sudo yum -y install mpich-devel

sudo yum -y install epel-release

sudo yum -y install libcsv libcsv-devel
sudo yum -y install install libssl-dev
sudo yum -y install openssl-devel zlib-devel libuuid-devel
sudo yum -y install cmake

# GenomicsDB Prereqs for building distributable target jars
sudo yum -y install libstdc++-static
sudo yum -y install cmake3
install_curl

if [ ! -d /usr/local/openssl ]; then
  cd $HOME
  wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz 
  tar -xvzf openssl-$OPENSSL_VERSION.tar.gz
  cd openssl-$OPENSSL_VERSION
  CFLAGS=-fPIC ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl
  make && sudo make install
  cd ..
  rm -fr openssl-$OPENSSL_VERSION.tar.gz
  echo "export OPENSSL_ROOT_DIR=/usr/local/openssl" >> ~/.bashrc
fi

# GenomicsDB prereqs for Testing
sudo yum -y install python-pip
sudo pip install --upgrade pip
sudo pip install jsondiff
sudo yum -y install lcov
sudo yum -y install csv

# GenomicsDB prerereq - Maven for building Java/Scala/Spark Modules
if [ ! -d $HOME/$MAVEN-$MAVEN_VERSION ]; then
  echo 
  echo "Installing Maven..."
  cd $HOME
  wget --quiet http://apache.cs.utah.edu/maven/maven-3/$MAVEN_VERSION/binaries/$MAVEN-$MAVEN_VERSION-bin.tar.gz -nv
  tar -zxvf $MAVEN-$MAVEN_VERSION-bin.tar.gz
  rm  $MAVEN-$MAVEN_VERSION-bin.tar.gz
  ln -s $MAVEN-$MAVEN_VERSION $MAVEN
  echo "export M2_HOME=$HOME/apache-maven/" >> ~/.bashrc
  echo "Installing Maven DONE"
fi

echo "export PATH=$HOME/bin:$HOME/$MAVEN/bin:/usr/lib64/mpich/bin:\$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$HOME/lib:/usr/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
echo "export C_INCLUDE_PATH=$HOME/include" >> ~/.bashrc

source ~/.bashrc

cd $HOME

# GenomicsDB prereq - Protobuf 3.0.x for normal development
install_protobuf 3.0.x

# GenomicsDB prereq - Protobuf v3.0.0-beta-1 for packaging distributable GenomicsDB jars
install_protobuf v3.0.0-beta-1

read -n 1 -s -r -p "Press any key to continue. This will bring up a new shell with the installed Prerequisites."
echo
scl enable devtoolset-3 bash
