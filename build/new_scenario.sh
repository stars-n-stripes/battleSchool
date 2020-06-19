#!/bin/bash

# Script that will clear out the currently loaded scenario and spin up a new one.

# Verify that a scenario has been provided

if [[ -z $1 ]]; then
	echo "Usage: $0 [scenario name]"
	exit 1
fi

# Test whether or not the scenario exists
# TODO: Replace the directory "challenges" with "scenarios"
if [[ $(wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$1/Vagrantfile --spider) ]]; then
	echo "ERROR: Vagrantfile not found at https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$1/Vagrantfile"
	exit 1
fi

# We need to be the dev user for this
if [[ $USER != "dev" ]]; then
	echo "This script must be run as dev."
	exit 1
fi

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
wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$1/scenario.ini -O scenario.ini

# Build the new Vagrant environment
echo "Building new Vagrant environment. . ."
vagrant init
# Note: Vagrant hates us if we attempt vagrant init after we've already downloaded the Vagrantfile, so that's why we do it after grabbing scenario.ini
wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/$1/Vagrantfile -O Vagrantfile
vagrant up &> /tmp/scenario_build.log
vagrant_result=$?
# $? Represents the exit code of the last command, which in this case should be vagrant up
if [[ vagrant_result ]]; then
	echo "INFO: Vagrant returned a non-zero exit code ($vagrant_result). This doesn't neccessarily mean complete failure, but you should take a look at the log located at /tmp/scenario_build.log"
fi

# TODO: Tie-in a hook of some sort for the battleSchoolSM

echo "Vagrant commands complete! You should verify that all boxes are up by going to /scenario and running vagrant status"
exit 0
