#!/bin/bash

yum install -y wget

export version_blackbox_exporter='1.0.1'
export arch_blackbox_exporter='linux-amd64'

useradd --no-create-home --shell /bin/false blackbox_exporter

wget "https://github.com/prometheus/blackbox_exporter/releases/download/v$version_blackbox/blackbox_exporter-$version_blackbox.$arch_blackbox.tar.gz" -O /etc/blackbox_exporter/blackbox_exporter.tar.gz

tar -xzvf /etc/blackbox_exporter.tar.gz -C /etc/

mv "/etc/blackbox_exporter-$version_blackbox_exporter.$arch_blackbox_exporter" /etc/blackbox_exporter

chown -R blackbox_exporter:blackbox_exporter /etc/blackbox_exporter

chmod +x /etc/blackbox_exporter/blackbox_exporter

cat << EOF > /etc/systemd/system/blackbox_exporter.service
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=blackbox_exporter
Group=blackbox_exporter
Type=simple
ExecStart=/etc/blackbox_exporter/blackbox_exporter --config.file /etc/blackbox_exporter/blackbox.yml --log.level=debug
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/blackbox_exporter.service

systemctl enable blackbox_exporter.service

systemctl start blackbox_exporter.service

systemctl status blackbox_exporter.service

rm -rf /etc/blackbox_exporter.tar.gz
