#!/usr/bin/env bash

# init-like script for the Geary testbed container

source config.shlib; # load the config library functions

# Run tasks as jobs where possible, so we can wait on them.
/usr/sbin/rsyslogd -n &
/usr/sbin/sshd -D &
/usr/sbin/dovecot -F &
/usr/sbin/postfix start # postfix won't get waited on.



# check for dir mounted  (look for HELP file to not exist)
# not mounted, then output help, exit
# if mounted, look for TEST file, run with test params
# if no test file, run normally

if [ -f /syncuser/HELP ]; then
	cat /help.txt
	exit 99
else
	echo "Good to go!"
fi


wait
