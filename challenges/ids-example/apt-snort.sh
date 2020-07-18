#!/bin/sh

# Update and install snort
apt update 2> /dev/null

export DEBIAN_FRONTEND=noninteractive
apt-get -yq install snort

# Install the open emerging threats ruleset from Proofpoint
cd /tmp
wget https://rules.emergingthreats.net/open/snort-2.9.0/emerging.rules.tar.gz
tar -xf emerging.rules.tar.gz
# Copy the rules over to the snort rules directory
cp rules/* /etc/snort/rules/
# Use the snort.conf file located on github
wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/ids-example/snort.conf -O /etc/snort/snort.conf

# TODO: Add Snort as a service in the background
# Working Command: sudo snort -A console -c /etc/snort/snort.conf -i eth2 -l /vagrant -L alerts.snort

