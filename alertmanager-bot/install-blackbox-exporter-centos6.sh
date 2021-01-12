#!/bin/bash
yum install -y wget

export version_node_exporter='1.0.1'
export arch_node_exporter='linux-amd64'


useradd --no-create-home --shell /bin/false node_exporter

wget "https://github.com/prometheus/node_exporter/releases/download/v$version_node_exporter/node_exporter-$version_node_exporter.$arch_node_exporter.tar.gz" -O /etc/node_exporter.tar.gz

tar -xzvf /etc/node_exporter.tar.gz -C /etc/

mv "/etc/node_exporter-$version_node_exporter.$arch_node_exporter" /etc/node_exporter

chown -R node_exporter:node_exporter /etc/node_exporter

chmod +x /etc/node_exporter/node_exporter

cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter Metrics Monitors
Wants=network-online.target
After=network-online.target

[Service]

Type=simple

User=node_exporter
Group=node_exporter

ExecStart=/etc/node_exporter/node_exporter \
    --collector.loadavg \
    --collector.meminfo \
    --collector.filesystem \
    --collector.systemd

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/node_exporter.service

systemctl enable node_exporter.service

systemctl start node_exporter.service

systemctl status node_exporter.service

rm -rf /etc/node_exporter.tar.gz
