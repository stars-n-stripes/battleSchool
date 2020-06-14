#!/bin/bash
# xrdp X session start script (c) 2015, 2017 mirabilos
# published under The MirOS Licence

if test -r /etc/profile; then
	. /etc/profile
fi

if test -r /etc/default/locale; then
	. /etc/default/locale
	test -z "${LANG+x}" || export LANG
	test -z "${LANGUAGE+x}" || export LANGUAGE
	test -z "${LC_ADDRESS+x}" || export LC_ADDRESS
	test -z "${LC_ALL+x}" || export LC_ALL
	test -z "${LC_COLLATE+x}" || export LC_COLLATE
	test -z "${LC_CTYPE+x}" || export LC_CTYPE
	test -z "${LC_IDENTIFICATION+x}" || export LC_IDENTIFICATION
	test -z "${LC_MEASUREMENT+x}" || export LC_MEASUREMENT
	test -z "${LC_MESSAGES+x}" || export LC_MESSAGES
	test -z "${LC_MONETARY+x}" || export LC_MONETARY
	test -z "${LC_NAME+x}" || export LC_NAME
	test -z "${LC_NUMERIC+x}" || export LC_NUMERIC
	test -z "${LC_PAPER+x}" || export LC_PAPER
	test -z "${LC_TELEPHONE+x}" || export LC_TELEPHONE
	test -z "${LC_TIME+x}" || export LC_TIME
	test -z "${LOCPATH+x}" || export LOCPATH
fi
# debug
# echo "$(whoami)" >> /tmp/whoiam
if test "$USER" = "student"; then
	# Have the student connect to the attacker Kali VM
	# TODO: Provide some sort of verification that the VM is up and running.
	echo "Starting student X session via SSH" >> /tmp/xrdp-student.log
	echo "DISPLAY: $DISPLAY" >> /tmp/xrdp-student.log
	ssh vagrant@127.0.0.1 -o "StrictHostKeyChecking=false" -p 8507 -i /scenario/.vagrant/machines/kali/virtualbox/private_key_student -X -C -Y "xhost +; xfce4-session; sudo pkill X;  pkill -U vagrant" &>> /tmp/xrdp-student.log

else
	startxfce4
	#echo "I would start xfce4 now for user $USER"
fi
