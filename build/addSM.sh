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

echo "Changing to dev user. . ."
su dev
cd /scenario

# Download the codebase
echo "Downloading BSSM . . ."
git clone https://github.com/stars-n-stripes/battleSchoolSM
cd battleSchoolSM

# Setup the server (initial migration)
echo "Migrating Django database schema. . ."
python manage.py makemigrations
python manage.py migrate

# Run the server 
# TODO: Detect Vbox IP address during runtime
echo "Running Scenario Manager Web Interface . . ."
echo "This will attempt to run via sudo:"
sudo python manage.py runserver 0.0.0.0:80 &
