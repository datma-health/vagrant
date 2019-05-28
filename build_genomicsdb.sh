#!/bin/bash

source ~/env-protobuf-3.0.x.sh

if [[ -z $PROTOBUF_LIBRARY ]]; then
  echo "PROTOBUF_LIBRARY env variable not defined. Exiting build."
  exit -1
fi

cd $HOME

# GenomicsDB
echo 
echo "Installing GenomicsDB..."
git clone --recursive https://github.com/GenomicsDB/GenomicsDB.git
pushd GenomicsDB
git submodule update --recursive --init
mkdir build
pushd build

echo "Building GenomicsDB... "
cmake -DCMAKE_INSTALL_PREFIX=~/ -DBUILD_JAVA=1 -DPROTOBUF_LIBRARY=${PROTOBUF_LIBRARY} ..

check_rc $!
make -j4 && make install
check_rc $!

popd
popd

echo "Installing GenomicsDB DONE"

