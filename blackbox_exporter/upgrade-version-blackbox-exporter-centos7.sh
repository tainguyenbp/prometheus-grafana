#!/bin/bash

# import variable version blackbox_exporter
export version_blackbox='0.18.0'
export arch_blackbox='linux-amd64


wget "https://github.com/prometheus/blackbox_exporter/releases/download/v$version_blackbox/blackbox_exporter-$version_blackbox.$arch_blackbox.tar.gz" -O /etc/blackbox_exporter/blackbox_exporter.tar.gz

tar -xzvf /etc/blackbox_exporter/blackbox_exporter.tar.gz -C /etc/blackbox_exporter/
systemctl stop blackbox_exporter

# delete version blackbox old
rm -rf /etc/blackbox_exporter/blackbox_exporter

# update version blackbox new
mv "/etc/blackbox_exporter/blackbox_exporter-$version_blackbox.$arch_blackbox/blackbox_exporter" /etc/blackbox_exporter/

# permission
chown -R blackbox_exporter:blackbox_exporter /etc/blackbox_exporter
chmod +x /etc/blackbox_exporter/blackbox_exporter

/etc/blackbox_exporter/blackbox_exporter --version
systemctl start blackbox_exporter

rm -rf /etc/blackbox_exporter/blackbox_exporter.tar.gz
rm -rf /etc/blackbox_exporter/blackbox_exporter-$version_blackbox.$arch_blackbox

systemctl status blackbox_exporter
