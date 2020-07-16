#!/bin/sh

# Update and install snort
apt update 2> /dev/null

# Using the installation instructions from
# https://snort-org-site.s3.amazonaws.com/production/document_files/files/000/000/251/original/Snort_3_on_Ubuntu.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIXACIED2SPMSC7GA%2F20200716%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20200716T191806Z&X-Amz-Expires=172800&X-Amz-SignedHeaders=host&X-Amz-Signature=430b67a293d19052ecdb72ca407ab670ede8d70285d4199592eae33f9c94c7a2

mkdir ~/snort_src
cd ~/snort_src || echo "Failed to cd into ~/snort_src, quitting." && exit
# Snort dependencies
sudo apt-get install -yqq build-essential autotools-dev libdumbnet-dev libluajit-5.1-dev libpcap-dev zlib1g-dev pkg-config libhwloc-dev cmake
sudo apt-get install -yqq liblzma-dev openssl libssl-dev cpputest libsqlite3-dev uuid-dev
# git-specific tools
sudo apt-get install -yqq libtool git autoconf
sudo apt-get install -y bison flex libcmocka-dev
# Newer version of PCRE
wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
tar -xzvf pcre-8.43.tar.gz
cd pcre-8.43 || echo "Failed to cd into ~/snort_src/pcre-8.43, quitting." && exit
./configure
make
make install

# Ragel installation
cd ~/snort_src || echo "Failed to cd into ~/snort_src, quitting." && exit
wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz
tar -xzvf ragel-6.10.tar.gz
cd ragel-6.10 || echo "Failed to cd into ~/snort_src/ragel-6.10, quitting." && exit
./configure
make
make install

# Boost C++ libraries for Hyperscan
cd ~/snort_src || echo "Failed to cd into ~/snort_src, quitting." && exit
wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz
tar -xvzf boost_1_72_0.tar.gz

# Hyperscan installation
wget https://github.com/intel/hyperscan/archive/v5.2.1.tar.gz
tar -xvzf v5.2.1.tar.gz
mkdir ~/snort_src/hyperscan-5.2.1-build
cd ~/snort_src/hyperscan-5.2.1-build || echo "Failed to cd into hyperscan directory, quitting." && exit
cmake -DCMAKE_INSTALL_PREFIX=/usr/local-DBOOST_ROOT=~/snort_src/boost_1_72_0/ ../hyperscan-5.2.1
make
make install

# Data Acquisition (DAQ) library
cd ~/snort_src || echo "Failed to cd into ~/snort_src, quitting." && exit
git clone https://github.com/snort3/libdaq.git
cd libdaq || echo "Failed to cd into ~/snort_src/libdaq, quitting." && exit./bootstrap
./configure
make
make install

# Update shared libraries
ldconfig

# Install Snort3 itself
cd ~/snort_src || echo "Failed to cd into ~/snort_src, quitting." && exit
git clone https://github.com/snortadmin/snort3.git
cd snort3 || echo "Failed to access snort3 source code, quitting." && exit
./configure_cmake.sh --prefix=/usr/local
cd build || echo "Failed to enter snort3 build directory, quitting." && exit
make
sudo make install

# Output final verification that snort is installed
/usr/local/bin/snort -V

