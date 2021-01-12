#!/bin/bash

# import variable version prometheus
export version_prometheus='2.24.0'
export arch_prometheus='linux-amd64'

# download new version promtheus
wget "https://github.com/prometheus/prometheus/releases/download/v$version_prometheus/prometheus-$version_prometheus.$arch_prometheus.tar.gz" -O /etc/prometheus/prometheus.tar.gz
tar -xzvf /etc/prometheus/prometheus.tar.gz -C /etc/prometheus/

systemctl stop prometheus

# delete version prometheus old
rm -rf /etc/prometheus/prometheus
rm -rf /etc/prometheus/consoles
rm -rf /etc/prometheus/console_libraries
rm -rf /etc/prometheus/promtool

# update new version prometheus
mv "/etc/prometheus/prometheus-$version_prometheus.$arch_prometheus/prometheus" /etc/prometheus/
mv "/etc/prometheus/prometheus-$version_prometheus.$arch_prometheus/console_libraries" /etc/prometheus/
mv "/etc/prometheus/prometheus-$version_prometheus.$arch_prometheus/consoles" /etc/prometheus/
mv "/etc/prometheus/prometheus-$version_prometheus.$arch_prometheus/promtool" /etc/prometheus/

# permission
chown -R prometheus:prometheus /etc/prometheus
chmod +x /etc/prometheus/prometheus

# check version prometheus upgraded
/etc/prometheus/prometheus --version
/etc/prometheus/promtool check config /etc/prometheus/prometheus.yml

# reload service when upgrade
systemctl start prometheus
systemctl restart alertmanager
systemctl restart jiralert

rm -rf /etc/prometheus/prometheus.tar.gz
rm -rf /etc/prometheus/prometheus-$version_prometheus.$arch_prometheus
systemctl status prometheus
