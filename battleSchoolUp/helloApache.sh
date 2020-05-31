#!/bin/bash

# "Getting started" provisioning script that will provision an Apache2 webserver via Vagrant
# Author: Chuck Lynch

# Provisioning files run as root, so there's no need for sudo in these scripts

echo "Installing Apache2 and configuring . . ."
apt update &> /dev/null
apt install -y apache2 &> /dev/null

# Discard the current/default contents of /var/www and link /vagrant to that location
# This means whatever shares a directory with the vagrantfile on the host side will be what's on the webserver
rm -rf /var/www
ln -fs /vagrant /var/www
