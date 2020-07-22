#!/bin/bash

# Script that will clear out the currently loaded scenario and spin up a new one.

# Verify that a scenario and target branch has been provided

if [[ -z $1 ]]; then
	echo "Usage: $0 [scenario name] [branch]"
	exit 1
fi

if [[ -z $2 ]]; then
	echo "Usage: $0 [scenario name] [branch]"
	exit 1
fi

# Test whether or not the scenario exists
# TODO: Replace the directory "challenges" with "scenarios"
if [[ $(wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/$2/challenges/$1/Vagrantfile --spider) ]]; then
	echo "ERROR: Vagrantfile not found at https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$1/Vagrantfile"
	exit 1
fi


if [[ $(wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/$2/challenges/$1/scenario.ini --spider) ]]; then
	echo "ERROR: Vagrantfile not found at https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$1/Vagrantfile"
	exit 1
fi

# We need to be root for the ssh key transfer at the end 
if [[ $USER != "root" ]]; then
	echo "This script must be run as root."
	exit 1
fi

# Virtually all of this will be done as dev
su dev << ENDSU

# If we get past the checks, go ahead and destroy the current scenario
echo "Destroying current Vagrant Scenario. . . "
cd /scenario
vagrant destroy -f &> /dev/null
echo ". . . done."

# Clear out the current scenario files
# The -f flag also suppresses a "file not found" error
echo "Clearing out /scenario. . ."
rm -f Vagrantfile
rm -f scenario.ini
rm -rf .vagrant/
echo "Done."

# Download the new scenario.ini and Vagrantfile
echo "Downloading new scenario files. . . "
wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/$2/challenges/$1/scenario.ini -O scenario.ini

# Build the new Vagrant environment
echo "Building new Vagrant environment. . ."
vagrant init
# Note: Vagrant hates us if we attempt vagrant init after we've already downloaded the Vagrantfile, so that's why we do it after grabbing scenario.ini
wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$1/Vagrantfile -O Vagrantfile
vagrant up --no-destroy-on-error  &> /tmp/scenario_build.log

ENDSU

echo "Giving ownership of Kali ssh key to student. . ."
cp /scenario/.vagrant/machines/kali/virtualbox/private_key /scenario/.vagrant/machines/kali/virtualbox/private_key_student
chown student:student /scenario/.vagrant/machines/kali/virtualbox/private_key_student


# TODO: Tie-in a hook of some sort for the battleSchoolSM

echo "Vagrant commands complete! You should verify that all boxes are up by going to /scenario and running vagrant status"
echo "(If it appears vagrant did not build the scenario properly, check /tmp/scenario_build.log)"
exit 0
