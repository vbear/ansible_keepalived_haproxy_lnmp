#!/bin/bash

cd /root/
tar -xzvf keepalived-1.3.5.tar.gz>/dev/null
cd keepalived-1.3.5
./configure --prefix=/opt/keepalived >/dev/null
make >/dev/null
make install >/dev/null

cp keepalived/etc/init.d/keepalived /etc/init.d/
cp /opt/keepalived/sbin/keepalived /usr/sbin/
echo "KEEPALIVED_OPTIONS=/etc/keepalived/keepalived.conf">/etc/sysconfig/keepalived                                                                                                                                                         
chmod +x /etc/init.d/keepalived
if [  ! -d /etc/keepalived ]; then
mkdir /etc/keepalived
fi
