# Dovecot & Postfix testbed for Geary
# Ideas taken from https://github.com/sullof/docker-sshd

FROM ubuntu:cosmic

RUN apt-get update -y

# Add imapsync install code 

RUN apt-get install -y libjson-webtoken-perl 

RUN apt-get install -y libjson-webtoken-perl \
  libauthen-ntlm-perl \
  libcgi-pm-perl \
  libcrypt-openssl-rsa-perl \
  libdata-uniqid-perl \
  libfile-copy-recursive-perl \
  libio-socket-ssl-perl \
  libio-socket-inet6-perl \
  libio-tee-perl \
  libhtml-parser-perl \
  libjson-webtoken-perl \
  libmail-imapclient-perl \
  libparse-recdescent-perl \
  libmodule-scandeps-perl \
  libpar-packer-perl \
  libreadonly-perl \
  libregexp-common-perl \
  libsys-meminfo-perl \
  libterm-readkey-perl \
  libtest-mockobject-perl \
  libtest-pod-perl \
  libunicode-string-perl \
  liburi-perl  \
  libwww-perl \
  procps \
  wget \
  make \
  cpanminus 

RUN wget -N https://imapsync.lamiral.info/imapsync \
  https://imapsync.lamiral.info/prerequisites_imapsync \
  && cp imapsync /usr/bin/imapsync \
  && chmod +x /usr/bin/imapsync # just_a_comment_to_force_update 2018_09_13_14_44_03



# Allow dovecot install to succeed (see
# https://github.com/dotcloud/docker/issues/1024)
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Allow postfix to install without interaction.
RUN echo "postfix postfix/mailname string example.com" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

RUN apt-get install -y openssh-server
RUN apt-get install -y dovecot-imapd
RUN apt-get install -y postfix
RUN apt-get install -y rsyslog

RUN mkdir /var/run/sshd

# let dovecot autoconfigure mailbox
RUN sed -i '/mail_location = mbox:~\/mail:INBOX=\/var\/mail\/%u/d' /etc/dovecot/conf.d/10-mail.conf
COPY dovecot.conf /etc/dovecot/conf.d/99-test.conf
COPY postfix.cf /postfix.cf.test
RUN cat /postfix.cf.test >> /etc/postfix/main.cf && rm /postfix.cf.test

RUN echo "root:root" | chpasswd

# user to sync to
RUN groupadd syncuser
RUN useradd -g syncuser -m -s /bin/bash -d /syncuser syncuser
RUN echo "syncuser:syncpass" | chpasswd

# help doco
COPY help.txt /help.txt
RUN touch /syncuser/HELP
RUN chown syncuser.syncuser /syncuser/HELP

# user for testing sync locally
RUN groupadd testuser
RUN useradd -g testuser -m -s /bin/bash -d /testuser testuser
RUN echo "testuser:testpass" | chpasswd

# obtain corpus of test emails from https://github.com/tedious/DovecotTesting
RUN wget -q -O - https://github.com/tedious/DovecotTesting/archive/master.tar.gz  | tar -C /testuser -x -v -z -f - DovecotTesting-master/resources/Maildir --strip-components=2
RUN chown -R testuser.testuser /testuser/Maildir
COPY test-msgids /test-msgids

COPY init.sh /init.sh
EXPOSE 22 25 80 110 143 465 993 995

# For imapsync
COPY config.cfg /config.cfg
COPY config.cfg.defaults /config.cfg.defaults
COPY config.shlib /config.shlib
COPY imapsync.shlib /imapsync.shlib

CMD ["/init.sh"]
