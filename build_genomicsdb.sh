#!/bin/bash

source ~/env-protobuf-3.0.x.sh

cd $HOME

# GenomicsDB
echo 
echo "Installing GenomicsDB..."
git clone --recursive https://github.com/nalinigans/GenomicsDB.git
cd GenomicsDB
git submodule update --recursive --init
mkdir build
cd build

if [[ ! -z $PROTOBUF_LIBRARY ]]; then
  echo "PROTOBUF_LIBRARY env variable not defined. Exiting build."
  exit -1
fi

echo "Building GenomicsDB without Cloud Storage support"
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX -DBUILD_JAVA=1 -D${PROTOBUF_LIBRARY} ..

check_rc $!
make -j4 && make install
check_rc $!

echo "Installing GenomicsDB DONE"

