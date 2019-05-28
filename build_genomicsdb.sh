#!/bin/bash

source ~/env-protobuf-3.0.x.sh

if [[ -z $PROTOBUF_LIBRARY ]]; then
  echo "PROTOBUF_LIBRARY env variable not defined. Exiting build."
  exit -1
fi

check_rc() {
  if [[ $# -eq 1 ]]; then
    if [[ -z $1 ]]; then
      echo "make returned $1. Quitting GenomicsDB Build"
      exit $1
    fi
  fi
}

cd $HOME

# GenomicsDB
echo 
echo "Installing GenomicsDB..."
if [ ! -d GenomicsDB ]; then
  git clone --recursive https://github.com/GenomicsDB/GenomicsDB.git
  pushd GenomicsDB
  git submodule update --recursive --init
  popd
fi
if [ ! -d GenomicsDB/build ]; then
  mkdir -p GenomicsDB/build
fi
pushd GenomicsDB
git pull origin master
pushd build

echo "Building GenomicsDB... "
cmake -DCMAKE_INSTALL_PREFIX=~/ -DBUILD_JAVA=1 -DPROTOBUF_LIBRARY=${PROTOBUF_LIBRARY} ..

check_rc $!
make -j4 && make install
check_rc $!

popd
popd

echo "Installing GenomicsDB DONE"

