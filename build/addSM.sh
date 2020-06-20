#!/bin/bash

# Script to add and build a webservice that is accessible by the student.
# This webservice allows the student to revert VMs in the scenario and
# - maybe one day -
# submit flags.

# Author: starsnstripes
################################################
# *  *  *  *  *  * 000000000000000000000000000 #
#  *  *  *  *  *   111111111111111111111111111 #
# *  *  *  *  *  * 000000000000000000000000000 #
#  *  *  *  *  *   111111111111111111111111111 #
# *  *  *  *  *  * 000000000000000000000000000 #
#  *  *  *  *  *   111111111111111111111111111 #
# *  *  *  *  *  * 000000000000000000000000000 #
#  *  *  *  *  *   111111111111111111111111111 #
# *  *  *  *  *  * 000000000000000000000000000 #
# 11111111111111111111111111111111111111111111 #
# 00000000000000000000000000000000000000000000 #
# 11111111111111111111111111111111111111111111 #
# 00000000000000000000000000000000000000000sns #
################################################

# Verify that this script is running as root
if [[ $USER != "root" ]]; then
	echo "Please run this script as root so it can install pipenv."
	exit
fi

# Install pipenv as a dependency and set python to be python3
apt install -yqq pipenv python-is-python3 

su dev << DEVCMD
cd /scenario

# Download the codebase
echo "Downloading BSSM . . ."
git clone https://github.com/stars-n-stripes/battleSchoolSM
cd battleSchoolSM

# Setup the server (initial migration)
echo "Migrating Django database schema. . ."
python manage.py makemigrations
python manage.py migrate
DEVCMD
# Run the Django DB migration in a separate su command so we can pull out whether or not an error occured.
MIGRATE_RETURN=$(su dev -c 'python manage.py migrate &> /tmp/django-migrate.log; echo $?')

if [[ $MIGRATE_RETURN ]]; then
	# Something went wrong with the data migration
	echo "ERROR: Something went wrong with building the Battle School Management Server. Please check the log generated at /tmp/django-migrate.log"
	exit
fi

# Run the server 
echo "Running Scenario Manager Web Interface on vboxnet0. . ."
# Grab the server IP that is exposed on the VirtualBox host-only network and only expose the server to that IP
VMWARE_IP=$(ip -f inet addr show vboxnet0 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
sudo python manage.py runserver $VMWARE_IP:80 &

