#!/bin/bash

# import variable version jiralert
# https://github.com/prometheus-community/jiralert/releases/download/1.0/jiralert-1.0.linux-amd64.tar.gz
export version_jiralert='1.0'
export arch_jiralert='linux-amd64'


wget "https://github.com/prometheus-community/jiralert/releases/download/$version_jiralert/jiralert-$version_jiralert.$arch_jiralert.tar.gz" -O /etc/jiralert/jiralert.tar.gz

tar -xzvf /etc/jiralert/jiralert.tar.gz -C /etc/jiralert/
systemctl stop jiralert

# delete version jiralert old
rm -rf /etc/jiralert/jiralert

# update version jiralert new
mv "/etc/jiralert/jiralert-$version_jiralert.$arch_jiralert/jiralert" /etc/jiralert/

# permission
chown -R jiralert:jiralert /etc/jiralert
chmod +x /etc/jiralert/jiralert

/etc/jiralert/jiralert --version
systemctl start jiralert

rm -rf /etc/jiralert/jiralert.tar.gz
rm -rf /etc/jiralert/jiralert-$version_jiralert.$arch_jiralert

systemctl status jiralert
