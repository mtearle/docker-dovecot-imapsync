#!/usr/bin/env bash

# init-like script for the Geary testbed container

source config.shlib; # load the config library functions
source imapsync.shlib; # load imapsync function

# Run tasks as jobs where possible, so we can wait on them.
/usr/sbin/rsyslogd -n &
/usr/sbin/sshd -D &
/usr/sbin/dovecot -F &
/usr/sbin/postfix start # postfix won't get waited on.


# set up mail directory under syncuser
mkdir -p /syncuser/mail
touch /syncuser/mail/inbox
chown -R syncuser.syncuser /syncuser/mail

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

	grep -Iirn ^Message-ID /syncuser/mail > /tmp/synced-msgids

	diff /test-msgids /tmp/synced-msgids

	if [ $? -eq 0 ]
	then
		echo "Successfully synced TEST messages"
	else
		echo "Error syncing messages"
	fi
else
	echo "Good to go!"

	# parameters for test
	host1="$(config_get host1)";
	port1="$(config_get port1)";
	user1="$(config_get user1)";
	password1="$(config_get password1)";
	#
	host2="$(config_get host2)";
	port2="$(config_get port2)";
	user2="$(config_get user2)";
	password2="$(config_get password2)";
	#
	flags="$(config_get flags)";
	defaultflags="$(config_get defaultflags)";

	echo
	echo "Running with:"
	echo
	echo call_imapsync \'$flags\' \'$defaultflags\' $host1 $port1 $user1 $password1 $host2 $port2 $user2 $password2 
	echo
	call_imapsync '$flags' '$defaultflags' $host1 $port1 $user1 $password1 $host2 $port2 $user2 $password2 

	echo "imapsync complete"
fi
