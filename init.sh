#!/usr/bin/env bash

# init-like script for the Geary testbed container

source config.shlib; # load the config library functions

# Run tasks as jobs where possible, so we can wait on them.
/usr/sbin/rsyslogd -n &
/usr/sbin/sshd -D &
/usr/sbin/dovecot -F &
/usr/sbin/postfix start # postfix won't get waited on.

wait
