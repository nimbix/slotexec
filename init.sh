#!/bin/sh

for i in rsa ecdsa ed25519; do
    /usr/bin/ssh-keygen -q -f /etc/ssh/ssh_host_"$i"_key -N '' -t $i
done

/usr/sbin/sshd

sleep infinity
