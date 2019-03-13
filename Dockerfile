# Dovecot & Postfix testbed for Geary
# Ideas taken from https://github.com/sullof/docker-sshd

FROM ubuntu:cosmic
MAINTAINER Charles Lindsay <chaz@yorba.org>

RUN apt-get update -y
RUN apt-get upgrade -y

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

RUN mkdir /var/run/sshd
ADD dovecot.conf /etc/dovecot/conf.d/99-test.conf
ADD postfix.cf /postfix.cf.test
RUN cat /postfix.cf.test >> /etc/postfix/main.cf && rm /postfix.cf.test

RUN groupadd syncuser
RUN useradd -g syncuser -m -s /bin/bash syncuser
RUN echo "root:root" | chpasswd
RUN echo "syncuser:syncpass" | chpasswd

ADD init.sh /init.sh
EXPOSE 22 25 80 110 143 465 993 995

# For imapsync
ADD config.cfg /config.cfg
ADD config.cfg.defaults /config.cfg.defaults
ADD config.shlib /config.shlib

CMD ["/init.sh"]
