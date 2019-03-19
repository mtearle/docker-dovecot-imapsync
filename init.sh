#!/usr/bin/env bash

# init-like script for the Geary testbed container

source config.shlib; # load the config library functions
source imapsync.shlib; # load imapsync function

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
elif [ -f /syncuser/TEST ]; then
	echo "Running test imapsync"

	# parameters for test
	host1=localhost
	flags="--ssl1 --ssl2"
	port1=993
	user1=testuser
	password1=testpass
	host2=localhost
	user2=syncuser
	port2=993
	password2=syncpass
	defaultflags="--regextrans2 's/\//_/g'"

	call_imapsync "$flags" "$defaultflags" $host1 $port1 $user1 $password1 $host2 $port2 $user2 $password2 
else
	echo "Good to go!"
fi




read

