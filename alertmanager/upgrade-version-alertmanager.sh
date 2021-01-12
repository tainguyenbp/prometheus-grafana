#!/bin/bash

# import variable version alertmanager
export version_alertmanager='0.21.0'
export arch_alertmanager='linux-amd64'

wget "https://github.com/prometheus/alertmanager/releases/download/v$version_alertmanager/alertmanager-$version_alertmanager.$arch_alertmanager.tar.gz" -O /etc/alertmanager/alertmanager.tar.gz

tar -xzvf /etc/alertmanager/alertmanager.tar.gz -C /etc/alertmanager/
systemctl stop alertmanager

# delete version alertmanger old
rm -rf /etc/alertmanager/alertmanager
rm -rf /etc/alertmanager/amtool

# update version alermanager new
mv "/etc/alertmanager/alertmanager-$version_alertmanager.$arch_alertmanager/alertmanager" /etc/alertmanager/
mv "/etc/alertmanager/alertmanager-$version_alertmanager.$arch_alertmanager/amtool" /etc/alertmanager/

# permission
chown -R alertmanager:alertmanager /etc/alertmanager
chmod +x /etc/alertmanager/alertmanager

/etc/alertmanager/alertmanager --version
systemctl start alertmanager

rm -rf /etc/alertmanager/alertmanager.tar.gz
rm -rf /etc/alertmanager/alertmanager-$version_alertmanager.$arch_alertmanager

systemctl status alertmanager
