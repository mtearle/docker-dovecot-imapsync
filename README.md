docker-dovecot-imapsync
=======================

This is the source to build a Docker image that will let you run a temporary IMAP
server sandboxed on your local machine to enable you to use imapsync to sync
messages to a local mailbox files.

Build the Docker image:

    docker build -t docker-dovecot-imapsync .

Run the image (example usage):

    docker run -v /path/to/sync/to:/syncuser -v /path/to/config.cfg:/config.cfg -v /path/to/passfile:/passfile -p 5522:22 --rm -it docker-dovecot-imapsync 
    
    docker run 
     -v /path/to/sync/to:/syncuser         # bind mount for direct to contain synced emails
     -v /path/to/config.cfg:/config.cfg    # bind mount for config file
     -v /path/to/passfile:/passfile        # bind mount for passfile for imapsync
     -p 5522:22                            # expose SSH port for debug
     --rm                                  # remove image after run
     -it docker-dovecot-imapsync           # image tag

Example config.cfg:

    host1=thatmailhost.example.com
    flags=--ssl1 --ssl2 --passfile1 /passfile
    port1=993
    user1=thatmailuser
    password1=nopass
    

There are three accounts on the image:
    root - password root
    testuser - password testpass
    syncuser - password syncpass

Tests can be run be creating an empty file called TEST under the path to be synced to

Copyright/License
-----------------

Copyright 2019 Mark Tearle

Adapted from docker-dovecot-postfix 
<https://github.com/dcondomitti/docker-dovecot-postfix.git>

Copyright 2014 Yorba Foundation

This program is free software: you can redistribute it and/or modify it under
the terms of the [GNU General Public
License](http://www.gnu.org/licenses/gpl-3.0.html) as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the [GNU General Public
License](http://www.gnu.org/licenses/gpl-3.0.html) for more details.
