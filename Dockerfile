FROM centos:8

# install ssh and sshd for multi-node operation; note that passwd is required by JARVICE runtime to be in the container
RUN yum -y install passwd openssh-clients openssh-server && yum clean all
COPY slotexec.sh /usr/local/bin/slotexec.sh

# sample script to run on all slots
COPY jobscript.sh /usr/local/bin/jobscript.sh

# replace systemd on nodes 1-n to start sshd
RUN rm -f /sbin/init
COPY init.sh /sbin/init

# Sample AppDef - see https://jarvice.readthedocs.io/en/latest/appdef/
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate

# JARVICE XE pull optimization - see https://jarvice.readthedocs.io/en/latest/docker/#best-practices
RUN mkdir -p /etc/NAE && touch /etc/NAE/{screenshot.png,screenshot.txt,license.txt,AppDef.json}
