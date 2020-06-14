#!/bin/bash
# STUDENT: THIS IS NOT PART OF THE SCENARIO
# MODIFYING THIS FILE WILL DISABLE GUI APPLICATIONS AS ROOT
# exports xauth cookies to root so you can launch GUI applications
auth_string=$(xauth list $DISPLAY)
tgt_display=$DISPLAY

# catch usage of sudo options 
first_arg=$1
if [ "${first_arg::1}" == "-" ] 
then
	sudo xauth add $auth_string && export DISPLAY=$tgt_display && sudo $@ 
else
	sudo xauth add $auth_string && export DISPLAY=$tgt_display && $@ 
fi