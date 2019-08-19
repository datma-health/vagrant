#!/bin/bash

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

  mkdir $PROTOBUF_DIR
  cd $PROTOBUF_DIR
  git clone -b $PROTOBUF_VER --single-branch https://github.com/google/protobuf.git && cd protobuf
  if [ -f /vagrant/protobuf-${PROTOBUF-VER}.autogen.sh.patch ]; then
    cp /vagrant/protobuf-${PROTOBUF_VER}.autogen.sh.patch autogen.sh
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

cd $HOME

# GenomicsDB prereq - Protobuf 3.0.x for normal development
install_protobuf 3.0.x

# GenomicsDB prereq - Protobuf v3.0.0-beta-1 for packaging GenomicsDB jars
install_protobuf v3.0.0-beta-1


