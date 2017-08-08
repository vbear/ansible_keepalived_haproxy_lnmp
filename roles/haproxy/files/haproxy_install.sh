#!/bin/bash

cd /root/
tar -xzvf haproxy-1.7.8.tar.gz>/dev/null
cd haproxy-1.7.8
make TARGET=linux2628 >/dev/null
make install>/dev/null
cp /usr/local/sbin/haproxy /usr/sbin/
cp examples/haproxy.init /etc/rc.d/init.d/haproxy
chmod +x /etc/rc.d/init.d/haproxy
if [  ! -d /etc/haproxy ]; then
mkdir /etc/haproxy
fi
