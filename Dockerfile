FROM centos:8

RUN yum -y install openssh openssh-server && yum clean all
COPY slotexec.sh /usr/local/bin/slotexec.sh

# sample script to run on all slots
COPY jobscript.sh /usr/local/bin/jobscript.sh

# replace systemd on nodes 1-n to start sshd
COPY init.sh /sbin/init

# Sample AppDef - see https://jarvice.readthedocs.io/en/latest/appdef/
COPY AppDef.json /etc/NAE/AppDef.json

# JARVICE XE pull optimization - see https://jarvice.readthedocs.io/en/latest/docker/#best-practices
RUN mkdir -p /etc/NAE && touch /etc/NAE/{screenshot.png,screenshot.txt,license.txt,AppDef.json}
