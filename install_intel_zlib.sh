#!/bin/bash

die() {
        if [[ $# -eq 1 ]]; then
                echo $1
        fi
        exit 1
}

check_rc() {
        cd $HOME
        if [[ $# -eq 1 ]]; then
                if [[ $1 -ne 0 ]]; then
                        die "command returned $1. Quitting Installation of Intel Zlib"
                fi
        fi
}

die() { 
        if [[ $# -eq 1 ]]; then
                echo $1
        fi
        exit 1
}

check_rc() {
        cd $HOME
        if [[ $# -eq 1 ]]; then
                if [[ $1 -ne 0 ]]; then
                        die "command returned $1. Quitting Installation of Intel Zlib"
                fi
        fi
}

# $1 - path variable name
# $2 - path variable value
# $3 - path variable separator - optional - default is ":"
add_path_to_bashrc() {
        if [[ ! $# -ge 2 ]]; then
                die "Specify env variable and value"
        fi
        SEP=":"
        if [[ $# -eq 3 ]]; then
                SEP=$3
        fi
        if grep -q -w $1 $HOME/.bashrc; then
                VALUE=`grep -w $1 $HOME/.bashrc`
                NEW_VALUE="export $1=$2$SEP${VALUE/export $1=/}"
                sed -i "s|$VALUE|$NEW_VALUE|g" $HOME/.bashrc
        elif [ -z ${!1} ]; then
                echo "export $1=$2" >> $HOME/.bashrc
        else
                echo "export $1=$2$SEP\$$1" >> $HOME/.bashrc
        fi
}

add_cmake_prefix_path() {
        if [[ $# -eq 0 ]]; then
                die "No path specified to add_cmake_prefix_path"
        fi
        add_path_to_bashrc "CMAKE_PREFIX_PATH" $1 ";"
}


if [ ! -d $HOME/intel_zlib ]; then
        echo
        echo "Installing Intel optimized zlib"

        sudo yum-config-manager --add-repo https://yum.repos.intel.com/ipp/setup/intel-ipp.repo &&
                sudo rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB &&
                sudo yum -y install intel-ipp-2018.2-046
        check_rc $!
        if [ ! -f /opt/intel/compilers_and_libraries_2018.2.199/linux/ipp/bin/ippvars.sh ]; then
                echo "Could not find ippvars.sh. Aborting installing Intel optimized zlib"
                exit -1
        fi
        sudo yum -y install patch
        check_rc $?

        if [ ! -d zlib-1.2.8 ]; then
                wget http://zlib.net/fossils/zlib-1.2.8.tar.gz &&
                        tar -xvzf zlib-1.2.8.tar.gz
                check_rc $?
        fi

        source /opt/intel/compilers_and_libraries_2018.2.199/linux/ipp/bin/ippvars.sh intel64
        echo "source /opt/intel/compilers_and_libraries_2018.2.199/linux/ipp/bin/ippvars.sh intel64" >> ~/.bashrc
        pushd $IPPROOT/examples &&
                if [ ! -d components_and_examples_lin_ps ]; then
                        sudo mkdir components_and_examples_lin_ps
                fi
        cd components_and_examples_lin_ps &&
                sudo tar -xzvf ../components_and_examples_lin_ps.tgz &&
                popd &&
                cd zlib-1.2.8 &&
                patch -p1 < $IPPROOT/examples/components_and_examples_lin_ps/components/interfaces/ipp_zlib/zlib-1.2.8.patch &&
                export CFLAGS="-m64 -DWITH_IPP -I$IPPROOT/include -fPIC" &&
                export LDFLAGS="$IPPROOT/lib/intel64/libippdc.a $IPPROOT/lib/intel64/libipps.a $IPPROOT/lib/intel64/libippcore.a" &&
                ./configure &&
                make shared &&
                mkdir -p $HOME/intel_zlib/lib &&
                cp libz.a $HOME/intel_zlib/lib &&
                rm -fr $HOME/zlib*
        check_rc $?
        add_cmake_prefix_path $HOME/intel_zlib
        echo "Installing Intel optimized zlib done"
fi
