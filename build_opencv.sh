#!/bin/bash

# Settings
OPENCV_VERSION=3.4.1
BUILD_TYPE=Debug
INSTALL_DIR=/usr/local
SOURCE_DIR=/vagrant

echo OPENCV_VERSION=$OPENCV_VERSION
echo BUILD_TYPE=$BUILD_TYPE
echo INSTALL_DIR=$INSTALL_DIR

#read -n 1 -s -r -p "Press any key to continue"

echo
echo

####################################################################
# Don't modify the following
####################################################################

START_DIR=`pwd`

source install_opencv_prereqs.sh

cd $SOURCE_DIR

# OpenCV Installation

echo
echo "Installing OpenCV..."

if [ ! -d local ]; then
  mkdir local
fi
cd local

if [ ! -d opencv-$OPENCV_VERSION ]; then
  wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip
  unzip $OPENCV_VERSION.zip
fi
cd opencv-$OPENCV_VERSION

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR ..
make && sudo make install

echo "Setting up OpenCV environment ..."
echo "#!/bin/sh" > opencv.sh
echo "if [[ -e \$PKG_CONFIG_PATH ]]; then" >> opencv.sh
echo "  export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:$INSTALL_DIR/lib/pkgconfig" >> opencv.sh
echo "else" >> opencv.sh
echo "  export PKG_CONFIG_PATH=$INSTALL_DIR/lib/pkgconfig" >> opencv.sh
echo "fi" >> opencv.sh
sudo mv opencv.sh /etc/profile.d/opencv.sh
echo "ENV_FILE=/etc/profile.d/opencv.sh"
echo

cd $START_DIR

echo "Installing OpenCV DONE"
